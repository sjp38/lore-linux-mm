Message-ID: <441AC3C7.1060900@yahoo.com.au>
Date: Sat, 18 Mar 2006 01:12:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] mm: mmu gather in-place
References: <20060317131354.GA16156@wotan.suse.de>
In-Reply-To: <20060317131354.GA16156@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
> 
> I'm embarrassed to release this patch in such a state, but I am
> because a) I won't have much time to work on it in the short term;
> b) it would take a lot of work to polish so I'd like to see what
> people think before going too far; c) so I have something other than
> boring lockless pagecache to talk about at Ottawa.
> 
> The basic idea is this: replace the heavyweight per-CPU mmu_gather
> structure with a lightweight stack based one which is missing the
> big page vector. Instead of the vector, use Linux pagetables to
> store the pages-to-be-freed. Pages and pagetables are first unmapped,
> then tlbs are flushed, then pages and pagetables are freed.
> 
> There is a downside: walking the page table can be anywhere from
> slightly to a lot less efficient than walking the vector, depending
> on density, and this adds a 2nd pagetable walk to unmapping (but
> removes the vector walk, of course).
> 
> Upsides: mmu_gather is preemptible, horrible mmu_gather breaking
> code can be removed, artificial disparity between PREEMPT tlb
> flush batching and non-PREEMPT disappears (preempt can now have
> good performance and non-preempt can have good latency). tlb flush
> batching is possibly much closer to perfect though on non-PREEMPT
> that may not be noticable (for PREEMPT, it appears to be spending
> 5x less time in tlb flushing on kbuild)
> 
> Caveats:
> - nonlinear mappings don't work yet
> - hugepages don't work yet
> - i386 only

Note that in theory it should be usable by any architecture of course.
Actually those ones for which hardware doesn't natively grok the Linux
page tables can even be more creative than i386...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
