Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 212436B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:38:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nADGc7DH027834
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 14 Nov 2009 01:38:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0AB045DE51
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:38:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69A8345DE4E
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:38:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 53BD5EF8002
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:38:07 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 068C0E78001
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:38:07 +0900 (JST)
Message-ID: <e5b0b419b72e8d6ee6b5a5cc721a24a5.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <28c262360911130820r34d2d2d2jf2ca754447eb9f5@mail.gmail.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
    <28c262360911130820r34d2d2d2jf2ca754447eb9f5@mail.gmail.com>
Date: Sat, 14 Nov 2009 01:38:06 +0900 (JST)
Subject: Re: [RFC MM] speculative page fault
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> On Fri, Nov 13, 2009 at 4:35 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> This is just a toy patch inspied by on Christoph's mmap_sem works.
>> Only for my hobby, now.
>>
>> Not well tested. So please look into only if you have time.
>>
>> My multi-thread page fault test program shows some improvement.
>> But I doubt my test ;) Do you have recommended benchmarks for parallel
>> page-faults ?
>>
>> Counting # of page faults per 60sec. See page-faults. bigger is better.
>> Test on x86-64 8cpus.
>>
>> [Before]
>> &#160;474441.541914 &#160;task-clock-msecs &#160; &#160; &#160; &#160;
# &#160; &#160; &#160;7.906 CPUs
>> &#160; &#160; &#160; &#160; &#160;10318 &#160;context-switches &#160;
&#160; &#160; &#160; # &#160; &#160; &#160;0.000 M/sec
>> &#160; &#160; &#160; &#160; &#160; &#160; 10 &#160;CPU-migrations
&#160; &#160; &#160; &#160; &#160; # &#160; &#160; &#160;0.000 M/sec
>> &#160; &#160; &#160; 15816787 &#160;page-faults &#160; &#160; &#160;
&#160; &#160; &#160; &#160;# &#160; &#160; &#160;0.033 M/sec
>> &#160;1485219138381 &#160;cycles &#160; &#160; &#160; &#160; &#160;
&#160; &#160; &#160; &#160; # &#160; 3130.458 M/sec &#160;(scaled from
69.99%)
>> &#160; 295669524399 &#160;instructions &#160; &#160; &#160; &#160;
&#160; &#160; # &#160; &#160; &#160;0.199 IPC &#160; &#160;(scaled from
79.98%)
>> &#160; &#160;57658291915 &#160;branches &#160; &#160; &#160; &#160;
&#160; &#160; &#160; &#160; # &#160; &#160;121.529 M/sec &#160;(scaled
from 79.98%)
>> &#160; &#160; &#160;798567455 &#160;branch-misses &#160; &#160; &#160;
&#160; &#160; &#160;# &#160; &#160; &#160;1.385 % &#160; &#160;
&#160;(scaled from 79.98%)
>> &#160; &#160; 2458780947 &#160;cache-references &#160; &#160; &#160;
&#160; # &#160; &#160; &#160;5.182 M/sec &#160;(scaled from 20.02%)
>> &#160; &#160; &#160;844605496 &#160;cache-misses &#160; &#160; &#160;
&#160; &#160; &#160; # &#160; &#160; &#160;1.780 M/sec &#160;(scaled
from 20.02%)
>>
>> [After]
>> 471166.582784 &#160;task-clock-msecs &#160; &#160; &#160; &#160; #
&#160; &#160; &#160;7.852 CPUs
>> &#160; &#160; &#160; &#160; &#160;10378 &#160;context-switches &#160;
&#160; &#160; &#160; # &#160; &#160; &#160;0.000 M/sec
>> &#160; &#160; &#160; &#160; &#160; &#160; 10 &#160;CPU-migrations
&#160; &#160; &#160; &#160; &#160; # &#160; &#160; &#160;0.000 M/sec
>> &#160; &#160; &#160; 37950235 &#160;page-faults &#160; &#160; &#160;
&#160; &#160; &#160; &#160;# &#160; &#160; &#160;0.081 M/sec
>> &#160;1463000664470 &#160;cycles &#160; &#160; &#160; &#160; &#160;
&#160; &#160; &#160; &#160; # &#160; 3105.060 M/sec &#160;(scaled from
70.32%)
>> &#160; 346531590054 &#160;instructions &#160; &#160; &#160; &#160;
&#160; &#160; # &#160; &#160; &#160;0.237 IPC &#160; &#160;(scaled from
80.20%)
>> &#160; &#160;63309364882 &#160;branches &#160; &#160; &#160; &#160;
&#160; &#160; &#160; &#160; # &#160; &#160;134.367 M/sec &#160;(scaled
from 80.19%)
>> &#160; &#160; &#160;448256258 &#160;branch-misses &#160; &#160; &#160;
&#160; &#160; &#160;# &#160; &#160; &#160;0.708 % &#160; &#160;
&#160;(scaled from 80.20%)
>> &#160; &#160; 2601112130 &#160;cache-references &#160; &#160; &#160;
&#160; # &#160; &#160; &#160;5.521 M/sec &#160;(scaled from 19.81%)
>> &#160; &#160; &#160;872978619 &#160;cache-misses &#160; &#160; &#160;
&#160; &#160; &#160; # &#160; &#160; &#160;1.853 M/sec &#160;(scaled
from 19.80%)
>>
>
> Looks amazing. page fault is the two times faster than old.
Yes, I amazed and now, doubts my patch or test-program ;)

> What's your test program?
>
This one.
http://marc.info/?l=linux-mm&m=125747798627503&w=2
(I might modify..but not far from this.)

> I think per thread vma cache is effective as well as speculative lock.
>
yes, I hope so.

>> Main concept of this patch is
>> &#160;- Do page fault without taking mm->mmap_sem until some
modification in vma happens.
>> &#160;- All page fault via get_user_pages() should have to take mmap_sem.
>> &#160;- find_vma()/rb_tree must be walked under proper locks. For
avoiding that, use
>> &#160; per-thread cache.
>>
>> It seems I don't have enough time to update this, more.
>> So, I dump patches here just for share.
>
> I think this is good embedded device as well as big thread environment
> like google.
> Some embedded device has big threads. That's because design issue of
> migration from RTOS
> to Linux. Thread model makes system design easier since threads share
> address space like RTOS.
> I know it's bad design. but At a loss, it's real problem.
>
> I support this idea.
> Thanks, Kame.

Thank you for your interests and review.
My cocerns is delaying to free vma might cause some problem (this breaks
some assumptions..,)
I wonder others might have another idea to improve find_vma(), hopefully
in lockless style.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
