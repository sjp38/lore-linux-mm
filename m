Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E22D66B01F0
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 06:51:33 -0400 (EDT)
Received: by pzk16 with SMTP id 16so920986pzk.22
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 03:51:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	 <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	 <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	 <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
	 <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
	 <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
	 <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Apr 2010 19:51:31 +0900
Message-ID: <w2i28c262361004010351r605c897dzd2bdccac149dcc6b@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 1, 2010 at 2:42 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 1 Apr 2010 13:44:29 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, 1 Apr 2010 11:43:18 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki =C2=A0 =C2=A0 =C2=
=A0 /*
>> >> >> diff --git a/mm/rmap.c b/mm/rmap.c
>> >> >> index af35b75..d5ea1f2 100644
>> >> >> --- a/mm/rmap.c
>> >> >> +++ b/mm/rmap.c
>> >> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap=
_one)(struct page *,
>> >> >>
>> >> >> =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageKsm(page)))
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_=
ksm(page, rmap_one, arg);
>> >> >> - =C2=A0 =C2=A0 else if (PageAnon(page))
>> >> >> + =C2=A0 =C2=A0 else if (PageAnon(page)) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(page=
))
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return SWAP_AGAIN;
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_=
anon(page, rmap_one, arg);
>> >> >
>> >> > SwapCache has a condition as (PageSwapCache(page) && page_mapped(pa=
ge) =3D=3D true.
>> >> >
>> >>
>> >> In case of tmpfs, page has swapcache but not mapped.
>> >>
>> >> > Please see do_swap_page(), PageSwapCache bit is cleared only when
>> >> >
>> >> > do_swap_page()...
>> >> > =C2=A0 =C2=A0 =C2=A0 swap_free(entry);
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vm_swap_full() || (vma->vm_flags & V=
M_LOCKED) || PageMlocked(page))
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_free_=
swap(page);
>> >> >
>> >> > Then, PageSwapCache is cleared only when swap is freeable even if m=
apped.
>> >> >
>> >> > rmap_walk_anon() should be called and the check is not necessary.
>> >>
>> >> Frankly speaking, I don't understand what is Mel's problem, why he ad=
ded
>> >> Swapcache check in rmap_walk, and why do you said we don't need it.
>> >>
>> >> Could you explain more detail if you don't mind?
>> >>
>> > I may miss something.
>> >
>> > unmap_and_move()
>> > =C2=A01. try_to_unmap(TTU_MIGRATION)
>> > =C2=A02. move_to_newpage
>> > =C2=A03. remove_migration_ptes
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0-> rmap_walk()
>> >
>> > Then, to map a page back we unmapped we call rmap_walk().
>> >
>> > Assume a SwapCache which is mapped, then, PageAnon(page) =3D=3D true.
>> >
>> > =C2=A0At 1. try_to_unmap() will rewrite pte with swp_entry of SwapCach=
e.
>> > =C2=A0 =C2=A0 =C2=A0 mapcount goes to 0.
>> > =C2=A0At 2. SwapCache is copied to a new page.
>> > =C2=A0At 3. The new page is mapped back to the place. Now, newpage's m=
apcount is 0.
>> > =C2=A0 =C2=A0 =C2=A0 Before patch, the new page is mapped back to all =
ptes.
>> > =C2=A0 =C2=A0 =C2=A0 After patch, the new page is not mapped back beca=
use its mapcount is 0.
>> >
>> > I don't think shared SwapCache of anon is not an usual behavior, so, t=
he logic
>> > before patch is more attractive.
>> >
>> > If SwapCache is not mapped before "1", we skip "1" and rmap_walk will =
do nothing
>> > because page->mapping is NULL.
>> >
>>
>> Thanks. I agree. We don't need the check.
>> Then, my question is why Mel added the check in rmap_walk.
>> He mentioned some BUG trigger and fixed things after this patch.
>> What's it?
>> Is it really related to this logic?
>> I don't think so or we are missing something.
>>
> Hmm. Consiering again.
>
> Now.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_locked =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mapped(p=
age)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!PageSwapCache(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto rcu_unlock;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0anon_vma =3D page_anon_vma(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0atomic_inc(&anon_vma->external_refcount);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>
> Maybe this is a fix.
>
> =3D=3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0skip_remap =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mapped(p=
age)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!PageSwapCache(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto rcu_unlock;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * We can't convice this anon_vma is valid or not because
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * !page_mapped(page). Then, we do migration(radix-tree replaceme=
nt)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * but don't remap it which touches anon_vma in page->mapping.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0skip_remap =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto skip_unmap;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0anon_vma =3D page_anon_vma(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0atomic_inc(&anon_vma->external_refcount);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.....copy page, radix-tree replacement,....
>

It's not enough.
we uses remove_migration_ptes in  move_to_new_page, too.
We have to prevent it.
We can check PageSwapCache(page) in move_to_new_page and then
skip remove_migration_ptes.

ex)
static int move_to_new_page(....)
{
     int swapcache =3D PageSwapCache(page);
     ...
     if (!swapcache)
         if(!rc)
             remove_migration_ptes
         else
             newpage->mapping =3D NULL;
}

And we have to close race between PageAnon(page) and rcu_read_lock.
If we don't do it, anon_vma could be free in the middle of operation.
I means

         * of migration. File cache pages are no problem because of page_lo=
ck()
         * File Caches may use write_page() or lock_page() in migration, th=
en,
         * just care Anon page here.
         */
        if (PageAnon(page)) {
                !!! RACE !!!!
                rcu_read_lock();
                rcu_locked =3D 1;

+
+               /*
+                * If the page has no mappings any more, just bail. An
+                * unmapped anon page is likely to be freed soon but worse,


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
