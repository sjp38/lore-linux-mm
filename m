Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9611F6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 21:49:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 85so55163889ioq.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 18:49:40 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c74si19102365ioe.176.2016.06.01.18.49.38
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 18:49:39 -0700 (PDT)
Date: Thu, 2 Jun 2016 10:50:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
Message-ID: <20160602015059.GA9133@js1304-P5Q-DELUXE>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-3-git-send-email-vbabka@suse.cz>
 <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
 <5731D453.8050104@suse.cz>
 <20160531062057.GA30967@js1304-P5Q-DELUXE>
 <354b700b-0dee-32a8-2ee6-17a78ba299b8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <354b700b-0dee-32a8-2ee6-17a78ba299b8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, May 31, 2016 at 09:59:36AM +0200, Vlastimil Babka wrote:
> On 05/31/2016 08:20 AM, Joonsoo Kim wrote:
> >>>From 68f09f1d4381c7451238b4575557580380d8bf30 Mon Sep 17 00:00:00 2001
> >>From: Vlastimil Babka <vbabka@suse.cz>
> >>Date: Fri, 29 Apr 2016 11:51:17 +0200
> >>Subject: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
> >>
> >>In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> >>so move the initialization above the retry: label. Also make the comment above
> >>the initialization more descriptive.
> >>
> >>The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
> >>which may change due to TIF_MEMDIE being set on the allocating thread. We can
> >>fix this, and make the code simpler and a bit more effective at the same time,
> >>by moving the part that determines ALLOC_NO_WATERMARKS from
> >>gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
> >>mask out ALLOC_NO_WATERMARKS in several places in __alloc_pages_slowpath()
> >>anymore.  The only test for the flag can instead call gfp_pfmemalloc_allowed().
> >
> >Your patch looks correct to me but it makes me wonder something.
> >Why do we need to mask out ALLOC_NO_WATERMARKS in several places? If
> >some requestors have ALLOC_NO_WATERMARKS flag, he will
> >eventually do ALLOC_NO_WATERMARKS allocation in retry loop. I don't
> >understand what's the merit of masking out it.
> 
> I can think of a reason. If e.g. reclaim makes free pages above
> watermark in the 4th zone in the zonelist, we would like the
> subsequent get_page_from_freelist() to succeed in that 4th zone.
> Passing ALLOC_NO_WATERMARKS there would likely succeed in the first
> zone, needlessly below the watermark.

Hmm... it's intent would be like as your guess but I think that it's
not correct. There would be not much disadvantage even if we allocate the
freepage from 1st zone where watermark is unmet, since 1st zone would
be higher zone than 4th zone and who can utilize higher zone can
utilize lower zone. There are many corner case handlings and we can't
be sure that we would eventually do the ALLOC_NO_WATERMARKS allocation
attempt again. And, ALLOC_NO_WATERMARKS means that it is a very
importatn task so we need to make it successful as fast as possible. I
think that allowing ALLOC_NO_WATERMARKS as much as possible is better.

So, IMO, keeping ALLOC_NO_WATERMARKS in alloc_flags and don't mask out it
as much as possible would be a way to go.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
