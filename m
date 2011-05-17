Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 374616B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:23:02 -0400 (EDT)
Date: Tue, 17 May 2011 17:22:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
Message-ID: <20110517162256.GO5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305295404-12129-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com>
 <20110517084227.GI5279@suse.de>
 <alpine.DEB.2.00.1105170847550.11187@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105170847550.11187@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, May 17, 2011 at 08:51:47AM -0500, Christoph Lameter wrote:
> On Tue, 17 May 2011, Mel Gorman wrote:
> 
> > entirely. Christoph wants to maintain historic behaviour of SLUB to
> > maximise the number of high-order pages it uses and at the end of the
> > day, which option performs better depends entirely on the workload
> > and machine configuration.
> 
> That is not what I meant. I would like more higher order allocations to
> succeed. That does not mean that slubs allocation methods and flags passed
> have to stay the same. You can change the slub behavior if it helps.
> 

In this particular patch, the success rate for high order allocations
would likely decrease in low memory conditions albeit the latency when
calling the page allocator will be lower and the disruption to the
system will be less (no copying or reclaim of pages). My expectation
would be that it's cheaper for SLUB to fall back than compact memory
or reclaim pages even if this means a slab page is smaller until more
memory is free. However, if the "goodness" criteria is high order
allocation success rate, the patch shouldn't be merged.

> I am just suspicious of compaction. If these mods are needed to reduce the
> amount of higher order pages then compaction does not have the
> beneficial effect that it should have. It does not actually
> increase the available higher order pages. Fix that first.
> 

The problem being addressed was the machine being hung at worst and in
other cases having kswapd pinned at 99-100% CPU. It's now been shown
that modifying SLUB is not necessary to fix this because the bug was
in page reclaim. The high-order allocation success rate didn't come
into it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
