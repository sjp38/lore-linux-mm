Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 809FD828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 03:10:58 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id e32so414242564qgf.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 00:10:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n130si12055584qhc.118.2016.01.15.00.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 00:10:57 -0800 (PST)
Date: Fri, 15 Jan 2016 09:10:51 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Message-ID: <20160115091051.03715530@redhat.com>
In-Reply-To: <yq14meiye92.fsf@sermon.lab.mkp.net>
References: <yq14meiye92.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Martin K. Petersen" <martin.petersen@oracle.com>, lsf-pc@lists.linux-foundation.org
Cc: brouer@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>


On Tue, 12 Jan 2016 11:05:45 -0500 "Martin K. Petersen" <martin.petersen@oracle.com> wrote:

> The annual Linux Storage, Filesystem and Memory Management Summit for
> 2016 will be held on April 18th and 19th at the Raleigh Marriott City
> center, Raleigh, NC.
> 
[...]
> 
> 2) Requests to attend the summit should be sent to:
> 
> 	lsf-pc@lists.linux-foundation.org
> 
> Please summarise what expertise you will bring to the meeting, and what
> you would like to discuss. Please also tag your email with [LSF/MM
> ATTEND] so there is less chance of it getting lost.

Hi committee,

I would like to participate in LSF/MM.  

I've over the last year optimized the SLAB+SLUB allocators,
specifically by introducing a bulking API.  This work is almost
complete, but I have some more ideas in the MM-area that I would like
to discuss with people.

Specifically I have the following ideas:

1. Speedup *SLUB* with approx 10-20% by using per CPU detached
   freelists for all types of allocations/free.
 * Actually have a prove-of-concept implementation that showed 20% speedup
 * Idea is every page (used-by SLUB) gets a detached freelist
 * The first CPU that alloc the page, owns this detached freelist
 * CPU owning page can do sync free operation on this freelist.
 * SLUB is already highly biased to keep objects on same CPU

2. Bulk alloc without disabling IRQ (SLUB)
 * This is something Real-Time (RT) people will be screaming for,
   once more users of bulk API starts to appear.
 * I think it is doable, but also very challenging to keep performance

3. Faster memset clearing of memory in SLUB
 * Currently netstack clears SKBs right after alloc (2-3% in perf)
 * In SLUB allocator we could clear larger section of memory
   which is significantly faster.
 * Bulk alloc would be the right spot
 * Difficult part is inventing an algorithm for matching contiguous mem,
   which is fast-enough, as the est. time budget is 15-20 cycles.

4. Bulk free from RCU context
 * One major slowdown of using RCU free is, that free will always hit
   SLUB slowpath.  We could change this via bulk free API.
 * This would be a major benefit for the entire kernel performance.
 * The challenge here is getting to know the RCU free code well-enough

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
