Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4B76B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:05:47 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so2115844pbc.4
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:05:47 -0700 (PDT)
Date: Thu, 10 Oct 2013 08:05:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131010070429.GG11028@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009110353.GA19370@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131009110353.GA19370@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 09, 2013 at 01:03:54PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > This series has roughly the same goals as previous versions despite the
> > size. It reduces overhead of automatic balancing through scan rate reduction
> > and the avoidance of TLB flushes. It selects a preferred node and moves tasks
> > towards their memory as well as moving memory toward their task. It handles
> > shared pages and groups related tasks together. Some problems such as shared
> > page interleaving and properly dealing with processes that are larger than
> > a node are being deferred. This version should be ready for wider testing
> > in -tip.
> 
> Thanks Mel - the series looks really nice. I've applied the patches to 
> tip:sched/core and will push them out later today if they pass testing 
> here.
> 

Thanks very much!

> > Note that with kernel 3.12-rc3 that numa balancing will fail to boot if 
> > CONFIG_JUMP_LABEL is configured. This is a separate bug that is 
> > currently being dealt with.
> 
> Okay, this is about:
> 
>   https://lkml.org/lkml/2013/9/30/308
> 
> Note that Peter and me saw no crashes so far, and we boot with 
> CONFIG_JUMP_LABEL=y and CONFIG_NUMA_BALANCING=y. It seems like an 
> unrelated bug in any case, perhaps related to specific details in your 
> kernel image?
> 

Possibly or it has been fixed since and I missed it. I'll test latest
tip and see what falls out.

> 2)
> 
> I also noticed a small Kconfig annoyance:
> 
> config NUMA_BALANCING_DEFAULT_ENABLED
>         bool "Automatically enable NUMA aware memory/task placement"
>         default y
>         depends on NUMA_BALANCING
>         help
>           If set, autonumic NUMA balancing will be enabled if running on a NUMA
>           machine.
> 
> config NUMA_BALANCING
>         bool "Memory placement aware NUMA scheduler"
>         depends on ARCH_SUPPORTS_NUMA_BALANCING
>         depends on !ARCH_WANT_NUMA_VARIABLE_LOCALITY
>         depends on SMP && NUMA && MIGRATION
>         help
>           This option adds support for automatic NUM
> 
> the NUMA_BALANCING_DEFAULT_ENABLED option should come after the 
> NUMA_BALANCING entries - things like 'make oldconfig' produce weird output 
> otherwise.
> 

Ok, I did not realise that would be a problem. Thanks for fixing it up
as well as the build errors on UP.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
