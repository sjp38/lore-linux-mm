Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 55A7B828E2
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 18:13:15 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so12079471pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:13:15 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id u14si12311529pfa.221.2016.01.27.15.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 15:13:14 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id uo6so12349628pac.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:13:14 -0800 (PST)
Date: Wed, 27 Jan 2016 15:13:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
In-Reply-To: <20151126015252.GA13138@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1601271507510.1248@chino.kir.corp.google.com>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org> <20151125025735.GC9563@js1304-P5Q-DELUXE> <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
 <20151126015252.GA13138@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 26 Nov 2015, Joonsoo Kim wrote:

> I understand design decision, but, it is better to get value as much
> as accurate if there is no performance problem. My patch would not
> cause much performance degradation because it is just adding one
> this_cpu_read().
> 
> Consider about following example. Current implementation returns
> interesting output if someone do following things.
> 
> v1 = zone_page_state(XXX);
> mod_zone_page_state(XXX, 1);
> v2 = zone_page_state(XXX);
> 
> v2 would be same with v1 in most of cases even if we already update
> it.
> 
> This situation could occurs in page allocation path and others. If
> some task try to allocate many pages, then watermark check returns
> same values until updating vmstat even if some freepage are allocated.
> There are some adjustments for this imprecision but why not do it become
> accurate? I think that this change is reasonable trade-off.
> 

I'm not sure that NR_ISOLATED_* should be vmstats in the first place.  The 
most important callers that depend on its accuracy is 
zone_reclaimable_pages() and the too_many_isolated() loop in both 
shrink_inactive_list() and memory compaction.  If zlc's are updated every 
1s, the HZ/10 in those loops don't really matter, they may as well be 
HZ/2.

I think memory compaction updates the counters in the most appropriate 
way, by incrementing a counter and then finally doing 
mod_zone_page_state() for the counter.  The other updaters are thp 
collapse and page migration.

I discount user-visible vmstats here because the trade-off has already 
been made that they may be stale for up to 1s and userspace isn't 
affected.

So what happens if we simply convert NR_ISOLATED_* into per-zone 
atomic64_t?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
