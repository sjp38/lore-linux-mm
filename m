Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8774A6B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:47:40 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so329636pdi.33
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:47:40 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y4si577879pdn.6.2014.10.17.00.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Oct 2014 00:47:39 -0700 (PDT)
Date: Fri, 17 Oct 2014 09:47:18 +0200
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141017074718.GB5641@esperanza>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
 <1413251163-8517-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413251163-8517-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 13, 2014 at 09:46:01PM -0400, Johannes Weiner wrote:
> Memory is internally accounted in bytes, using spinlock-protected
> 64-bit counters, even though the smallest accounting delta is a page.
> The counter interface is also convoluted and does too many things.
> 
> Introduce a new lockless word-sized page counter API, then change all
> memory accounting over to it.  The translation from and to bytes then
> only happens when interfacing with userspace.
> 
> The removed locking overhead is noticable when scaling beyond the
> per-cpu charge caches - on a 4-socket machine with 144-threads, the
> following test shows the performance differences of 288 memcgs
> concurrently running a page fault benchmark:
> 
> vanilla:
> 
>    18631648.500498      task-clock (msec)         #  140.643 CPUs utilized            ( +-  0.33% )
>          1,380,638      context-switches          #    0.074 K/sec                    ( +-  0.75% )
>             24,390      cpu-migrations            #    0.001 K/sec                    ( +-  8.44% )
>      1,843,305,768      page-faults               #    0.099 M/sec                    ( +-  0.00% )
> 50,134,994,088,218      cycles                    #    2.691 GHz                      ( +-  0.33% )
>    <not supported>      stalled-cycles-frontend
>    <not supported>      stalled-cycles-backend
>  8,049,712,224,651      instructions              #    0.16  insns per cycle          ( +-  0.04% )
>  1,586,970,584,979      branches                  #   85.176 M/sec                    ( +-  0.05% )
>      1,724,989,949      branch-misses             #    0.11% of all branches          ( +-  0.48% )
> 
>      132.474343877 seconds time elapsed                                          ( +-  0.21% )
> 
> lockless:
> 
>    12195979.037525      task-clock (msec)         #  133.480 CPUs utilized            ( +-  0.18% )
>            832,850      context-switches          #    0.068 K/sec                    ( +-  0.54% )
>             15,624      cpu-migrations            #    0.001 K/sec                    ( +- 10.17% )
>      1,843,304,774      page-faults               #    0.151 M/sec                    ( +-  0.00% )
> 32,811,216,801,141      cycles                    #    2.690 GHz                      ( +-  0.18% )
>    <not supported>      stalled-cycles-frontend
>    <not supported>      stalled-cycles-backend
>  9,999,265,091,727      instructions              #    0.30  insns per cycle          ( +-  0.10% )
>  2,076,759,325,203      branches                  #  170.282 M/sec                    ( +-  0.12% )
>      1,656,917,214      branch-misses             #    0.08% of all branches          ( +-  0.55% )
> 
>       91.369330729 seconds time elapsed                                          ( +-  0.45% )
> 
> On top of improved scalability, this also gets rid of the icky long
> long types in the very heart of memcg, which is great for 32 bit and
> also makes the code a lot more readable.
> 
> Notable differences between the old and new API:
> 
> - res_counter_charge() and res_counter_charge_nofail() become
>   page_counter_try_charge() and page_counter_charge() resp. to match
>   the more common kernel naming scheme of try_do()/do()
> 
> - res_counter_uncharge_until() is only ever used to cancel a local
>   counter and never to uncharge bigger segments of a hierarchy, so
>   it's replaced by the simpler page_counter_cancel()
> 
> - res_counter_set_limit() is replaced by page_counter_limit(), which
>   expects its callers to serialize against themselves
> 
> - res_counter_memparse_write_strategy() is replaced by
>   page_counter_limit(), which rounds down to the nearest page size -
>   rather than up.  This is more reasonable for explicitely requested
>   hard upper limits.
> 
> - to keep charging light-weight, page_counter_try_charge() charges
>   speculatively, only to roll back if the result exceeds the limit.
>   Because of this, a failing bigger charge can temporarily lock out
>   smaller charges that would otherwise succeed.  The error is bounded
>   to the difference between the smallest and the biggest possible
>   charge size, so for memcg, this means that a failing THP charge can
>   send base page charges into reclaim upto 2MB (4MB) before the limit
>   would have been reached.  This should be acceptable.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Definitely better than it was.

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
