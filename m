Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id E94CB6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 02:19:45 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id f11so140149171igo.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 23:19:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e138si12578111ite.59.2016.05.30.23.19.44
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 23:19:45 -0700 (PDT)
Date: Tue, 31 May 2016 15:20:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
Message-ID: <20160531062057.GA30967@js1304-P5Q-DELUXE>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-3-git-send-email-vbabka@suse.cz>
 <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
 <5731D453.8050104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5731D453.8050104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, May 10, 2016 at 02:30:11PM +0200, Vlastimil Babka wrote:
> On 05/10/2016 01:28 PM, Tetsuo Handa wrote:
> > Vlastimil Babka wrote:
> >> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> >> so move the initialization above the retry: label. Also make the comment above
> >> the initialization more descriptive.
> > 
> > Not true. gfp_to_alloc_flags() will include ALLOC_NO_WATERMARKS if current
> > thread got TIF_MEMDIE after gfp_to_alloc_flags() was called for the first
> 
> Oh, right. Stupid global state.
> 
> > time. Do you want to make TIF_MEMDIE threads fail their allocations without
> > using memory reserves?
> 
> No, thanks for catching this. How about the following version? I think
> that's even nicer cleanup, if correct. Note it causes a conflict in
> patch 03/13 but it's simple to resolve.
> 
> Thanks
> 
> ----8<----
> >From 68f09f1d4381c7451238b4575557580380d8bf30 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 29 Apr 2016 11:51:17 +0200
> Subject: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
> 
> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> so move the initialization above the retry: label. Also make the comment above
> the initialization more descriptive.
> 
> The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
> which may change due to TIF_MEMDIE being set on the allocating thread. We can
> fix this, and make the code simpler and a bit more effective at the same time,
> by moving the part that determines ALLOC_NO_WATERMARKS from
> gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
> mask out ALLOC_NO_WATERMARKS in several places in __alloc_pages_slowpath()
> anymore.  The only test for the flag can instead call gfp_pfmemalloc_allowed().

Your patch looks correct to me but it makes me wonder something.
Why do we need to mask out ALLOC_NO_WATERMARKS in several places? If
some requestors have ALLOC_NO_WATERMARKS flag, he will
eventually do ALLOC_NO_WATERMARKS allocation in retry loop. I don't
understand what's the merit of masking out it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
