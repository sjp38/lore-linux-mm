Date: Mon, 21 Oct 2002 08:21:50 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <2577017645.1035188509@[10.10.2.3]>
In-Reply-To: <m1bs5nvo2r.fsf@frodo.biederman.org>
References: <m1bs5nvo2r.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> >> For reference, one of the tests was TPC-H.  My code reduced the number of
>> >> allocated pte_chains from 5 million to 50 thousand.
>> > 
>> > Don't tease, what did that do for performance? I see that someone has
>> > already posted a possible problem, and the code would pass for complex for
>> > most people, so is the gain worth the pain?
>> 
>> In many cases, this will stop the box from falling over flat on it's 
>> face due to ZONE_NORMAL exhaustion (from pte-chains), or even total
>> RAM exhaustion (from PTEs). Thus the performance gain is infinite ;-)
> 
> So why has no one written a pte_chain reaper?  It is perfectly sane
> to allocate a swap entry and move an entire pte_chain to the swap
> cache.  

I think the underlying subsystem does not easily allow for dynamic regeneration, so it's non-trivial. wli was looking at doing pagetable reclaim at some point, IIRC.

IMHO, it's better not to fill memory with crap in the first place than
to invent complex methods of managing and shrinking it afterwards. You
only get into pathalogical conditions under sharing situation, else 
it's limited to about 1% of RAM (bad, but manageable) ... thus providing
this sort of sharing nixes the worst of it. Better cache warmth on 
switches (for TLB misses), faster fork+exec, etc. are nice side-effects.

The ultimate solution is per-object reverse mappings, rather than per
page, but that's a 2.7 thingy now.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
