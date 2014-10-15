Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BB8256B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 19:16:28 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so2200930pab.16
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:16:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ud2si17396733pac.18.2014.10.15.16.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 16:16:27 -0700 (PDT)
Date: Wed, 15 Oct 2014 16:16:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: count only dirty pages as congested
Message-Id: <20141015161625.cad6bf6ffc5655fb843c8965@linux-foundation.org>
In-Reply-To: <CAKU+Ga8Onii31qr5OJOrAJt1CPde-0zG703fkxKyJV5ATBkPQQ@mail.gmail.com>
References: <1413403115-1551-1-git-send-email-jamieliu@google.com>
	<20141015130544.380aca0acfcb1413459520b0@linux-foundation.org>
	<CAKU+Ga8Onii31qr5OJOrAJt1CPde-0zG703fkxKyJV5ATBkPQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Liu <jamieliu@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Oct 2014 16:07:42 -0700 Jamie Liu <jamieliu@google.com> wrote:

> On Wed, Oct 15, 2014 at 1:05 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 15 Oct 2014 12:58:35 -0700 Jamie Liu <jamieliu@google.com> wrote:
> >
> >> shrink_page_list() counts all pages with a mapping, including clean
> >> pages, toward nr_congested if they're on a write-congested BDI.
> >> shrink_inactive_list() then sets ZONE_CONGESTED if nr_dirty ==
> >> nr_congested. Fix this apples-to-oranges comparison by only counting
> >> pages for nr_congested if they count for nr_dirty.
> >>
> >> ...
> >>
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -875,7 +875,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >>                * end of the LRU a second time.
> >>                */
> >>               mapping = page_mapping(page);
> >> -             if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
> >> +             if (((dirty || writeback) && mapping &&
> >> +                  bdi_write_congested(mapping->backing_dev_info)) ||
> >>                   (writeback && PageReclaim(page)))
> >>                       nr_congested++;
> >
> > What are the observed runtime effects of this change?
>
> wait_iff_congested() only waits if ZONE_CONGESTED is set (and at least
> one BDI is still congested). Modulo concurrent changes to BDI
> congestion status:
> 
> After this change, the probability that a given shrink_inactive_list()
> sets ZONE_CONGESTED increases monotonically with the fraction of dirty
> pages on the LRU, to 100% if all dirty pages are backed by a
> write-congested BDI. This is in line with what appears to intended,
> judging by the comment:
> 
> /*
> * Tag a zone as congested if all the dirty pages scanned were
> * backed by a congested BDI and wait_iff_congested will stall.
> */
> if (nr_dirty && nr_dirty == nr_congested)
> set_bit(ZONE_CONGESTED, &zone->flags);
> 
> Before this change, the probability that a given
> shrink_inactive_list() sets ZONE_CONGESTED varies erratically. Because
> the ZONE_CONGESTED condition is nr_dirty && nr_dirty == nr_congested,
> the probability peaks when the fraction of dirty pages is equal to the
> fraction of file pages backed by congested BDIs. So under some
> circumstances, an increase in the fraction of dirty pages or in the
> fraction of congested pages can actually result in an *decreased*
> probability that reclaim will stall for writeback congestion, and vice
> versa; which is both counterintuitive and counterproductive.

(top-posting repaired.  Please don't do that!)

OK, I buy all that.  But has any runtime testing been performed to
confirm this and to quantify the effects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
