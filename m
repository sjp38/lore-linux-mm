Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A7DE628033A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:50:49 -0400 (EDT)
Received: by padck2 with SMTP id ck2so61024187pad.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:50:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id oc5si18856967pdb.180.2015.07.17.06.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 06:50:48 -0700 (PDT)
Date: Fri, 17 Jul 2015 15:50:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm, meminit: Allow early_pfn_to_nid to be used
 during runtime
Message-ID: <20150717135042.GO19282@twins.programming.kicks-ass.net>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
 <1437135724-20110-4-git-send-email-mgorman@suse.de>
 <20150717131232.GK19282@twins.programming.kicks-ass.net>
 <20150717131729.GE2561@suse.de>
 <20150717132922.GN19282@twins.programming.kicks-ass.net>
 <20150717133913.GF2561@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717133913.GF2561@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 17, 2015 at 02:39:13PM +0100, Mel Gorman wrote:

> I'm don't know and no longer have access to the necessary machine to test
> any more. You make a reasonable point and I would be surprised if it was
> noticable. On the other hand, conditional locking is evil and the patch
> reflected my thinking at the time "we don't need locks during boot". It's
> the type of thinking that should be backed with figures if it was to be
> used at all so lets go with;

Last time I tested it, an uncontended spinlock (cache hot) ran around 20
cycles, the unlock is a regular store (x86) and in single digit cycles.
I doubt modern hardware makes it go slower.

> ---8<---
> mm, meminit: Allow early_pfn_to_nid to be used during runtime v2
> 
> early_pfn_to_nid historically was inherently not SMP safe but only
> used during boot which is inherently single threaded or during hotplug
> which is protected by a giant mutex. With deferred memory initialisation
> there was a thread-safe version introduced and the early_pfn_to_nid
> would trigger a BUG_ON if used unsafely. Memory hotplug hit that check.
> This patch makes early_pfn_to_nid introduces a lock to make it safe to
> use during hotplug.
> 
> Reported-and-tested-by: Alex Ng <alexng@microsoft.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
