Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A02B2900139
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:20:30 -0400 (EDT)
Received: by ywm13 with SMTP id 13so5295397ywm.14
        for <linux-mm@kvack.org>; Sun, 28 Aug 2011 21:20:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110827173421.GA2967@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
	<20110822213347.GF2507@redhat.com>
	<CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
	<20110824000914.GH23870@redhat.com>
	<20110824002717.GI23870@redhat.com>
	<20110824133459.GP23870@redhat.com>
	<20110826062436.GA5847@google.com>
	<20110826161048.GE23870@redhat.com>
	<20110826185430.GA2854@redhat.com>
	<20110827094152.GA16402@google.com>
	<20110827173421.GA2967@redhat.com>
Date: Mon, 29 Aug 2011 13:20:26 +0900
Message-ID: <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sun, Aug 28, 2011 at 2:34 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> On Sat, Aug 27, 2011 at 02:41:52AM -0700, Michel Lespinasse wrote:
>> I understand you may have to remove the VM_BUG_ON(page_mapcount(page) <=
=3D 0)
>> that I had suggested in __get_page_tail() (sorry about that).
>
> The function doing that is snd_pcm_mmap_data_fault and it's doing what
> I described in prev email.
>
>> My only additional suggestion is about the put_page_testzero in
>> __get_page_tail(), maybe if you could just increment the tail page count
>> instead of calling __get_page_tail_foll(), then you wouldn't have to
>> release the extra head page count there. And it would even look kinda
>> natural, head page count gets acquired before compound_lock_irqsave(),
>> so we only have to acquire an extra tail page count after confirming
>> this is still a tail page.
>
> Ok, I added a param to __get_page_tail_foll, it is constant at build
> time and because it's inline the branch should be optimized away at
> build time without requiring a separate function. The bugchecks are
> the same so we can share and just skip the atomic_inc on the
> page_head in __get_page_tail_foll. Also it had to be moved into
> internal.h as a further cleanup.
>
>> Either way, the code looks OK by now.
>>
>> Reviewed-by: Michel Lespinasse <walken@google.com>
>
> Thanks. Incremental diff to correct the false positive bug on for
> drivers like alsa allocating __GFP_COMP and mapping subpages with page
> faults.
>
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -166,12 +166,6 @@ int __get_page_tail(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flags =3D compound=
_lock_irqsave(page_head);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* here __split_hu=
ge_page_refcount won't run anymore */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(PageTai=
l(page))) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* get_page() can only be called on tail pages
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* after get_page_foll() taken a tail page
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* refcount.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 VM_BUG_ON(page_mapcount(page) <=3D 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__get_page_tail_foll(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0got =3D 1;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
>
> This is the optimization.
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -375,26 +375,6 @@ static inline int page_count(struct page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return atomic_read(&compound_head(page)->_coun=
t);
> =C2=A0}
>
> -static inline void __get_page_tail_foll(struct page *page)
> -{
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we're getting a tail page, the elevated=
 page->_count is
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* required only in the head page and we will=
 elevate the head
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* page->_count and tail page->_mapcount.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* We elevate page_tail->_mapcount for tail p=
ages to force
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* page_tail->_count to be zero at all times =
to avoid getting
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* false positives from get_page_unless_zero(=
) with
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* speculative page access (like in
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* page_cache_get_speculative()) on tail page=
s.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(atomic_read(&page->first_page->_count) <=
=3D 0);
> - =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(atomic_read(&page->_count) !=3D 0);
> - =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(page_mapcount(page) < 0);
> - =C2=A0 =C2=A0 =C2=A0 atomic_inc(&page->first_page->_count);
> - =C2=A0 =C2=A0 =C2=A0 atomic_inc(&page->_mapcount);
> -}
> -
> =C2=A0extern int __get_page_tail(struct page *page);
>
> =C2=A0static inline void get_page(struct page *page)
> diff --git a/mm/internal.h b/mm/internal.h
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -37,6 +37,28 @@ static inline void __put_page(struct pag
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_dec(&page->_count);
> =C2=A0}
>
> +static inline void __get_page_tail_foll(struct page *page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool get_pag=
e_head)
> +{
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we're getting a tail page, the elevated=
 page->_count is
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* required only in the head page and we will=
 elevate the head
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* page->_count and tail page->_mapcount.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We elevate page_tail->_mapcount for tail p=
ages to force
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* page_tail->_count to be zero at all times =
to avoid getting
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* false positives from get_page_unless_zero(=
) with
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* speculative page access (like in
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* page_cache_get_speculative()) on tail page=
s.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(atomic_read(&page->first_page->_count) <=
=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(atomic_read(&page->_count) !=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(page_mapcount(page) < 0);
> + =C2=A0 =C2=A0 =C2=A0 if (get_page_head)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&page->firs=
t_page->_count);
> + =C2=A0 =C2=A0 =C2=A0 atomic_inc(&page->_mapcount);
> +}
> +
> =C2=A0static inline void get_page_foll(struct page *page)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(PageTail(page)))
> @@ -45,7 +67,7 @@ static inline void get_page_foll(struct
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * __split_huge_pa=
ge_refcount() can't run under
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * get_page_foll()=
 because we hold the proper PT lock.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __get_page_tail_foll(p=
age);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __get_page_tail_foll(p=
age, true);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Getting a norma=
l page or the head of a compound page
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -166,16 +166,8 @@ int __get_page_tail(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flags =3D compound=
_lock_irqsave(page_head);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* here __split_hu=
ge_page_refcount won't run anymore */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(PageTai=
l(page))) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __get_page_tail_foll(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __get_page_tail_foll(page, false);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0got =3D 1;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* We can release the refcount taken by
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* get_page_unless_zero() now that
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* __split_huge_page_refcount() is blocked on
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* the compound_lock.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (put_page_testzero(page_head))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compound_unlock_ir=
qrestore(page_head, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!got)=
)
>
>
> =3D=3D=3D
> Subject: thp: tail page refcounting fix
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> Michel while working on the working set estimation code, noticed that cal=
ling
> get_page_unless_zero() on a random pfn_to_page(random_pfn) wasn't safe, i=
f the
> pfn ended up being a tail page of a transparent hugepage under splitting =
by
> __split_huge_page_refcount(). He then found the problem could also
> theoretically materialize with page_cache_get_speculative() during the
> speculative radix tree lookups that uses get_page_unless_zero() in SMP if=
 the
> radix tree page is freed and reallocated and get_user_pages is called on =
it
> before page_cache_get_speculative has a chance to call get_page_unless_ze=
ro().
>
> So the best way to fix the problem is to keep page_tail->_count zero at a=
ll
> times. This will guarantee that get_page_unless_zero() can never succeed =
on any
> tail page. page_tail->_mapcount is guaranteed zero and is unused for all =
tail
> pages of a compound page, so we can simply account the tail page referenc=
es
> there and transfer them to tail_page->_count in __split_huge_page_refcoun=
t() (in
> addition to the head_page->_mapcount).
>
> While debugging this s/_count/_mapcount/ change I also noticed get_page i=
s
> called by direct-io.c on pages returned by get_user_pages. That wasn't en=
tirely
> safe because the two atomic_inc in get_page weren't atomic. As opposed ot=
her
> get_user_page users like secondary-MMU page fault to establish the shadow
> pagetables would never call any superflous get_page after get_user_page
> returns. It's safer to make get_page universally safe for tail pages and =
to use
> get_page_foll() within follow_page (inside get_user_pages()). get_page_fo=
ll()
> is safe to do the refcounting for tail pages without taking any locks bec=
ause
> it is run within PT lock protected critical sections (PT lock for pte and
> page_table_lock for pmd_trans_huge). The standard get_page() as invoked b=
y
> direct-io instead will now take the compound_lock but still only for tail
> pages. The direct-io paths are usually I/O bound and the compound_lock is=
 per
> THP so very finegrined, so there's no risk of scalability issues with it.=
 A
> simple direct-io benchmarks with all lockdep prove locking and spinlock
> debugging infrastructure enabled shows identical performance and no overh=
ead.
> So it's worth it. Ideally direct-io should stop calling get_page() on pag=
es
> returned by get_user_pages(). The spinlock in get_page() is already optim=
ized
> away for no-THP builds but doing get_page() on tail pages returned by GUP=
 is
> generally a rare operation and usually only run in I/O paths.
>
> This new refcounting on page_tail->_mapcount in addition to avoiding new =
RCU
> critical sections will also allow the working set estimation code to work
> without any further complexity associated to the tail page refcounting
> with THP.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Michel Lespinasse <walken@google.com>
> Reviewed-by: Michel Lespinasse <walken@google.com>

There is a just nitpick at below but the code looks more clear than
old and even fixed bug I missed but Michel found.

Thanks!

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> @@ -1156,6 +1156,7 @@ static void __split_huge_page_refcount(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long head_index =3D page->index;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D page_zone(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int zonestat;
> + =C2=A0 =C2=A0 =C2=A0 int tail_count =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* prevent PageLRU to go away from under us, a=
nd freeze lru stats */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&zone->lru_lock);
> @@ -1164,11 +1165,14 @@ static void __split_huge_page_refcount(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 1; i < HPAGE_PMD_NR; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page_=
tail =3D page + i;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* tail_page->_count c=
annot change */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_sub(atomic_read=
(&page_tail->_count), &page->_count);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(page_count(page=
) <=3D 0);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_add(page_mapcou=
nt(page) + 1, &page_tail->_count);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(atomic_read(&pa=
ge_tail->_count) <=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* tail_page->_mapcoun=
t cannot change */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(page_mapcount(p=
age_tail) < 0);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tail_count +=3D page_m=
apcount(page_tail);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* check for overflow =
*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(tail_count < 0)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(atomic_read(&pa=
ge_tail->_count) !=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_add(page_mapcou=
nt(page) + page_mapcount(page_tail) + 1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0&page_tail->_count);

I doubt someone might try to change this with atomic_set for reducing
LOCK_PREFIX overhead in future although it's not fast path. Of course,
we can prevent that patch but can't prevent his wasted time. I hope
there is a comment why we use atomic_add like the errata PPro with
OOStore.





--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
