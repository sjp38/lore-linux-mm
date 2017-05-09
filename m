Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF9FA831FE
	for <linux-mm@kvack.org>; Tue,  9 May 2017 19:09:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d142so15613799oib.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 16:09:34 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 63si543104ote.123.2017.05.09.16.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 16:09:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Date: Tue, 9 May 2017 22:59:27 +0000
Message-ID: <20170509225927.GA11822@hori1.linux.bs1.fc.nec.co.jp>
References: <20170427143721.GK4706@dhcp22.suse.cz>
 <87pofxk20k.fsf@firstfloor.org> <20170428060755.GA8143@dhcp22.suse.cz>
 <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
 <20170502185507.GB19165@dhcp22.suse.cz>
 <20170508025827.GA4913@hori1.linux.bs1.fc.nec.co.jp>
 <20170509091823.GF6481@dhcp22.suse.cz>
In-Reply-To: <20170509091823.GF6481@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6E41886D5944404DBD286165EF9ABB02@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, May 09, 2017 at 11:18:23AM +0200, Michal Hocko wrote:
> On Mon 08-05-17 02:58:36, Naoya Horiguchi wrote:
> > On Tue, May 02, 2017 at 08:55:07PM +0200, Michal Hocko wrote:
> > > On Tue 02-05-17 16:59:30, Laurent Dufour wrote:
> > > > On 28/04/2017 15:48, Michal Hocko wrote:
> > > [...]
> > > > > This is getting quite hairy. What is the expected page count of t=
he
> > > > > hwpoison page?
> > >=20
> > > OK, so from the quick check of the hwpoison code it seems that the re=
f
> > > count will be > 1 (from get_hwpoison_page).
> > >=20
> > > > > I guess we would need to update the VM_BUG_ON in the
> > > > > memcg uncharge code to ignore the page count of hwpoison pages if=
 it can
> > > > > be arbitrary.
> > > >=20
> > > > Based on the experiment I did, page count =3D=3D 2 when isolate_lru=
_page()
> > > > succeeds, even in the case of a poisoned page.
> > >=20
> > > that would make some sense to me. The page should have been already
> > > unmapped therefore but memory_failure increases the ref count and 1 i=
s
> > > for isolate_lru_page().
> >=20
> > # sorry for late reply, I was on holidays last week...
> >=20
> > Right, and the refcount taken for memory_failure is not freed after
> > memory_failure() returns. unpoison_memory() does free the refcount.
>=20
> OK, from the charge POV this would be safe because we clear page->memcg
> so it wouldn't get uncharged more times.
>=20
> > > > In my case I think this
> > > > is because the page is still used by the process which is calling m=
advise().
> > > >=20
> > > > I'm wondering if I'm looking at the right place. May be the poisone=
d
> > > > page should remain attach to the memory_cgroup until no one is usin=
g it.
> > > > In that case this means that something should be done when the page=
 is
> > > > off-lined... I've to dig further here.
> > >=20
> > > No, AFAIU the page will not drop the reference count down to 0 in mos=
t
> > > cases. Maybe there are some scenarios where this can happen but I wou=
ld
> > > expect that the poisoned page will be mapped and in use most of the t=
ime
> > > and won't drop down 0. And then we should really uncharge it because =
it
> > > will pin the memcg and make it unfreeable which doesn't seem to be wh=
at
> > > we want.  So does the following work reasonable? Andi, Johannes, what=
 do
> > > you think? I cannot say I would be really comfortable touching hwpois=
on
> > > code as I really do not understand the workflow. Maybe we want to mov=
e
> > > this uncharge down to memory_failure() right before we report success=
?
> >=20
> > memory_failure() can be called for any types of page (including slab or
> > any kernel/driver pages), and the reported problem seems happen only on
> > in-use user pages, so uncharging in delete_from_lru_cache() as done bel=
ow
> > looks better to me.
>=20
> Yeah, we do see problems only for LRU/page cache pages but my
> understanding is that error_states (e.g. me_kernel for the kernel
> memory) might change in the future and then we wouldn't catch the same
> bug, no?

Right about future change, and we will see the same bug. I guess that the
first target of kernel page is slab page, and memcg_kmem_uncharge() will
be used there. Implementors/Reviewers should care about uncharging when the
time comes.

Thanks,
Naoya Horiguchi

>=20
> > > ---
> > > From 8bf0791bcf35996a859b6d33fb5494e5b53de49d Mon Sep 17 00:00:00 200=
1
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Tue, 2 May 2017 20:32:24 +0200
> > > Subject: [PATCH] hwpoison, memcg: forcibly uncharge LRU pages
> > >=20
> > > Laurent Dufour has noticed that hwpoinsoned pages are kept charged. I=
n
> > > his particular case he has hit a bad_page("page still charged to cgro=
up")
> > > when onlining a hwpoison page.
> >=20
> > > While this looks like something that shouldn't
> > > happen in the first place because onlining hwpages and returning them=
 to
> > > the page allocator makes only little sense it shows a real problem.
> > >=20
> > > hwpoison pages do not get freed usually so we do not uncharge them (a=
t
> > > least not since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")=
).
> > > Each charge pins memcg (since e8ea14cc6ead ("mm: memcontrol: take a c=
ss
> > > reference for each charged page")) as well and so the mem_cgroup and =
the
> > > associated state will never go away. Fix this leak by forcibly
> > > uncharging a LRU hwpoisoned page in delete_from_lru_cache(). We also
> > > have to tweak uncharge_list because it cannot rely on zero ref count
> > > for these pages.
> > >=20
> > > Fixes: 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")
> > > Reported-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> >=20
> > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> Thanks! I will wait a day or two for Johannes and repost the patch.
> Andrew could you drop
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-uncharge-poisoned-pages.p=
atch
> in the mean time, please?
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
