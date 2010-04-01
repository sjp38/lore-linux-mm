Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D7B836B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 22:43:19 -0400 (EDT)
Received: by pwi2 with SMTP id 2so695521pwi.14
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:43:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	 <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	 <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Apr 2010 11:43:18 +0900
Message-ID: <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Mar 2010 10:14:49 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> PageAnon pages that are unmapped may or may not have an anon_vma so
>> are not currently migrated. However, a swap cache page can be migrated
>> and fits this description. This patch identifies page swap caches and
>> allows them to be migrated.
>>
>
> Some comments.
>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> ---
>> =C2=A0mm/migrate.c | =C2=A0 15 ++++++++++-----
>> =C2=A0mm/rmap.c =C2=A0 =C2=A0| =C2=A0 =C2=A06 ++++--
>> =C2=A02 files changed, 14 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 35aad2a..f9bf37e 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -203,6 +203,9 @@ static int migrate_page_move_mapping(struct address_=
space *mapping,
>> =C2=A0 =C2=A0 =C2=A0 void **pslot;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (!mapping) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
SetPageSwapCache(newpage);
>> +
>
> Migration of SwapCache requires radix-tree replacement, IOW,
> =C2=A0mapping =3D=3D NULL && PageSwapCache is BUG.
>
> So, this never happens.
>
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Anonymous page witho=
ut mapping */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_count(page) !=
=3D 1)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return -EAGAIN;
>> @@ -607,11 +610,13 @@ static int unmap_and_move(new_page_t get_new_page,=
 unsigned long private,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the page was is=
olated and when we reached here while
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RCU lock wa=
s not held
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapped(page))
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto rcu_unlock;
>> -
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D page_anon_vma(p=
age);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&anon_vma->extern=
al_refcount);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapped(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (!PageSwapCache(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 goto rcu_unlock;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
anon_vma =3D page_anon_vma(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
atomic_inc(&anon_vma->external_refcount);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 /*
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index af35b75..d5ea1f2 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(=
struct page *,
>>
>> =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageKsm(page)))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_ksm(pa=
ge, rmap_one, arg);
>> - =C2=A0 =C2=A0 else if (PageAnon(page))
>> + =C2=A0 =C2=A0 else if (PageAnon(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
return SWAP_AGAIN;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_anon(p=
age, rmap_one, arg);
>
> SwapCache has a condition as (PageSwapCache(page) && page_mapped(page) =
=3D=3D true.
>

In case of tmpfs, page has swapcache but not mapped.

> Please see do_swap_page(), PageSwapCache bit is cleared only when
>
> do_swap_page()...
> =C2=A0 =C2=A0 =C2=A0 swap_free(entry);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vm_swap_full() || (vma->vm_flags & VM_LOCK=
ED) || PageMlocked(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_free_swap(p=
age);
>
> Then, PageSwapCache is cleared only when swap is freeable even if mapped.
>
> rmap_walk_anon() should be called and the check is not necessary.

Frankly speaking, I don't understand what is Mel's problem, why he added
Swapcache check in rmap_walk, and why do you said we don't need it.

Could you explain more detail if you don't mind?

>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
