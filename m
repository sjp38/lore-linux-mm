Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R5FdwH025124 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:15:39 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R5FdqA023502 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:15:39 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s5.gw.fujitsu.co.jp (8.12.11)
	id i7R5FdVS005073 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:15:39 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3300JC4AM17D@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 14:15:38 +0900 (JST)
Date: Fri, 27 Aug 2004 14:20:48 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <20040826215927.0af2dee9.akpm@osdl.org>
Message-id: <412EC4B0.1040901@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
 <412EBD22.2090508@jp.fujitsu.com> <20040826215927.0af2dee9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Certainly, executing an atomic op in a tight loop will show a lot of
> difference.  But that doesn't mean that making these operations non-atomic
> makes a significant difference to overall kernel performance!
> 
Thanks.
My test before positng patch is calling mmap()/munmap() with 4-16Mega bytes.
munmap with such Mega bytes causes many calls of __free_pages_bulk() and
many pages are coalesced at once.

This means atomic_ops in heavyly called tight loop
(I called it 3 times in the most inner loop...)

and my test shows bad performance ;).


> But whatever - it all adds up.  The microoptimisation is fine - let's go
> that way.
> 
I'd like to add macros and to get my codes clear.

> 
>>Result:
>>[root@kanex2 atomic]# nice -10 ./test-atomics
>>score 0 is            64011 note: cache hit, no atomic
>>score 1 is           543011 note: cache hit, atomic
>>score 2 is           303901 note: cache hit, mixture
>>score 3 is           344261 note: cache miss, no atomic
>>score 4 is          1131085 note: cache miss, atomic
>>score 5 is           593443 note: cache miss, mixture
>>score 6 is           118455 note: cache hit, dependency, noatomic
>>score 7 is           416195 note: cache hit, dependency, mixture
>>
>>smaller score is better.
>>score 0-2 shows set_bit/__set_bit performance during good cache hit rate.
>>score 3-5 shows set_bit/__set_bit performance during bad cache hit rate.
>>score 6-7 shows set_bit/__set_bit performance during good cache hit
>>but there is data dependency on each access in the tight loop.
> 
> 
> I _think_ the above means atomic ops are 10x more costly, yes?
> 
yes, when L2 cache hits, I think.




-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
