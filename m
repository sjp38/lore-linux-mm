Message-ID: <41C4E6BC.4000002@yahoo.com.au>
Date: Sun, 19 Dec 2004 13:26:04 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au> <20041219002010.GN771@holomorphy.com> <Pine.LNX.4.58.0412181721520.22750@ppc970.osdl.org> <20041219020823.GP771@holomorphy.com>
In-Reply-To: <20041219020823.GP771@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Sat, 18 Dec 2004, William Lee Irwin III wrote:
> 
>>>For clear_page_tables() you want to scan as little as possible. The
>>>exit()-time performance issue is tlb_finish_mmu().
> 
> 
> On Sat, Dec 18, 2004 at 05:31:48PM -0800, Linus Torvalds wrote:
> 
>>Note that the fact that we share lots of code between "unmap" and "exit" 
>>is likely a (performance) bug.
>>The exit case is really a lot simpler, not just because we get rid of the 
>>whole VM, but because nobody else can be reading the page tables at the 
>>same time, and in particular we do not have a lot of the races that a 
>>simple unmap can have. The whole "gather/flush" thing is overkill, I 
>>think.
> 
> 
> For x86-style MMU's you could literally not bother flushing the TLB at
> all, since you'll just switch to another set of pagetables.
> 
> 

I think you're right. At exit-time, I think the flush should just amount
to __flush_tlb() anyway, in which case it is only another cr3 reload, so
it is probably not a big saving?

> On Sat, Dec 18, 2004 at 05:31:48PM -0800, Linus Torvalds wrote:
> 
>>Actually, looking at the code, I wonder why we haven't marked the exit 
>>case to be "fast". We have this special optimization for single-CPU which 
>>doesn't bunch pages up and free them in chunks, and we should probably 
>>mark the exit case to use the fast-case where we can flush the TLB's 
>>early. Hmm?
>>Ingo, is there any reason we don't do this:
>>--- 1.24/include/asm-generic/tlb.h	2004-07-10 17:14:00 -07:00
>>+++ edited/include/asm-generic/tlb.h	2004-12-18 17:30:43 -08:00
>>@@ -58,7 +58,7 @@
>> 	tlb->mm = mm;
>> 
>> 	/* Use fast mode if only one CPU is online */
>>-	tlb->nr = num_online_cpus() > 1 ? 0U : ~0U;
>>+	tlb->nr = num_online_cpus() > 1 && !full_mm_flush ? 0U : ~0U;
>> 
>> 	tlb->fullmm = full_mm_flush;
>> 	tlb->freed = 0;
>>which should make the exit case TLB handling go much faster. Was there 
>>some race in that too? Nobody should be using the VM any more at that 
>>point, so it _should_ be safe, no?
> 
> 
> The stale translations can't be left around for ASID-tagged TLB's, lest
> the next user of the ASID inherit them.
> 

I think they should still be flushed before the ASID is reused though,
right? (not that I know how Linux uses ASID TLBs)

It looks to me like Linus' patch should fly (albiet with my limited
knowledge of !i386 architectures).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
