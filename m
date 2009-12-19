Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 934796B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 01:37:46 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBJ6bhIF026453
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 19 Dec 2009 15:37:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2058145DE50
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:37:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0303045DE4E
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:37:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DD0B91DB803F
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:37:42 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D4811DB8037
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:37:42 +0900 (JST)
Message-ID: <d68104c17771d2a52c59efc6ef8d5bc9.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <4B2C4727.1010302@gmail.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
    <20091216101107.GA15031@basil.fritz.box>
    <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
    <20091216102806.GC15031@basil.fritz.box>
    <28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
    <20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
    <20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
    <20091218094336.cb479a36.kamezawa.hiroyu@jp.fujitsu.com>
    <4B2C4727.1010302@gmail.com>
Date: Sat, 19 Dec 2009 15:37:41 +0900 (JST)
Subject: Re: [RFC 2/4] add mm event counter
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Minchan Kim
> Hi, Kame.
>
Hi,

> KAMEZAWA Hiroyuki wrote:
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Add version counter to mm_struct. It's updated when
>> write_lock is held and released. And this patch also adds
>> task->mm_version. By this, mm_semaphore can provides some
>> operation like seqlock.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/mm_types.h |    1 +
>>  include/linux/sched.h    |    2 +-
>>  mm/mm_accessor.c         |   29 ++++++++++++++++++++++++++---
>>  3 files changed, 28 insertions(+), 4 deletions(-)
>>
>> Index: mmotm-mm-accessor/include/linux/mm_types.h
>> ===================================================================
>> --- mmotm-mm-accessor.orig/include/linux/mm_types.h
>> +++ mmotm-mm-accessor/include/linux/mm_types.h
>> @@ -216,6 +216,7 @@ struct mm_struct {
>>  	atomic_t mm_count;			/* How many references to "struct mm_struct"
>> (users count as 1) */
>>  	int map_count;				/* number of VMAs */
>>  	struct rw_semaphore mmap_sem;
>
> How about ?
>
> struct map_sem {
> 	struct rw_semaphore;
> #ifdef CONFIG_PER_THREAD_VMACACHE
> 	int version;
> #endif
> };
>
> struct mm_struct {
> 	...
> 	struct map_sem mmap_sem
> 	...
> };
>
> void mm_read_lock(struct mem_sem *mmap_sem)
> {
> 	down_read(mmap_sem);
> #ifdef CONFIG_PER_THREAD_VMACACHE
> 	if (current->mm_version != mmap_sem->version)
> 		current->mm_version = mmap_sem->version;
> #endif
> }
>
> We know many place(ex, page fault patch) are matched (current->mm == mm).
> Let's compare it just case of get_user_pages and few cases before calling
> mm_xxx_lock.
>
Yes, your idea is reasonable.

> Why I suggest above is that i don't want regression about single thread
> app.
> (Of course. you use the cache hit well but we can't ignore compare and
> one cache line invalidation by store).
>
> If we can configure CONFIG_PER_THREAD_VMACACHE, we can prevent it.
>
Sure.

> As a matter of fact, I want to control speculative page fault and older in
> runtime.
> For example, if any process starts to have many threads, VM turns on
> speculative about
> the process. But It's not easy to determine the threshold
> (ex, the number of thread >> NR_CPU  .
>
> I think mm_accessor patch is valuable as above.
>
> 1. It doesn't hide lock instance.
> 2. It can be configurable.
> 3. code is more simple.
>
> If you can do it well without mm_accessor, I don't mind it.
>
> I think this is a good start point.
>
ok. As an additional information, I tried some benchmarks as
kernel make, sysbench, java grande, .... etc. But no difference
before after patches. So, this patch's effect is very limited to
some special application's special case.
Then, I'd like to start from CONFIG_SPECULATIVE_PAGE_FAULT.
And I should add CONFIG_SPLIT_PTLOCK rather than #define USE_SPLIT_PTLOCK
for making configurable.


>> +	int version;
>>  	spinlock_t page_table_lock;		/* Protects page tables and some counters
>> */
>>
>>  	struct list_head mmlist;		/* List of maybe swapped mm's.	These are
>> globally strung

>>  void mm_write_unlock(struct mm_struct *mm)
>>  {
>> +	mm->version++;
>>  	up_write(&mm->mmap_sem);
>
> Don't we need to increase version in unlock case?
>
This is for quick check. As seq_lock, the reader can know mm is
write-locked by checking
   mm->versio & 0x1.
In this patch, current->mm_version is always even number.
(But this attribute is not used in later patch ;)



>>  }
>>  EXPORT_SYMBOL(mm_write_unlock);
>>
>>  int mm_write_trylock(struct mm_struct *mm)
>>  {
>> -	return down_write_trylock(&mm->mmap_sem);
>> +	int ret = down_write_trylock(&mm->mmap_sem);
>> +
>> +	if (ret)
>> +		mm->version++;
>> +	return ret;
>>  }
>>  EXPORT_SYMBOL(mm_write_trylock);
>>
>> @@ -45,6 +56,7 @@ EXPORT_SYMBOL(mm_is_locked);
>>
>>  void mm_write_to_read_lock(struct mm_struct *mm)
>>  {
>> +	mm->version++;
>>  	downgrade_write(&mm->mmap_sem);
>>  }
>>  EXPORT_SYMBOL(mm_write_to_read_lock);
>> @@ -78,3 +90,14 @@ void mm_read_might_lock(struct mm_struct
>>  	might_lock_read(&mm->mmap_sem);
>>  }
>>  EXPORT_SYMBOL(mm_read_might_lock);
>> +
>> +/*
>> + * Called when mm is accessed without read-lock or for chekcing
> 							  ^^^^^^^^
> 							  checking :)
yes.

>> + * per-thread cached value is stale or not.
>> + */
>> +int mm_version_check(struct mm_struct *mm)
> Nitpick:
>
> How about "int vma_cache_stale(struct mm_struct *mm)"?
>
>> +{
>> +	if ((current->mm == mm) && (current->mm_version != mm->version))
>> +		return 0;
>> +	return 1;
>> +}
>>
>
yes, if the usage is limited to vma_cache.

I'd like to add vma->vma_version instead of mm->version for avoiding
mm_accessor. Maybe I can do it...Anyway, thank you for good inputs.

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
