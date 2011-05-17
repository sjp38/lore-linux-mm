Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 910278D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 15:36:04 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4HJZgXj031459
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:35:42 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq6.eem.corp.google.com with ESMTP id p4HJYxRS030581
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:35:34 -0700
Received: by pwj8 with SMTP id 8so547365pwj.13
        for <linux-mm@kvack.org>; Tue, 17 May 2011 12:35:34 -0700 (PDT)
Date: Tue, 17 May 2011 12:35:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
In-Reply-To: <alpine.DEB.2.00.1105171251450.15604@router.home>
Message-ID: <alpine.DEB.2.00.1105171233150.5438@chino.kir.corp.google.com>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com> <20110517084227.GI5279@suse.de> <alpine.DEB.2.00.1105170847550.11187@router.home>
 <20110517162256.GO5279@suse.de> <alpine.DEB.2.00.1105171251450.15604@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 17 May 2011, Christoph Lameter wrote:

> > In this particular patch, the success rate for high order allocations
> > would likely decrease in low memory conditions albeit the latency when
> > calling the page allocator will be lower and the disruption to the
> > system will be less (no copying or reclaim of pages). My expectation
> > would be that it's cheaper for SLUB to fall back than compact memory
> > or reclaim pages even if this means a slab page is smaller until more
> > memory is free. However, if the "goodness" criteria is high order
> > allocation success rate, the patch shouldn't be merged.
> 
> The criteria is certainly overall system performance and not a high order
> allocation rate.
> 

SLUB definitely depends on these higher order allocations being successful 
for performance, dropping back to the min order is a last resort as 
opposed to failing the kmalloc().  If it's the last resort, then it makes 
sense that we'd want to try both compaction and reclaim while we're 
already in the page allocator as we go down the slub slowpath.  Why not 
try just a little harder (compaction and/or reclaim) to alloc the cache's 
preferred order?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
