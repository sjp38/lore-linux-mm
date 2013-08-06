Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1F8236B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 13:53:52 -0400 (EDT)
Date: Tue, 6 Aug 2013 12:21:12 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC PATCH 3/6] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
Message-ID: <20130806162112.GB10535@logfs.org>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
 <1375713125-18163-4-git-send-email-vbabka@suse.cz>
 <20130805172142.GB470@logfs.org>
 <5200F9D9.5090405@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5200F9D9.5090405@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mgorman@suse.de, linux-mm@kvack.org

On Tue, 6 August 2013 15:27:53 +0200, Vlastimil Babka wrote:
> On 08/05/2013 07:21 PM, JA?rn Engel wrote:
> > On Mon, 5 August 2013 16:32:02 +0200, Vlastimil Babka wrote:
> >>  
> >>  /*
> >> + * Munlock a batch of pages from the same zone
> >> + *
> >> + * The work is split to two main phases. First phase clears the Mlocked flag
> >> + * and attempts to isolate the pages, all under a single zone lru lock.
> >> + * The second phase finishes the munlock only for pages where isolation
> >> + * succeeded.
> >> + */
> >> +static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
> >> +{
> >> +	int i;
> >> +	int nr = pagevec_count(pvec);
> >> +
> >> +	/* Phase 1: page isolation */
> >> +	spin_lock_irq(&zone->lru_lock);
> >> +	for (i = 0; i < nr; i++) {
> >> +		struct page *page = pvec->pages[i];
> >> +
> >> +		if (TestClearPageMlocked(page)) {
> >> +			struct lruvec *lruvec;
> >> +			int lru;
> >> +
> >> +			/* we have disabled interrupts */
> >> +			__mod_zone_page_state(zone, NR_MLOCK, -1);
> >> +
> >> +			switch (__isolate_lru_page(page,
> >> +						ISOLATE_UNEVICTABLE)) {
> >> +			case 0:
> >> +				lruvec = mem_cgroup_page_lruvec(page, zone);
> >> +				lru = page_lru(page);
> >> +				del_page_from_lru_list(page, lruvec, lru);
> >> +				break;
> >> +
> >> +			case -EINVAL:
> >> +				__munlock_isolation_failed(page);
> >> +				goto skip_munlock;
> >> +
> >> +			default:
> >> +				BUG();
> >> +			}
> > more serious is that you don't handle -EBUSY gracefully.  I guess you
> > would have to mlock() the empty zero page to excercise this code path.
>
> From what I see in the implementation, -EBUSY can only happen with flags
> that I don't use, or when get_page_unless_zero() fails. But it cannot
> fail since I already have get_page() from follow_page_mask(). (the
> function is about zero get_page() pins, not about being zero page).

You are right.  Not sure if this should be explained in a comment in
the code as well.

> > +			}
> > +			if (PageTransHuge(page)) {
> > +				/*
> > +				 * THP pages are not handled by pagevec due
> > +				 * to their possible split (see below).
> > +				 */
> > +				if (pagevec_count(&pvec))
> > +					__munlock_pagevec(&pvec, zone);
> > Should you re-initialize the pvec after this call?
> __munlock_pagevec() does it as the last thing

Right you are.

JA?rn

--
The key to performance is elegance, not battalions of special cases.
-- Jon Bentley and Doug McIlroy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
