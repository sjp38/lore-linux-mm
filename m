Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R5Q2wH030206 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:26:02 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R5Q1ti025222 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:26:01 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102]) by s0.gw.fujitsu.co.jp (8.12.10)
	id i7R5PwKw003041 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:25:58 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I33005XYB38NS@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 14:25:57 +0900 (JST)
Date: Fri, 27 Aug 2004 14:31:07 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <1093583072.2984.463.camel@nighthawk>
Message-id: <412EC71B.4070308@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
 <412EBD22.2090508@jp.fujitsu.com> <1093583072.2984.463.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
>>To Dave:
>>cost of prefetch() is not here, because I found it is very sensitive to
>>what is done in the loop and difficult to measure in this program.
>>I found cost of calling prefetch is a bit high, I'll measure whether
>>prefetch() in buddy allocator is good or bad again.
>>
>>I think this result shows I should use non-atomic ops when I can.
> 
> 
> I think we all know that locked instructions are going to be slower. 
> However, what I wanted to see is how it influences a slightly more
> realistic test, and actually in the context of the kernel.  Let's
> actually see how much impact using the prefetch() and atomic vs
> non-atomic ops has when they're used *in* the kernel on a less
> contrived  less microbenchmarky test.
> 
> How about finding some kind of benchmark that will do a bunch of forking
> and a bunch of page faulting to cause lots of activity in the allocator?
> 
I cannot find suitable one, so I test in microbenchmark calling mmap()
and munmap(). As you say, real-world workload test is more suitable to
measure kernel's performance.

> I'd suggest something like http://ck.kolivas.org/kernbench/ or SDET if
> you can get your hands on it.  Anybody else have some suggestions?
> 
thanks.

> The atomic ops, you're probably right about, but it would still be nice
> to have some hard data.  As for prefetch(), we could scatter it and
> unlikely() all over the kernel, but we only tend to do so when we can
> either demonstrate a concrete gain, or it is a super-hot path.  With
> hot-and-cold-pages around, even the allocator functions don't
> necessarily count as super-hot.  
> 
Hmm, my test program was mmap()/munnamp Magebytes of page and hot_cold_page()
does not work enough, because current batch is16.
My test might be a bit special case.


-- Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
