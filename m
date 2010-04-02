Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 73CB66B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:20:30 -0400 (EDT)
Received: by pvg11 with SMTP id 11so113981pvg.14
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 17:20:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100401173640.GB621@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	 <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	 <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	 <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
	 <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
	 <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
	 <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com>
	 <w2i28c262361004010351r605c897dzd2bdccac149dcc6b@mail.gmail.com>
	 <20100401173640.GB621@csn.ul.ie>
Date: Fri, 2 Apr 2010 09:20:27 +0900
Message-ID: <l2s28c262361004011720pd7abc6d6id54d85c756997b95@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 2, 2010 at 2:36 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Apr 01, 2010 at 07:51:31PM +0900, Minchan Kim wrote:
>> On Thu, Apr 1, 2010 at 2:42 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, 1 Apr 2010 13:44:29 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > On Thu, 1 Apr 2010 11:43:18 +0900
>> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >> >
>> >> >> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki =C2=A0 =C2=A0 =
=C2=A0 /*
>> >> >> >> diff --git a/mm/rmap.c b/mm/rmap.c
>> >> >> >> index af35b75..d5ea1f2 100644
>> >> >> >> --- a/mm/rmap.c
>> >> >> >> +++ b/mm/rmap.c
>> >> >> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*r=
map_one)(struct page *,
>> >> >> >>
>> >> >> >> =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageKsm(page)))
>> >> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_wa=
lk_ksm(page, rmap_one, arg);
>> >> >> >> - =C2=A0 =C2=A0 else if (PageAnon(page))
>> >> >> >> + =C2=A0 =C2=A0 else if (PageAnon(page)) {
>> >> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(p=
age))
>> >> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return SWAP_AGAIN;
>> >> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_wa=
lk_anon(page, rmap_one, arg);
>> >> >> >
>> >> >> > SwapCache has a condition as (PageSwapCache(page) && page_mapped=
(page) =3D=3D true.
>> >> >> >
>> >> >>
>> >> >> In case of tmpfs, page has swapcache but not mapped.
>> >> >>
>> >> >> > Please see do_swap_page(), PageSwapCache bit is cleared only whe=
n
>> >> >> >
>> >> >> > do_swap_page()...
>> >> >> > =C2=A0 =C2=A0 =C2=A0 swap_free(entry);
>> >> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vm_swap_full() || (vma->vm_flags =
& VM_LOCKED) || PageMlocked(page))
>> >> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_fr=
ee_swap(page);
>> >> >> >
>> >> >> > Then, PageSwapCache is cleared only when swap is freeable even i=
f mapped.
>> >> >> >
>> >> >> > rmap_walk_anon() should be called and the check is not necessary=
.
>> >> >>
>> >> >> Frankly speaking, I don't understand what is Mel's problem, why he=
 added
>> >> >> Swapcache check in rmap_walk, and why do you said we don't need it=
.
>> >> >>
>> >> >> Could you explain more detail if you don't mind?
>> >> >>
>> >> > I may miss something.
>> >> >
>> >> > unmap_and_move()
>> >> > =C2=A01. try_to_unmap(TTU_MIGRATION)
>> >> > =C2=A02. move_to_newpage
>> >> > =C2=A03. remove_migration_ptes
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0-> rmap_walk()
>> >> >
>> >> > Then, to map a page back we unmapped we call rmap_walk().
>> >> >
>> >> > Assume a SwapCache which is mapped, then, PageAnon(page) =3D=3D tru=
e.
>> >> >
>> >> > =C2=A0At 1. try_to_unmap() will rewrite pte with swp_entry of SwapC=
ache.
>> >> > =C2=A0 =C2=A0 =C2=A0 mapcount goes to 0.
>> >> > =C2=A0At 2. SwapCache is copied to a new page.
>> >> > =C2=A0At 3. The new page is mapped back to the place. Now, newpage'=
s mapcount is 0.
>> >> > =C2=A0 =C2=A0 =C2=A0 Before patch, the new page is mapped back to a=
ll ptes.
>> >> > =C2=A0 =C2=A0 =C2=A0 After patch, the new page is not mapped back b=
ecause its mapcount is 0.
>> >> >
>> >> > I don't think shared SwapCache of anon is not an usual behavior, so=
, the logic
>> >> > before patch is more attractive.
>> >> >
>> >> > If SwapCache is not mapped before "1", we skip "1" and rmap_walk wi=
ll do nothing
>> >> > because page->mapping is NULL.
>> >> >
>> >>
>> >> Thanks. I agree. We don't need the check.
>> >> Then, my question is why Mel added the check in rmap_walk.
>> >> He mentioned some BUG trigger and fixed things after this patch.
>> >> What's it?
>> >> Is it really related to this logic?
>> >> I don't think so or we are missing something.
>> >>
>> > Hmm. Consiering again.
>> >
>> > Now.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_locked =3D =
1;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock()=
;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mappe=
d(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (!PageSwapCache(page))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto rcu_unlock;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0anon_vma =3D page_anon_vma(page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0atomic_inc(&anon_vma->external_refcount);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> >
>> > Maybe this is a fix.
>> >
>> > =3D=3D
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0skip_remap =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock()=
;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mappe=
d(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (!PageSwapCache(page))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto rcu_unlock;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * We can't convice this anon_vma is valid or not because
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * !page_mapped(page). Then, we do migration(radix-tree replac=
ement)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * but don't remap it which touches anon_vma in page->mapping.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0skip_remap =3D 1;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0goto skip_unmap;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0anon_vma =3D page_anon_vma(page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0atomic_inc(&anon_vma->external_refcount);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.....copy page, radix-tree replacement,....
>> >
>>
>> It's not enough.
>> we uses remove_migration_ptes in =C2=A0move_to_new_page, too.
>> We have to prevent it.
>> We can check PageSwapCache(page) in move_to_new_page and then
>> skip remove_migration_ptes.
>>
>> ex)
>> static int move_to_new_page(....)
>> {
>> =C2=A0 =C2=A0 =C2=A0int swapcache =3D PageSwapCache(page);
>> =C2=A0 =C2=A0 =C2=A0...
>> =C2=A0 =C2=A0 =C2=A0if (!swapcache)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if(!rc)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_migration_ptes
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0newpage->mapping =3D NUL=
L;
>> }
>>
>
> This I agree with.
>
>> And we have to close race between PageAnon(page) and rcu_read_lock.
>
> Not so sure on this. The page is locked at this point and that should
> prevent it from becoming !PageAnon

page lock can't prevent anon_vma free.
It's valid just only file-backed page, I think.

>> If we don't do it, anon_vma could be free in the middle of operation.
>> I means
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* of migration. File cache pages are n=
o problem because of page_lock()
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* File Caches may use write_page() or =
lock_page() in migration, then,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* just care Anon page here.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !!! RACE !!!!
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_locked =3D 1=
;
>>
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the page h=
as no mappings any more, just bail. An
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapped anon=
 page is likely to be freed soon but worse,
>>
>
> I am not sure this race exists because the page is locked but a key
> observation has been made - A page that is unmapped can be migrated if
> it's PageSwapCache but it may not have a valid anon_vma. Hence, in the
> !page_mapped case, the key is to not use anon_vma. How about the
> following patch?

I like this. Kame. How about your opinion?
please, look at a comment.

>
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
>
> mm,migration: Allow the migration of PageSwapCache pages
>
> PageAnon pages that are unmapped may or may not have an anon_vma so are
> not currently migrated. However, a swap cache page can be migrated and
> fits this description. This patch identifies page swap caches and allows
> them to be migrated but ensures that no attempt to made to remap the page=
s
> would would potentially try to access an already freed anon_vma.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 35aad2a..5d0218b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -484,7 +484,8 @@ static int fallback_migrate_page(struct address_space=
 *mapping,
> =C2=A0* =C2=A0 < 0 - error code
> =C2=A0* =C2=A0=3D=3D 0 - success
> =C2=A0*/
> -static int move_to_new_page(struct page *newpage, struct page *page)
> +static int move_to_new_page(struct page *newpage, struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 int safe_to_remap)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rc;
> @@ -519,10 +520,12 @@ static int move_to_new_page(struct page *newpage, s=
truct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D fallback_mi=
grate_page(mapping, newpage, page);
>
> - =C2=A0 =C2=A0 =C2=A0 if (!rc)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 remove_migration_ptes(=
page, newpage);
> - =C2=A0 =C2=A0 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 newpage->mapping =3D N=
ULL;
> + =C2=A0 =C2=A0 =C2=A0 if (safe_to_remap) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!rc)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 remove_migration_ptes(page, newpage);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 newpage->mapping =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page(newpage);
>
> @@ -539,6 +542,7 @@ static int unmap_and_move(new_page_t get_new_page, un=
signed long private,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rc =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int *result =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *newpage =3D get_new_page(page, pr=
ivate, &result);
> + =C2=A0 =C2=A0 =C2=A0 int safe_to_remap =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rcu_locked =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int charge =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem =3D NULL;
> @@ -600,18 +604,26 @@ static int unmap_and_move(new_page_t get_new_page, =
unsigned long private,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_locked =3D 1;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the page ha=
s no mappings any more, just bail. An
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapped anon =
page is likely to be freed soon but worse,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it's possible =
its anon_vma disappeared between when
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the page was i=
solated and when we reached here while
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RCU lock w=
as not held
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapped(page)=
)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto rcu_unlock;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Determine how to sa=
fely use anon_vma */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapped(page)=
) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!PageSwapCache(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto rcu_unlock;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D page_anon=
_vma(page);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&anon_vma->=
external_refcount);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* We cannot be sure that the anon_vma of an unmapped
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* page is safe to use. In this case, the page still

How about changing comment?
"In this case, swapcache page still "
Also, I want to change "safe_to_remap" to "remap_swapcache".
I think it's just problem related to swapcache page.
So I want to represent it explicitly although we can know it's swapcache
by code.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
