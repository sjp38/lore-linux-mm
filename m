Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 497C36B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 00:08:41 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id 1so43169402ion.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 21:08:41 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id f16si1955871igt.24.2016.01.27.21.08.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 21:08:40 -0800 (PST)
Date: Thu, 28 Jan 2016 14:08:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20160128050844.GD14467@js1304-P5Q-DELUXE>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
 <20151125025735.GC9563@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
 <20151126015252.GA13138@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601271507510.1248@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601271507510.1248@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 27, 2016 at 03:13:12PM -0800, David Rientjes wrote:
> On Thu, 26 Nov 2015, Joonsoo Kim wrote:
> 
> > I understand design decision, but, it is better to get value as much
> > as accurate if there is no performance problem. My patch would not
> > cause much performance degradation because it is just adding one
> > this_cpu_read().
> > 
> > Consider about following example. Current implementation returns
> > interesting output if someone do following things.
> > 
> > v1 = zone_page_state(XXX);
> > mod_zone_page_state(XXX, 1);
> > v2 = zone_page_state(XXX);
> > 
> > v2 would be same with v1 in most of cases even if we already update
> > it.
> > 
> > This situation could occurs in page allocation path and others. If
> > some task try to allocate many pages, then watermark check returns
> > same values until updating vmstat even if some freepage are allocated.
> > There are some adjustments for this imprecision but why not do it become
> > accurate? I think that this change is reasonable trade-off.
> > 
> 
> I'm not sure that NR_ISOLATED_* should be vmstats in the first place.  The 
> most important callers that depend on its accuracy is 
> zone_reclaimable_pages() and the too_many_isolated() loop in both 
> shrink_inactive_list() and memory compaction.  If zlc's are updated every 
> 1s, the HZ/10 in those loops don't really matter, they may as well be 
> HZ/2.
> 
> I think memory compaction updates the counters in the most appropriate 
> way, by incrementing a counter and then finally doing 
> mod_zone_page_state() for the counter.  The other updaters are thp 
> collapse and page migration.
> 
> I discount user-visible vmstats here because the trade-off has already 
> been made that they may be stale for up to 1s and userspace isn't 
> affected.
> 
> So what happens if we simply convert NR_ISOLATED_* into per-zone 
> atomic64_t?

Just a small uncomfortable thing is that calculation is done
with different kinds of metric. For example, comparing vmstat values
(NR_INACTIVE_*, NR_ACTIVE_*) with per-zone atomic NR_ISOLATED_*
looks ugly and error-prone because their accuracy is different.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
