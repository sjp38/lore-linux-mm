Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 87B046B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:37:14 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so220473680wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:37:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga19si28246279wic.9.2015.10.14.01.37.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 01:37:13 -0700 (PDT)
Date: Wed, 14 Oct 2015 10:37:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Making per-cpu lists draining dependant on a flag
Message-ID: <20151014083710.GF28333@dhcp22.suse.cz>
References: <56179E4F.5010507@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56179E4F.5010507@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Andrew Morton <akpm@linux-foundation.org>, Marian Marinov <mm@1h.com>, SiteGround Operations <operations@siteground.com>, Jan Kara <jack@suse.cz>

On Fri 09-10-15 14:00:31, Nikolay Borisov wrote:
> Hello mm people,
> 
> 
> I want to ask you the following question which stemmed from analysing
> and chasing this particular deadlock:
> http://permalink.gmane.org/gmane.linux.kernel/2056730

This link doesn't seem to work properly for me. Could you post a
http://lkml.kernel.org/r/$msg_id link please?

> To summarise it:
> 
> For simplicity I will use the following nomenclature:
> t1 - kworker/u96:0
> t2 - kworker/u98:39
> t3 - kworker/u98:7
> 
> t1 issues drain_all_pages which generates IPI's, at the same time
> however,

OK, as per
http://lkml.kernel.org/r/1444318308-27560-1-git-send-email-kernel%40kyup.com
drain_all_pages is called from the __alloc_pages_nodemask called from
slab allocator. There is no stack leading to the allocation but then you
are saying

> t2 has already started doing async write of pages
> as part of its normal operation but is blocked upon t1 completion of
> its IPI (generated from drain_all_pages) since they both work on the
> same dm-thin volume.

which I read as the allocator is holding the same dm_bufio_lock, right?

> At the same time again, t3 is executing
> ext4_finish_bio, which disables interrupts, yet is dependent on t2
> completing its writes.

That would be a bug on its own because ext4_finish_bio seems to be
called from SoftIRQ context so it cannot wait for a regular scheduling
context. Whoever is holding that lock BH_Uptodate_Lock has to be in
(soft)IRQ context.

<found the original thread on linux-mm finally - the threading got
broken on the way>
http://lkml.kernel.org/r/20151013131453.GA1332%40quack.suse.cz

So Jack (CCed) thinks this is a non-atomic update of flags and that
indeed sounds plausible.

> But since it has disabled interrupts, it wont
> respond to t1's IPI and at this point a hard lock up occurs. This
> happens, since drain_all_pages calls on_each_cpu_mask with the last
> argument equal to  "true" meaning "wait until the ipi handler has
> finished", which of course will never happen in the described situation.
> 
> Based on that I was wondering whether avoiding such situation might
> merit making drain_all_pages invocation from
> __alloc_pages_direct_reclaim dependent on a particular GFP being passed
> e.g. GFP_NOPCPDRAIN or something along those lines?

I do not think so. Even if the dependency was real it would be a clear
deadlock even without drain_all_pages AFAICS.

> Alternatively would it be possible to make the IPI asycnrhonous e.g.
> calling on_each_cpu_mask with the last argument equal to false?

Strictly speaking the allocation path doesn't really depend on the sync
behavior. We are just trying to release pages on pcp lists and retry the
allocation. Even if the allocation context was faster than other CPUs
and fail the request then we would try again without triggering the OOM
because the reclaim has apparently made some progress.

Other callers might be more sensitive. Anyway this is called only if the
allocator issues a sleeping allocation request so I think that waiting
here is perfectly acceptable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
