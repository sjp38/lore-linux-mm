Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 2C77C6B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 07:14:29 -0400 (EDT)
Message-ID: <5215F272.4080108@suse.cz>
Date: Thu, 22 Aug 2013 13:13:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz> <1376915022-12741-4-git-send-email-vbabka@suse.cz> <20130819153820.8d11f06b688aeb4f0e402afd@linux-foundation.org>
In-Reply-To: <20130819153820.8d11f06b688aeb4f0e402afd@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 08/20/2013 12:38 AM, Andrew Morton wrote:
> On Mon, 19 Aug 2013 14:23:38 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Currently, munlock_vma_range() calls munlock_vma_page on each page in a loop,
>> which results in repeated taking and releasing of the lru_lock spinlock for
>> isolating pages one by one. This patch batches the munlock operations using
>> an on-stack pagevec, so that isolation is done under single lru_lock. For THP
>> pages, the old behavior is preserved as they might be split while putting them
>> into the pagevec. After this patch, a 9% speedup was measured for munlocking
>> a 56GB large memory area with THP disabled.
>>
>> A new function __munlock_pagevec() is introduced that takes a pagevec and:
>> 1) It clears PageMlocked and isolates all pages under lru_lock. Zone page stats
>> can be also updated using the variant which assumes disabled interrupts.
>> 2) It finishes the munlock and lru putback on all pages under their lock_page.
>> Note that previously, lock_page covered also the PageMlocked clearing and page
>> isolation, but it is not needed for those operations.
>>
>> ...
>>
>> +static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>> +{
>> +	int i;
>> +	int nr = pagevec_count(pvec);
>> +
>> +	/* Phase 1: page isolation */
>> +	spin_lock_irq(&zone->lru_lock);
>> +	for (i = 0; i < nr; i++) {
>> +		struct page *page = pvec->pages[i];
>> +
>> +		if (TestClearPageMlocked(page)) {
>> +			struct lruvec *lruvec;
>> +			int lru;
>> +
>> +			/* we have disabled interrupts */
>> +			__mod_zone_page_state(zone, NR_MLOCK, -1);
>> +
>> +			if (PageLRU(page)) {
>> +				lruvec = mem_cgroup_page_lruvec(page, zone);
>> +				lru = page_lru(page);
>> +
>> +				get_page(page);
>> +				ClearPageLRU(page);
>> +				del_page_from_lru_list(page, lruvec, lru);
>> +			} else {
>> +				__munlock_isolation_failed(page);
>> +				goto skip_munlock;
>> +			}
>> +
>> +		} else {
>> +skip_munlock:
>> +			/*
>> +			 * We won't be munlocking this page in the next phase
>> +			 * but we still need to release the follow_page_mask()
>> +			 * pin.
>> +			 */
>> +			pvec->pages[i] = NULL;
>> +			put_page(page);
>> +		}
>> +	}
>> +	spin_unlock_irq(&zone->lru_lock);
>> +
>> +	/* Phase 2: page munlock and putback */
>> +	for (i = 0; i < nr; i++) {
>> +		struct page *page = pvec->pages[i];
>> +
>> +		if (page) {
>> +			lock_page(page);
>> +			__munlock_isolated_page(page);
>> +			unlock_page(page);
>> +			put_page(page); /* pin from follow_page_mask() */
>> +		}
>> +	}
>> +	pagevec_reinit(pvec);
> 
> A minor thing: it would be a little neater if the pagevec_reinit() was
> in the caller, munlock_vma_pages_range().  So the caller remains in
> control of the state of the pagevec and the callee treats it in a
> read-only fashion.


Yeah that's right. Unfortunately the function may also modify the
pagevec by setting a page pointer to NULL. When it fails to isolate the
page, it does that to mark it as excluded from further phases of
processing. I'm not sure that it's worth to allocate an extra array for
such marking just to avoid the modification.

So maybe we could just clarify this in the function's comment?

--------------------->8----------------------------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 22 Aug 2013 11:30:28 +0200
Subject: [PATCH v2 4/9]
 mm-munlock-batch-non-thp-page-isolation-and-munlockputback-using-pagevec-fix

Clarify in __munlock_pagevec() comment that pagegec is modified and
reinited.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index 4a19838..4b3fc72 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -233,6 +233,9 @@ static int __mlock_posix_error_return(long retval)
  * and attempts to isolate the pages, all under a single zone lru lock.
  * The second phase finishes the munlock only for pages where isolation
  * succeeded.
+ *
+ * Note that pvec is modified during the process. Before returning
+ * pagevec_reinit() is called on it.
  */
 static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
-- 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
