Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F47A6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 03:09:24 -0500 (EST)
Received: by iwn9 with SMTP id 9so700877iwn.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 00:09:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101129074954.GB22803@localhost>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
	<20101129074954.GB22803@localhost>
Date: Mon, 29 Nov 2010 17:09:21 +0900
Message-ID: <AANLkTimVFT8Fsm5b9z3EWP024BiPBHSM7AfUbib9ZHe1@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Wu,

On Mon, Nov 29, 2010 at 4:49 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sun, Nov 28, 2010 at 11:02:55PM +0800, Minchan Kim wrote:
>> This patch is based on mmotm-11-23.
>
> I cannot find __pagevec_lru_deactive() in mmotm-11-23.
> Do you have any more patches?

Please see this patch.
http://www.spinics.net/lists/mm-commits/msg80851.html

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
>> In fact, invalidation is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head.
>>
>> Why I need the page to head, Dirty/Writeback page would be flushed
>> sooner or later. This patch uses trick PG_reclaim so the page would
>> be moved into tail of inactive list when the page writeout completes.
>>
>> It can prevent writeout of pageout which is less effective than
>> flusher's writeout.
>>
>> This patch considers page_mappged(page) with working set.
>> So the page could leave head of inactive to get a change to activate.
>>
>> Originally, I reused lru_demote of Peter with some change so added
>> his Signed-off-by.
>>
>> Note :
>> PG_reclaim trick of writeback page could race with end_page_writeback
>> so this patch check PageWriteback one more. It makes race window time
>> reall small. But by theoretical, it still have a race. But it's a trivia=
l.
>>
>> Quote from fe3cba17 and some modification
>> "If some page PG_reclaim unintentionally, it will confuse readahead and
>> make it restart the size rampup process. But it's a trivial problem, and
>> can mostly be avoided by checking PageWriteback(page) first in readahead=
"
>>
>> PG_reclaim trick of dirty page don't work now since clear_page_dirty_for=
_io
>> always clears PG_reclaim. Next patch will fix it.
>>
>> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>>
>> Changelog since v1:
>> =A0- modify description
>> =A0- correct typo
>> =A0- add some comment
>> =A0- change deactivation policy
>> ---
>> =A0mm/swap.c | =A0 84 +++++++++++++++++++++++++++++++++++++++++++++-----=
----------
>> =A01 files changed, 63 insertions(+), 21 deletions(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 31f5ec4..345eca1 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -268,10 +268,65 @@ void add_page_to_unevictable_list(struct page *pag=
e)
>> =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> =A0}
>>
>> -static void __pagevec_lru_deactive(struct pagevec *pvec)
>> +/*
>> + * This function is used by invalidate_mapping_pages.
>> + * If the page can't be invalidated, this function moves the page
>> + * into inative list's head or tail to reclaim ASAP and evict
>> + * working set page.
>> + *
>> + * PG_reclaim means when the page's writeback completes, the page
>> + * will move into tail of inactive for reclaiming ASAP.
>> + *
>> + * 1. active, mapped page -> inactive, head
>> + * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
>> + * 3. inactive, mapped page -> none
>> + * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
>> + * 5. others -> none
>> + *
>> + * In 4, why it moves inactive's head, the VM expects the page would
>> + * be writeout by flusher. The flusher's writeout is much effective tha=
n
>> + * reclaimer's random writeout.
>> + */
>> +static void __lru_deactivate(struct page *page, struct zone *zone)
>> =A0{
>> - =A0 =A0 int i, lru, file;
>> + =A0 =A0 int lru, file;
>> + =A0 =A0 int active =3D 0;
>> +
>> + =A0 =A0 if (!PageLRU(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 if (PageActive(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 active =3D 1;
>> + =A0 =A0 /* Some processes are using the page */
>> + =A0 =A0 if (page_mapped(page) && !active)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>
> It's good to check such protections if doing heuristic demotion.
> However if requested explicitly by the user, I'm _much more_ inclined
> to act stupid&dumb and meet the user's expectation. Or will this code
> be called by someone other than DONTNEED? Sorry I have no context of
> the full code.

Sorry.

Yes. I expect lru_deactive_page can be used by other places with some
modification.
First thing I expected is here.

http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
After I make sure this patch's effective, I will try it, too.


>
>> + =A0 =A0 else if (PageWriteback(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 SetPageReclaim(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Check race with end_page_writeback */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!PageWriteback(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageReclaim(page);
>
> Does the double check help a lot?
>
>> + =A0 =A0 } else if (PageDirty(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 SetPageReclaim(page);
>
> Typically there are much more dirty pages than writeback pages.
> I guess it's a good place to call bdi_start_inode_writeback() which
> was posted here: http://www.spinics.net/lists/linux-mm/msg10833.html

It looks good to me.
It makes my code very simple.

I can use it. It means my patch depends on yours patch.
Do you have a plan to merge it?


>
> Thanks,
> Fengguang
>
>> +
>> + =A0 =A0 file =3D page_is_file_cache(page);
>> + =A0 =A0 lru =3D page_lru_base_type(page);
>> + =A0 =A0 del_page_from_lru_list(zone, page, lru + active);
>> + =A0 =A0 ClearPageActive(page);
>> + =A0 =A0 ClearPageReferenced(page);
>> + =A0 =A0 add_page_to_lru_list(zone, page, lru);
>> + =A0 =A0 if (active)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_event(PGDEACTIVATE);
>> +
>> + =A0 =A0 update_page_reclaim_stat(zone, page, file, 0);
>> +}
>>
>> +/*
>> + * This function must be called with preemption disable.
>> + */
>> +static void __pagevec_lru_deactivate(struct pagevec *pvec)
>> +{
>> + =A0 =A0 int i;
>> =A0 =A0 =A0 struct zone *zone =3D NULL;
>>
>> =A0 =A0 =A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> @@ -284,21 +339,7 @@ static void __pagevec_lru_deactive(struct pagevec *=
pvec)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone =3D pagezone;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_loc=
k);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (PageLRU(page)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageActive(page)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 file =3D page_=
is_file_cache(page);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru =3D page_l=
ru_base_type(page);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_=
lru_list(zone, page,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 lru + LRU_ACTIVE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageActiv=
e(page);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageRefer=
enced(page);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lr=
u_list(zone, page, lru);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_eve=
nt(PGDEACTIVATE);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 update_page_re=
claim_stat(zone, page, file, 0);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 __lru_deactivate(page, zone);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 if (zone)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> @@ -336,11 +377,13 @@ static void drain_cpu_pagevecs(int cpu)
>>
>> =A0 =A0 =A0 pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
>> =A0 =A0 =A0 if (pagevec_count(pvec))
>> - =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactive(pvec);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactivate(pvec);
>> =A0}
>>
>> =A0/*
>> - * Forecfully demote a page to the tail of the inactive list.
>> + * Forcefully deactivate a page.
>> + * This function is used for reclaiming the page ASAP when the page
>> + * can't be invalidated by Dirty/Writeback.
>> =A0 */
>> =A0void lru_deactivate_page(struct page *page)
>> =A0{
>> @@ -348,12 +391,11 @@ void lru_deactivate_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_de=
activate_pvecs);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pagevec_add(pvec, page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactive(pvec);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactivate(pvec)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactivate_pvecs);
>> =A0 =A0 =A0 }
>> =A0}
>>
>> -
>> =A0void lru_add_drain(void)
>> =A0{
>> =A0 =A0 =A0 drain_cpu_pagevecs(get_cpu());
>> --
>> 1.7.0.4
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
