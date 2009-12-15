Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 25CE76B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 11:59:38 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBFGs4wN003211
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 01:54:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F12D45DE4F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 01:54:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 73B0245DE4D
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 01:54:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B8A41DB8037
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 01:54:04 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 133F91DB8038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 01:54:04 +0900 (JST)
Message-ID: <807687e0c4dabab00176fd75ada5d177.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912150920160.16754@router.home>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
    <20091215181337.1c4f638d.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0912150920160.16754@router.home>
Date: Wed, 16 Dec 2009 01:54:03 +0900 (JST)
Subject: Re: [mmotm][PATCH 2/5] mm : avoid  false sharing on mm_counter
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter さんは書きました：
> On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:
>
>>  #if USE_SPLIT_PTLOCKS
>> +#define SPLIT_RSS_COUNTING
>>  struct mm_rss_stat {
>>  	atomic_long_t count[NR_MM_COUNTERS];
>>  };
>> +/* per-thread cached information, */
>> +struct task_rss_stat {
>> +	int events;	/* for synchronization threshold */
>
> Why count events? Just always increment the task counters and fold them
> at appropriate points into mm_struct.

I used event counter because I think this patch is _easy_ version of all
I've wrote since November. I'd like to start from simple one rather than
some codes which is invasive and can cause complicated discussion.

This event counter is very simple and all we do can be folded under /mm.
To be honest, I'd like to move synchronization point to tick or
schedule(), but for now, I'd like to start from this.
The point of this patch is "spliting" mm_counter counting and remove
false sharing. The problem of synchronization of counter can be
discussed later.

As you know, I have exterme version using percpu etc...but it's not
too late to think of some best counter after removing false sharing
of mmap_sem. When measuring page-fault speed, using more than 4 threads,
most of time is used for false sharing of mmap_sem and this counter's
scalability is not a problem. (So, my test program just use 2 threads.)

Considering trade-off, I'd like to start from "implement all under /mm"
imeplemnation. We can revisit and modify this after mmap_sem problem is
fixed.

If you recommend to drop this and just post 1,3,4,5. I'll do so.

> Or get rid of the mm_struct counters and only sum them up on the fly if
needed?
>
Get rid of mm_struct's counter is impossible because of get_user_pages(),
kswapd, vmscan etc...(now)

Then, we have 3 choices.
  1. leave atomic counter on mm_struct
  2. add pointer to some thread's counter in mm_struct.
  3. use percpu counter on mm_stuct.

With 2. , we'll have to take care of atomicity of updateing per-thread
counter...so, not choiced. With 3, using percpu counter, as you did, seems
attractive. But there are problem scalabilty in read-side and we'll
need some synchonization point for avoid level-down in read-side even
using percpu counter..

Considering memory foot print, the benefit of per-thread counter is
that we can put per-thread counter near to cache-line of task->mm
and we don't have to take care of extra cache-miss.
(if counter size is enough small.)


> Add a pointer to thread rss_stat structure to mm_struct and remove the
> counters? If the task has only one thread then the pointer points to the
> accurate data (most frequent case). Otherwise it can be NULL and then we
> calculate it on the fly?
>
get_user_pages(), vmscan, kvm etc...will touch other process's page table.

>> +static void add_mm_counter_fast(struct mm_struct *mm, int member, int
>> val)
>> +{
>> +	struct task_struct *task = current;
>> +
>> +	if (likely(task->mm == mm))
>> +		task->rss_stat.count[member] += val;
>> +	else
>> +		add_mm_counter(mm, member, val);
>> +}
>> +#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm,
>> member,1)
>> +#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm,
>> member,-1)
>> +
>
> Code will be much simpler if you always increment the task counts.
>
yes, I know and tried but failed. Maybe bigger patch will be required.

The result this patch shows is not very bad even if we have more chances.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
