Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4B45D6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 19:50:30 -0500 (EST)
Date: Fri, 6 Feb 2009 01:50:22 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090206005022.GA6803@elte.hu>
References: <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org> <Pine.LNX.4.64.0902052046240.18431@blonde.anvils> <498B54A0.7040005@goop.org> <20090205215050.GB28097@elte.hu> <498B6325.1040401@goop.org> <20090205234241.GA14203@elte.hu> <498B7F7F.3090701@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <498B7F7F.3090701@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Ingo Molnar wrote:
>> just the act of using PAE was measured to cause multi-percent slowdown 
>> in fork() and exec() latencies, etc. The pagetables are twice as large 
>> so is that really surprising?
>>   
>
> Is there a similar slowdown running the CPU in 32 vs 64 bit mode?  Or does 
> having more/wider registers mitigate it?

Yes, of course there's a slowdown on 64-bit kernels in fork() performance, 
mainly related to pte size.

Here's some numbers done with perfstat. The "fork" binary forks 256 times, 
waits for the child tasks and then exits. It is a 32-bit binary, statically 
linked - i.e. very similar layout and function on both 32-bit and 64-bit 
kernels.

The results (tabulated a bit, average result of 20 runs):

 $ perfstat -e -3,-4,-5 ./fork

  Performance counter stats for './fork':

        32-bit  32-bit-PAE     64-bit
     ---------  ----------  ---------
     27.367537   30.660090  31.542003  task clock ticks     (msecs)

          5785        5810       5751  pagefaults           (events)
           389         388        388  context switches     (events)
             4           4          4  CPU migrations       (events)
     ---------  ----------  ---------
                    +12.0%     +15.2%  overhead

So PAE is 12.0% slower (the overhead of double the pte size and three page 
table levels), and 64-bit is 15.2% slower (the extra overhead of having four 
page table levels added to the overhead of double the pte size).

Larger ptes do not come for free and the 64-bit instructions do not mitigate 
the cachemiss overhead and memory bandwidth cost.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
