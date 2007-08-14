Message-ID: <46C1F573.4000403@redhat.com>
Date: Tue, 14 Aug 2007 14:33:23 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: L2 cache alignment and page coloring
References: <46C1F194.8080405@llnl.gov>
In-Reply-To: <46C1F194.8080405@llnl.gov>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keasler@llnl.gov
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Keasler wrote:
> Hi,
> 
> I work in an HPC environment where we run a process with a tight inner 
> loop (entirely contained in the I-cache) to work on large quantities of 
> data.  We've reduced system services to minimize our process getting 
> swapped out.
> 
> I am concerned that using malloc(L2_CACHE_SIZE) in user space is mapping 
> the underlying physical pages such that they do not form a cover of the 
> L2 cache (i.e. several physical pages are aliasing into the same part of 
> the L2 cache).
> 
> Are there any tricks available to force a more cache friendly 
> virtual-to-physical mapping from user space?
> 
> Thanks,
> -Jeff
> 
> PS  Even better if it is likely to work for L3 cache.

There may be easier methods depending on your architecture, but if the memory 
region is contiguous in both virtual and physical memory, it's pretty much 
impossible for any set-associative cache implementation (even L3) to alias it 
inefficiently.  Therefore I suggest using hugepages.  Just make sure that either 
you're using CPUs with lots of hugepage TLB entries, or that you won't be using 
very many of them at once.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
