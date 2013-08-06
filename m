Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 127406B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 09:27:56 -0400 (EDT)
Message-ID: <5200F9D9.5090405@suse.cz>
Date: Tue, 06 Aug 2013 15:27:53 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/6] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz> <1375713125-18163-4-git-send-email-vbabka@suse.cz> <20130805172142.GB470@logfs.org>
In-Reply-To: <20130805172142.GB470@logfs.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@logfs.org>
Cc: mgorman@suse.de, linux-mm@kvack.org

On 08/05/2013 07:21 PM, JA?rn Engel wrote:

Hi and thanks for the review!
> On Mon, 5 August 2013 16:32:02 +0200, Vlastimil Babka wrote:
>>  
>>  /*
>> + * Munlock a batch of pages from the same zone
>> + *
>> + * The work is split to two main phases. First phase clears the Mlocked flag
>> + * and attempts to isolate the pages, all under a single zone lru lock.
>> + * The second phase finishes the munlock only for pages where isolation
>> + * succeeded.
>> + */
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
>> +			switch (__isolate_lru_page(page,
>> +						ISOLATE_UNEVICTABLE)) {
>> +			case 0:
>> +				lruvec = mem_cgroup_page_lruvec(page, zone);
>> +				lru = page_lru(page);
>> +				del_page_from_lru_list(page, lruvec, lru);
>> +				break;
>> +
>> +			case -EINVAL:
>> +				__munlock_isolation_failed(page);
>> +				goto skip_munlock;
>> +
>> +			default:
>> +				BUG();
>> +			}
> On purely aesthetic grounds I don't like the switch too much.  A bit
Right, I just saw this function used like this elsewhere so it seemed
like the right thing to do if I was to reuse as much existing code as
possible. But I already got a suggestion that this is too big of a
hammer for this call path where three simple statements are sufficient
instead, and subsequent patches also replace this.
> more serious is that you don't handle -EBUSY gracefully.  I guess you
> would have to mlock() the empty zero page to excercise this code path.
>
>From what I see in the implementation, -EBUSY can only happen with flags
that I don't use, or when get_page_unless_zero() fails. But it cannot
fail since I already have get_page() from follow_page_mask(). (the
function is about zero get_page() pins, not about being zero page).
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
>> +		if (unlikely(!page))
>> +			continue;
> Whenever I see likely() or unlikely() I wonder whether it really makes
> a difference or whether it is just cargo-cult programming.  My best
> guess is that about half of them are cargo-cult.
Yeah that's another thing I saw being used around and seemed to make
sense. But in truth I'm also not sure if contemporary processors gain
anything from it. I will drop it then.
> +			}
> +			if (PageTransHuge(page)) {
> +				/*
> +				 * THP pages are not handled by pagevec due
> +				 * to their possible split (see below).
> +				 */
> +				if (pagevec_count(&pvec))
> +					__munlock_pagevec(&pvec, zone);
> Should you re-initialize the pvec after this call?
__munlock_pagevec() does it as the last thing

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
