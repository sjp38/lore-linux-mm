Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B6B506B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 23:52:07 -0500 (EST)
Received: by iwn10 with SMTP id 10so876596iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 20:52:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122141449.9de58a2c.akpm@linux-foundation.org>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122141449.9de58a2c.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 13:52:05 +0900
Message-ID: <AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 7:14 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 21 Nov 2010 23:30:23 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Recently, there are reported problem about thrashing.
>> (http://marc.info/?l=3Drsync&m=3D128885034930933&w=3D2)
>> It happens by backup workloads(ex, nightly rsync).
>> That's because the workload makes just use-once pages
>> and touches pages twice. It promotes the page into
>> active list so that it results in working set page eviction.
>>
>> Some app developer want to support POSIX_FADV_NOREUSE.
>> But other OSes don't support it, either.
>> (http://marc.info/?l=3Dlinux-mm&m=3D128928979512086&w=3D2)
>>
>> By Other approach, app developer uses POSIX_FADV_DONTNEED.
>> But it has a problem. If kernel meets page is writing
>> during invalidate_mapping_pages, it can't work.
>> It is very hard for application programmer to use it.
>> Because they always have to sync data before calling
>> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
>> be discardable. At last, they can't use deferred write of kernel
>> so that they could see performance loss.
>> (http://insights.oetiker.ch/linux/fadvise.html)
>>
>> In fact, invalidate is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head.
>>
>> If it is real working set, it could have a enough time to
>> activate the page since we always try to keep many pages in
>> inactive list.
>>
>> I reuse lru_demote of Peter with some change.
>>
>>
>> ...
>>
>> +/*
>> + * Function used to forecefully demote a page to the head of the inacti=
ve
>> + * list.
>> + */
>
> This comment is wrong? =A0The page gets moved to the _tail_ of the
> inactive list?

No. I add it in _head_ of the inactive list intentionally.
Why I don't add it to _tail_ is that I don't want to be aggressive.
The page might be real working set. So I want to give a chance to
activate it again.
If it's not working set, it can be reclaimed easily and it can prevent
active page demotion since inactive list size would be big enough for
not calling shrink_active_list.

>
>> +void lru_deactive_page(struct page *page)
>
> Should be "deactivate" throughout the patch. IMO.

Thank you.

>
>> +{
>> + =A0 =A0 if (likely(get_page_unless_zero(page))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_deac=
tive_pvecs);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pagevec_add(pvec, page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactive(pvec);
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactive_pvecs);
>> + =A0 =A0 }
>> =A0}
>>
>> +
>> =A0void lru_add_drain(void)
>> =A0{
>> =A0 =A0 =A0 drain_cpu_pagevecs(get_cpu());
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index cd94607..c73fb19 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(struct addres=
s_space *mapping,
>> =A0{
>> =A0 =A0 =A0 struct pagevec pvec;
>> =A0 =A0 =A0 pgoff_t next =3D start;
>> - =A0 =A0 unsigned long ret =3D 0;
>> + =A0 =A0 unsigned long ret;
>> + =A0 =A0 unsigned long count =3D 0;
>> =A0 =A0 =A0 int i;
>>
>> =A0 =A0 =A0 pagevec_init(&pvec, 0);
>> @@ -359,8 +360,10 @@ unsigned long invalidate_mapping_pages(struct addre=
ss_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock_failed)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D invalidate_inode_page=
(page);
>> -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D invalidate_inode_page(=
page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_deactive_p=
age(page);
>
> This is the core part of the patch and it needs a code comment to
> explain the reasons for doing this.
>
> I wonder about the page_mapped() case. =A0We were unable to invalidate
> the page because it was mapped into pagetables. =A0But was it really
> appropriate to deactivate the page in that case?

Yes. My assumption is that if it's real working set, it could be
activated easily during inactive list moving window time.

>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D ret;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next > end)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> Suggested updates:
>
>
> =A0include/linux/swap.h | =A0 =A02 +-
> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 13 ++++++-------
> =A0mm/truncate.c =A0 =A0 =A0 =A0| =A0 =A07 ++++++-
> =A03 files changed, 13 insertions(+), 9 deletions(-)
>
> diff -puN include/linux/swap.h~mm-deactivate-invalidated-pages-fix includ=
e/linux/swap.h
> --- a/include/linux/swap.h~mm-deactivate-invalidated-pages-fix
> +++ a/include/linux/swap.h
> @@ -213,7 +213,7 @@ extern void mark_page_accessed(struct pa
> =A0extern void lru_add_drain(void);
> =A0extern int lru_add_drain_all(void);
> =A0extern void rotate_reclaimable_page(struct page *page);
> -extern void lru_deactive_page(struct page *page);
> +extern void lru_deactivate_page(struct page *page);
> =A0extern void swap_setup(void);
>
> =A0extern void add_page_to_unevictable_list(struct page *page);
> diff -puN mm/swap.c~mm-deactivate-invalidated-pages-fix mm/swap.c
> --- a/mm/swap.c~mm-deactivate-invalidated-pages-fix
> +++ a/mm/swap.c
> @@ -39,7 +39,7 @@ int page_cluster;
>
> =A0static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> =A0static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> -static DEFINE_PER_CPU(struct pagevec, lru_deactive_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>
>
> =A0/*
> @@ -334,23 +334,22 @@ static void drain_cpu_pagevecs(int cpu)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_restore(flags);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 pvec =3D &per_cpu(lru_deactive_pvecs, cpu);
> + =A0 =A0 =A0 pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
> =A0 =A0 =A0 =A0if (pagevec_count(pvec))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__pagevec_lru_deactive(pvec);
> =A0}
>
> =A0/*
> - * Function used to forecefully demote a page to the head of the inactiv=
e
> - * list.
> + * Forecfully demote a page to the tail of the inactive list.
> =A0*/
> -void lru_deactive_page(struct page *page)
> +void lru_deactivate_page(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0if (likely(get_page_unless_zero(page))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_d=
eactive_pvecs);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_d=
eactivate_pvecs);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pagevec_add(pvec, page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__pagevec_lru_deactive(pve=
c);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactive_pvecs);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactivate_pvecs);
> =A0 =A0 =A0 =A0}
> =A0}
>
> diff -puN mm/truncate.c~mm-deactivate-invalidated-pages-fix mm/truncate.c
> --- a/mm/truncate.c~mm-deactivate-invalidated-pages-fix
> +++ a/mm/truncate.c
> @@ -361,8 +361,13 @@ unsigned long invalidate_mapping_pages(s
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D invalidate_inode_p=
age(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page was dirty =
or under writeback we cannot
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidate it now. =A0=
Move it to the tail of the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* inactive LRU so that r=
eclaim will free it promptly.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_deactiv=
e_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_deactiv=
ate_page(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count +=3D ret;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlock_page(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (next > end)
> _
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
