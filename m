Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84EFE6B03B5
	for <linux-mm@kvack.org>; Sun,  7 May 2017 22:59:49 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z125so54333126itc.4
        for <linux-mm@kvack.org>; Sun, 07 May 2017 19:59:49 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m187si9172295itb.2.2017.05.07.19.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 19:59:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Date: Mon, 8 May 2017 02:58:36 +0000
Message-ID: <20170508025827.GA4913@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz>
 <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
 <20170502185507.GB19165@dhcp22.suse.cz>
In-Reply-To: <20170502185507.GB19165@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E9693BC9B8093D419D88C2482F5A05C5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, May 02, 2017 at 08:55:07PM +0200, Michal Hocko wrote:
> On Tue 02-05-17 16:59:30, Laurent Dufour wrote:
> > On 28/04/2017 15:48, Michal Hocko wrote:
> [...]
> > > This is getting quite hairy. What is the expected page count of the
> > > hwpoison page?
>=20
> OK, so from the quick check of the hwpoison code it seems that the ref
> count will be > 1 (from get_hwpoison_page).
>=20
> > > I guess we would need to update the VM_BUG_ON in the
> > > memcg uncharge code to ignore the page count of hwpoison pages if it =
can
> > > be arbitrary.
> >=20
> > Based on the experiment I did, page count =3D=3D 2 when isolate_lru_pag=
e()
> > succeeds, even in the case of a poisoned page.
>=20
> that would make some sense to me. The page should have been already
> unmapped therefore but memory_failure increases the ref count and 1 is
> for isolate_lru_page().

# sorry for late reply, I was on holidays last week...

Right, and the refcount taken for memory_failure is not freed after
memory_failure() returns. unpoison_memory() does free the refcount.

>=20
> > In my case I think this
> > is because the page is still used by the process which is calling madvi=
se().
> >=20
> > I'm wondering if I'm looking at the right place. May be the poisoned
> > page should remain attach to the memory_cgroup until no one is using it=
.
> > In that case this means that something should be done when the page is
> > off-lined... I've to dig further here.
>=20
> No, AFAIU the page will not drop the reference count down to 0 in most
> cases. Maybe there are some scenarios where this can happen but I would
> expect that the poisoned page will be mapped and in use most of the time
> and won't drop down 0. And then we should really uncharge it because it
> will pin the memcg and make it unfreeable which doesn't seem to be what
> we want.  So does the following work reasonable? Andi, Johannes, what do
> you think? I cannot say I would be really comfortable touching hwpoison
> code as I really do not understand the workflow. Maybe we want to move
> this uncharge down to memory_failure() right before we report success?

memory_failure() can be called for any types of page (including slab or
any kernel/driver pages), and the reported problem seems happen only on
in-use user pages, so uncharging in delete_from_lru_cache() as done below
looks better to me.

> ---
> From 8bf0791bcf35996a859b6d33fb5494e5b53de49d Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 2 May 2017 20:32:24 +0200
> Subject: [PATCH] hwpoison, memcg: forcibly uncharge LRU pages
>=20
> Laurent Dufour has noticed that hwpoinsoned pages are kept charged. In
> his particular case he has hit a bad_page("page still charged to cgroup")
> when onlining a hwpoison page.

> While this looks like something that shouldn't
> happen in the first place because onlining hwpages and returning them to
> the page allocator makes only little sense it shows a real problem.
>=20
> hwpoison pages do not get freed usually so we do not uncharge them (at
> least not since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")).
> Each charge pins memcg (since e8ea14cc6ead ("mm: memcontrol: take a css
> reference for each charged page")) as well and so the mem_cgroup and the
> associated state will never go away. Fix this leak by forcibly
> uncharging a LRU hwpoisoned page in delete_from_lru_cache(). We also
> have to tweak uncharge_list because it cannot rely on zero ref count
> for these pages.
>=20
> Fixes: 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")
> Reported-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memcontrol.c     | 2 +-
>  mm/memory-failure.c | 7 +++++++
>  2 files changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 16c556ac103d..4cf26059adb1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5527,7 +5527,7 @@ static void uncharge_list(struct list_head *page_li=
st)
>  		next =3D page->lru.next;
> =20
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
> -		VM_BUG_ON_PAGE(page_count(page), page);
> +		VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
> =20
>  		if (!page->mem_cgroup)
>  			continue;
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8a6bd3a9eb1e..4497d9619bb4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -541,6 +541,13 @@ static int delete_from_lru_cache(struct page *p)
>  		 */
>  		ClearPageActive(p);
>  		ClearPageUnevictable(p);
> +
> +		/*
> +		 * Poisoned page might never drop its ref count to 0 so we have to
> +		 * uncharge it manually from its memcg.
> +		 */
> +		mem_cgroup_uncharge(p);
> +
>  		/*
>  		 * drop the page count elevated by isolate_lru_page()
>  		 */
> --=20
> 2.11.0
>=20
> --=20
> Michal Hocko
> SUSE Labs
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
