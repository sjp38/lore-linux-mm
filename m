Message-ID: <41E5AFE6.6000509@yahoo.com.au>
Date: Thu, 13 Jan 2005 10:16:54 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page table lock patch V15 [0/7]: overview
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>	<Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com>	<m1652ddljp.fsf@muc.de>	<Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>	<41E4BCBE.2010001@yahoo.com.au>	<20050112014235.7095dcf4.akpm@osdl.org>	<Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112104326.69b99298.akpm@osdl.org>
In-Reply-To: <20050112104326.69b99298.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>>>Do we have measurements of the negative and/or positive impact on smaller
>>
>> > machines?
>>
>> Here is a measurement of 256M allocation on a 2 way SMP machine 2x
>> PIII-500Mhz:
>>
>>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>>   0  10    1    0.005s      0.016s   0.002s 54357.280  52261.895
>>   0  10    2    0.008s      0.019s   0.002s 43112.368  42463.566
>>
>> With patch:
>>
>>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>>   0  10    1    0.005s      0.016s   0.002s 54357.280  53439.357
>>   0  10    2    0.008s      0.018s   0.002s 44650.831  44202.412
>>
>> So only a very minor improvements for old machines (this one from ~ 98).
> 
> 
> OK.  But have you written a test to demonstrate any performance
> regressions?  From, say, the use of atomic ops on ptes?
> 

Performance wise, Christoph's never had as much of a problem as my
patches because it isn't doing extra atomic operations in copy_page_range.

However, it looks like it should be. For the same reason there needs to
be an atomic read in handle_mm_fault. And it probably needs atomic ops
in other places too, I think.

So my patches cost about 7% in lmbench fork benchmark... however, I've
been thinking we could take the mmap_sem for writing before doing the
copy_page_range which could reduce the need for atomic ops.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
