Message-ID: <46B0C8A3.8090506@mbligh.org>
Date: Wed, 01 Aug 2007 10:53:39 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [rfc] balance-on-fork NUMA placement
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de>
In-Reply-To: <20070801002313.GC31006@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Tue, Jul 31, 2007 at 11:14:08AM +0200, Andi Kleen wrote:
>> On Tuesday 31 July 2007 07:41, Nick Piggin wrote:
>>
>>> I haven't given this idea testing yet, but I just wanted to get some
>>> opinions on it first. NUMA placement still isn't ideal (eg. tasks with
>>> a memory policy will not do any placement, and process migrations of
>>> course will leave the memory behind...), but it does give a bit more
>>> chance for the memory controllers and interconnects to get evenly
>>> loaded.
>> I didn't think slab honored mempolicies by default? 
>> At least you seem to need to set special process flags.
>>
>>> NUMA balance-on-fork code is in a good position to allocate all of a new
>>> process's memory on a chosen node. However, it really only starts
>>> allocating on the correct node after the process starts running.
>>>
>>> task and thread structures, stack, mm_struct, vmas, page tables etc. are
>>> all allocated on the parent's node.
>> The page tables should be only allocated when the process runs; except
>> for the PGD.
> 
> We certainly used to copy all page tables on fork. Not any more, but we
> must still copy anonymous page tables.

This topic seems to come up periodically every since we first introduced
the NUMA scheduler, and every time we decide it's a bad idea. What's
changed? What workloads does this improve (aside from some artificial
benchmark like stream)?

To repeat the conclusions of last time ... the primary problem is that
99% of the time, we exec after we fork, and it makes that fork/exec
cycle slower, not faster, so exec is generally a much better time to do
this. There's no good predictor of whether we'll exec after fork, unless
one has magically appeared since late 2.5.x ?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
