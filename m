Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F31B6C742BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE83120645
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:39:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE83120645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B928E0145; Fri, 12 Jul 2019 08:39:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54B228E00DB; Fri, 12 Jul 2019 08:39:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 414488E0145; Fri, 12 Jul 2019 08:39:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E569E8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:39:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so7723258eds.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:39:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cnxIR78x6jtHlSwcaVWVvcQJGmS5Gd6Poqs0rtRFFKg=;
        b=KoY0PP5K4KRWqlgyDjNdYcduwdASvhYHlJoemE60f17qyiTTOKVLD9qSea/W2H2Tgw
         ogQLC2T7t+FD9C7XfwcedD93/7279kZcHRwQMUxHBLiJVYGGyFT3Pm+YNVIXr18U+ZEF
         HkcYYgK2FG9l7BF2kT14VK61mleavvLK+NEnCK4SsroAp5vDEztQDtgGU8vRQS6Z0NB3
         ywQ8qMfpvUkfAbMwl9sqI7nJk5Htcm5zFbP8OdlCZzwuYAK/FRQ5V86aKljyk8jd9dMW
         Yy6+6IuFi0qLQEH7RQnkH8H5ercMNBBz6S8+zgbrlCdWciGAt/eISWw8CmYRFaRl+FpY
         S2qQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAULsslHY9KqYcNWFPoow2g7Ldwt2gUkUWKfBHWGx7PcSe0uizve
	M9OeQqgoysTzQw+31tD1V0ekCe7oaJSCnOJJjyXcx7lKBfr9jNVB0WybkdT1erfr/0JcVPKTvhT
	xvf6Bq7JQTCd1UsdiuIdvvmsn2H0m9aGry3zp+hb4NJc0eT3aPIjYha2TBcm/Kctw0w==
X-Received: by 2002:a50:9822:: with SMTP id g31mr8815632edb.175.1562935178497;
        Fri, 12 Jul 2019 05:39:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD1kAtnGXVD4HMuYjIqDb21sNJGqQn2iCWa+Mcb8Hcb04Db8LOE8rSnR2Y12JoknTFCdXc
X-Received: by 2002:a50:9822:: with SMTP id g31mr8815586edb.175.1562935177645;
        Fri, 12 Jul 2019 05:39:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562935177; cv=none;
        d=google.com; s=arc-20160816;
        b=NwMB2f36tOF8UXrFzKPtUYLuE0lNo+6UDjiBQDXOGp4xZcZHDrF02m8Ka1Zr/97uqc
         O0VIy/EGbZCYzfRwjMsUYBBqwLRPmIQS/mV7mcPExpSV2ItpiavMcBex3IOQzy62XpL1
         8LGLvbtZNm+BiPiOkU3/YWiIBjIGBhFcYHf8tqSqL9cDX6LUrmMEqqb4LgVa/GG46481
         ozSR6uxw1bbCf6dFZfhyDl00sRbEaoo0C+gjgH7DczKmvRhJKrZDsLhlAjfurdZt58vX
         BNwKYzjYHlOv1o06WArlPi5arjXufV6rdiOYwinkMyC1zEDJLdwe0wIFkASyUrnTKXOV
         kmKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cnxIR78x6jtHlSwcaVWVvcQJGmS5Gd6Poqs0rtRFFKg=;
        b=fLGGr6UKExdM3OsW92NWB+WXv8Am1P3OY+vMMiifBvOFFGpD1xZ2fJ50QDhEs5aZH+
         x3Kode3UwmMIYI8+159WsQufnEe7EJ3vvgk+8dOioKvUJQ9C8TGvoPka7wEISrRZBvOd
         cbEFowVlHfkRDWUtASwoLM8WHOfwxuEYOwA9+kJlmR1kqbALw66/3SxSAFWJqdKJGQ0v
         1cla20LORrzBmBjth7YEuMfsI8lG+Tk6oE8UeXVC4Du3uUuqcQbRKy1IEFnMFVX3Wjy6
         cnQ2n1ryoa1llSX0WwO96osDQFQB13OMwENpOIvdOwCyd/vRcR285ns1Shqvtr3aGos5
         b3hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si5387442edg.136.2019.07.12.05.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:39:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1C4B5AC3F;
	Fri, 12 Jul 2019 12:39:37 +0000 (UTC)
Date: Fri, 12 Jul 2019 13:39:35 +0100
From: Mel Gorman <mgorman@suse.de>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	mhocko@suse.cz, stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-ID: <20190712123935.GK13484@suse.de>
References: <20190711125838.32565-1-jack@suse.cz>
 <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
 <20190712091746.GB906@quack2.suse.cz>
 <20190712101042.GJ13484@suse.de>
 <20190712112056.GA24009@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190712112056.GA24009@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 01:20:56PM +0200, Jan Kara wrote:
> On Fri 12-07-19 11:10:43, Mel Gorman wrote:
> > On Fri, Jul 12, 2019 at 11:17:46AM +0200, Jan Kara wrote:
> > > On Thu 11-07-19 17:04:55, Andrew Morton wrote:
> > > > On Thu, 11 Jul 2019 14:58:38 +0200 Jan Kara <jack@suse.cz> wrote:
> > > > 
> > > > > buffer_migrate_page_norefs() can race with bh users in a following way:
> > > > > 
> > > > > CPU1					CPU2
> > > > > buffer_migrate_page_norefs()
> > > > >   buffer_migrate_lock_buffers()
> > > > >   checks bh refs
> > > > >   spin_unlock(&mapping->private_lock)
> > > > > 					__find_get_block()
> > > > > 					  spin_lock(&mapping->private_lock)
> > > > > 					  grab bh ref
> > > > > 					  spin_unlock(&mapping->private_lock)
> > > > >   move page				  do bh work
> > > > > 
> > > > > This can result in various issues like lost updates to buffers (i.e.
> > > > > metadata corruption) or use after free issues for the old page.
> > > > > 
> > > > > Closing this race window is relatively difficult. We could hold
> > > > > mapping->private_lock in buffer_migrate_page_norefs() until we are
> > > > > finished with migrating the page but the lock hold times would be rather
> > > > > big. So let's revert to a more careful variant of page migration requiring
> > > > > eviction of buffers on migrated page. This is effectively
> > > > > fallback_migrate_page() that additionally invalidates bh LRUs in case
> > > > > try_to_free_buffers() failed.
> > > > 
> > > > Is this premature optimization?  Holding ->private_lock while messing
> > > > with the buffers would be the standard way of addressing this.  The
> > > > longer hold times *might* be an issue, but we don't know this, do we? 
> > > > If there are indeed such problems then they could be improved by, say,
> > > > doing more of the newpage preparation prior to taking ->private_lock.
> > > 
> > > I didn't check how long the private_lock hold times would actually be, it
> > > just seems there's a lot of work done before the page is fully migrated a
> > > we could release the lock. And since the lock blocks bh lookup,
> > > set_page_dirty(), etc. for the whole device, it just seemed as a bad idea.
> > > I don't think much of a newpage setup can be moved outside of private_lock
> > > - in particular page cache replacement, page copying, page state migration
> > > all need to be there so that bh code doesn't get confused.
> > > 
> > > But I guess it's fair to measure at least ballpark numbers of what the lock
> > > hold times would be to get idea whether the contention concern is
> > > substantiated or not.
> > > 
> > 
> > I think it would be tricky to measure and quantify how much the contention
> > is an issue. While it would be possible to construct a microbenchmark that
> > should illustrate the problem, it would tell us relatively little about
> > how much of a problem it is generally. It would be relatively difficult
> > to detect the contention and stalls in block lookups due to migration
> > would be tricky to spot. Careful use of lock_stat might help but
> > enabling that has consequences of its own.
> > 
> > However, a rise in allocation failures due to dirty pages not being
> > migrated is relatively easy to detect and the consequences are relatively
> > benign -- failed high-order allocation that is usually ok versus a stall
> > on block lookups that could have a wider general impact.
> > 
> > On that basis, I think the patch you proposed is the more appropriate as
> > a fix for the race which has the potential for data corruption. So;
> > 
> > Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Thanks. And I agree with you that detecting failed migrations is generally
> easier than detecting private_lock contention. Anyway, out of curiosity, I
> did run thpfioscale workload in mmtests with some additional metadata
> workload on the system to increase proportion of bdev page cache and added
> tracepoints to see how long the relevant part of __buffer_migrate_page()
> lasts (patch attached). The longest duration of the critical section was
> 311 us which is significant. But that was an outlier by far. The most of
> times critical section lasted couple of us. The full histogram is here:
> 
> [min - 0.000006]: 2907 93.202950%
> (0.000006 - 0.000011]: 105 3.366464%
> (0.000011 - 0.000016]: 36 1.154216%
> (0.000016 - 0.000021]: 45 1.442770%
> (0.000021 - 0.000026]: 13 0.416800%
> (0.000026 - 0.000031]: 4 0.128246%
> (0.000031 - 0.000036]: 2 0.064123%
> (0.000036 - 0.000041]: 2 0.064123%
> (0.000041 - 0.000046]: 1 0.032062%
> (0.000046 - 0.000050]: 1 0.032062%
> (0.000050 - 0.000055]: 0 0.000000%
> (0.000055 - 0.000060]: 0 0.000000%
> (0.000060 - 0.000065]: 0 0.000000%
> (0.000065 - 0.000070]: 0 0.000000%
> (0.000070 - 0.000075]: 2 0.064123%
> (0.000075 - 0.000080]: 0 0.000000%
> (0.000080 - 0.000085]: 0 0.000000%
> (0.000085 - 0.000090]: 0 0.000000%
> (0.000090 - 0.000095]: 0 0.000000%
> (0.000095 - max]: 1 0.032062%
> 
> So although I still think that just failing the migration if we cannot
> invalidate buffer heads is a safer choice, just extending the private_lock
> protected section does not seem as bad as I was afraid.
> 

That does not seem too bad and your revised patch looks functionally
fine. I'd leave out the tracepoints though because a perf probe would have
got roughly the same data and the tracepoint may be too specific to track
another class of problem. Whether the tracepoint survives or not and
with a changelog added;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Andrew, which version do you want to go with, the original version or
this one that holds private_lock for slightly longer during migration?

> From fd584fb6fa6d48e1fae1077d2ab0021ae9c98edf Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Wed, 10 Jul 2019 11:31:01 +0200
> Subject: [PATCH] mm: migrate: Fix race with __find_get_block()
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/trace/events/migrate.h | 42 ++++++++++++++++++++++++++++++++++++++++++
>  mm/migrate.c                   |  8 +++++++-
>  2 files changed, 49 insertions(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
> index 705b33d1e395..15473a508216 100644
> --- a/include/trace/events/migrate.h
> +++ b/include/trace/events/migrate.h
> @@ -70,6 +70,48 @@ TRACE_EVENT(mm_migrate_pages,
>  		__print_symbolic(__entry->mode, MIGRATE_MODE),
>  		__print_symbolic(__entry->reason, MIGRATE_REASON))
>  );
> +
> +TRACE_EVENT(mm_migrate_buffers_begin,
> +
> +	TP_PROTO(struct address_space *mapping, unsigned long index),
> +
> +	TP_ARGS(mapping, index),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long,	mapping)
> +		__field(unsigned long,	index)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mapping	= (unsigned long)mapping;
> +		__entry->index		= index;
> +	),
> +
> +	TP_printk("mapping=%lx index=%lu", __entry->mapping, __entry->index)
> +);
> +
> +TRACE_EVENT(mm_migrate_buffers_end,
> +
> +	TP_PROTO(struct address_space *mapping, unsigned long index, int rc),
> +
> +	TP_ARGS(mapping, index, rc),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long,	mapping)
> +		__field(unsigned long,	index)
> +		__field(int,		rc)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mapping	= (unsigned long)mapping;
> +		__entry->index		= index;
> +		__entry->rc		= rc;
> +	),
> +
> +	TP_printk("mapping=%lx index=%lu rc=%d", __entry->mapping, __entry->index, __entry->rc)
> +);
> +
> +
>  #endif /* _TRACE_MIGRATE_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index e9594bc0d406..bce0f1b03a60 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -763,6 +763,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
>  recheck_buffers:
>  		busy = false;
>  		spin_lock(&mapping->private_lock);
> +		trace_mm_migrate_buffers_begin(mapping, page->index);
>  		bh = head;
>  		do {
>  			if (atomic_read(&bh->b_count)) {
> @@ -771,12 +772,13 @@ static int __buffer_migrate_page(struct address_space *mapping,
>  			}
>  			bh = bh->b_this_page;
>  		} while (bh != head);
> -		spin_unlock(&mapping->private_lock);
>  		if (busy) {
>  			if (invalidated) {
>  				rc = -EAGAIN;
>  				goto unlock_buffers;
>  			}
> +			trace_mm_migrate_buffers_end(mapping, page->index, -EAGAIN);
> +			spin_unlock(&mapping->private_lock);
>  			invalidate_bh_lrus();
>  			invalidated = true;
>  			goto recheck_buffers;
> @@ -809,6 +811,10 @@ static int __buffer_migrate_page(struct address_space *mapping,
>  
>  	rc = MIGRATEPAGE_SUCCESS;
>  unlock_buffers:
> +	if (check_refs) {
> +		trace_mm_migrate_buffers_end(mapping, page->index, rc);
> +		spin_unlock(&mapping->private_lock);
> +	}
>  	bh = head;
>  	do {
>  		unlock_buffer(bh);
> -- 
> 2.16.4
> 


-- 
Mel Gorman
SUSE Labs

