Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 468806B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:13:24 -0500 (EST)
Received: by iwn9 with SMTP id 9so363075iwn.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 18:13:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101129090514.829C.A69D9226@jp.fujitsu.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
	<20101129090514.829C.A69D9226@jp.fujitsu.com>
Date: Mon, 29 Nov 2010 11:13:22 +0900
Message-ID: <AANLkTikBvHn3Tc_RKTM8tGKjK1kgEZYsBCjXZSZ+Ri+-@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

On Mon, Nov 29, 2010 at 9:33 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
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
>> +
>> + =A0 =A0 else if (PageWriteback(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 SetPageReclaim(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Check race with end_page_writeback */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!PageWriteback(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageReclaim(page);
>> + =A0 =A0 } else if (PageDirty(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 SetPageReclaim(page);
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
>
> I don't like this change because fadvise(DONT_NEED) is rarely used
> function and this PG_reclaim trick doesn't improve so much. In the
> other hand, It increase VM state mess.

Chick-egg problem.
Why fadvise(DONT_NEED) is rarely used is it's hard to use effective.
mincore + fdatasync + fadvise series is very ugly.
This patch's goal is to solve it.

PG_reclaim trick would prevent working set eviction.
If you fadvise call and there are the invalidated page which are
dirtying in middle of inactive LRU,
reclaimer would evict working set of inactive LRU's tail even if we
have a invalidated page in LRU.
It's bad.

About VM state mess, PG_readahead already have done it.
But I admit this patch could make it worse and that's why I Cced Wu Fenggua=
ng.

The problem it can make is readahead confusing and working set
eviction after writeback.
I can add ClearPageReclaim of mark_page_accessed for clear flag if the
page is accessed during race.
But I didn't add it in this version because I think it's very rare case.

I don't want to add new page flag due to this function or revert merge
patch of (PG_readahead and PG_reclaim)


>
> However, I haven't found any fault and unworked reason in this patch.
>
Thanks for the good review, KOSAKI. :)


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
