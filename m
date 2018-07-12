Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 646B46B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 07:13:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f5-v6so16959064plf.18
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:13:54 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0130.outbound.protection.outlook.com. [104.47.1.130])
        by mx.google.com with ESMTPS id x19-v6si20904613pgl.660.2018.07.12.04.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Jul 2018 04:13:52 -0700 (PDT)
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
 <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
 <a9fe3e9e-a1b7-ee19-35e6-af32b5f25a37@virtuozzo.com>
 <CALvZod6eomn1Mt5r28tMthq4b+3MWuWJKgishf_N4UjortzvHw@mail.gmail.com>
 <ed6a04cb-6164-bfab-f2ff-8813068e2e95@virtuozzo.com>
Message-ID: <d1fc50d1-8a64-a118-7040-8ae5606d411d@virtuozzo.com>
Date: Thu, 12 Jul 2018 14:13:41 +0300
MIME-Version: 1.0
In-Reply-To: <ed6a04cb-6164-bfab-f2ff-8813068e2e95@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On 03.07.2018 20:32, Kirill Tkhai wrote:
> On 03.07.2018 20:00, Shakeel Butt wrote:
>> On Tue, Jul 3, 2018 at 9:17 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>>
>>> Hi, Shakeel,
>>>
>>> On 03.07.2018 18:46, Shakeel Butt wrote:
>>>> On Tue, Jul 3, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
>>>>>
>>>>> On Tue, Jul 03, 2018 at 06:09:05PM +0300, Kirill Tkhai wrote:
>>>>>> +++ b/mm/vmscan.c
>>>>>> @@ -169,6 +169,49 @@ unsigned long vm_total_pages;
>>>>>>  static LIST_HEAD(shrinker_list);
>>>>>>  static DECLARE_RWSEM(shrinker_rwsem);
>>>>>>
>>>>>> +#ifdef CONFIG_MEMCG_KMEM
>>>>>> +static DEFINE_IDR(shrinker_idr);
>>>>>> +static int shrinker_nr_max;
>>>>>
>>>>> So ... we've now got a list_head (shrinker_list) which contains all of
>>>>> the shrinkers, plus a shrinker_idr which contains the memcg-aware shrinkers?
>>>>>
>>>>> Why not replace the shrinker_list with the shrinker_idr?  It's only used
>>>>> twice in vmscan.c:
>>>>>
>>>>> void register_shrinker_prepared(struct shrinker *shrinker)
>>>>> {
>>>>>         down_write(&shrinker_rwsem);
>>>>>         list_add_tail(&shrinker->list, &shrinker_list);
>>>>>         up_write(&shrinker_rwsem);
>>>>> }
>>>>>
>>>>>         list_for_each_entry(shrinker, &shrinker_list, list) {
>>>>> ...
>>>>>
>>>>> The first is simply idr_alloc() and the second is
>>>>>
>>>>>         idr_for_each_entry(&shrinker_idr, shrinker, id) {
>>>>>
>>>>> I understand there's a difference between allocating the shrinker's ID and
>>>>> adding it to the list.  You can do this by calling idr_alloc with NULL
>>>>> as the pointer, and then using idr_replace() when you want to add the
>>>>> shrinker to the list.  idr_for_each_entry() skips over NULL entries.
>>>>>
>>>>> This will actually reduce the size of each shrinker and be more
>>>>> cache-efficient when calling the shrinkers.  I think we can also get
>>>>> rid of the shrinker_rwsem eventually, but let's leave it for now.
>>>>
>>>> Can you explain how you envision shrinker_rwsem can be removed? I am
>>>> very much interested in doing that.
>>>
>>> Have you tried to do some games with SRCU? It looks like we just need to
>>> teach count_objects() and scan_objects() to work with semi-destructed
>>> shrinkers. Though, this looks this will make impossible to introduce
>>> shrinkers, which do synchronize_srcu() in scan_objects() for example.
>>> Not sure, someone will actually use this, and this is possible to consider
>>> as limitation.
>>>
>>
>> Hi Kirill, I tried SRCU and the discussion is at
>> https://lore.kernel.org/lkml/20171117173521.GA21692@infradead.org/T/#u
>>
>> Paul E. McKenney suggested to enable SRCU unconditionally. So, to use
>> SRCU for shrinkers, we first have to push unconditional SRCU.
> 
> First time, I read this, I though the talk goes about some new srcu_read_lock()
> without an argument and it's need to rework SRCU in some huge way. Thanks
> god, it was just a misreading :)
>> Tetsuo had another lockless solution which was a bit involved but does
>> not depend on SRCU.
> 
> Ok, I see refcounters suggestion. Thanks for the link, Shakeel!

Just returning to this theme. Since both of the suggested ways contain
srcu synchronization, it may be better just to use percpu-rwsem, since
there is the same functionality out-of-box.

register/unregister_shrinker() will use two rw semaphores:

register_shrinker()
{
	down_write(&shrinker_rwsem);
	idr_alloc();
	up_write(&shrinker_rwsem);
}

unregister_shrinker()
{
	percpu_down_write(&percpu_shrinker_rwsem);
	down_write(&shrinker_rwsem);
	idr_remove();
	up_write(&shrinker_rwsem);
	percpu_up_write(&percpu_shrinker_rwsem);
}

shrink_slab()
{
	percpu_down_read(&percpu_shrinker_rwsem);
	rcu_read_lock();
	shrinker = idr_find();
	rcu_read_unlock();

	do_shrink_slab(shrinker);
	percpu_up_read(&percpu_shrinker_rwsem);
}

1)Here is a trick to make register_shrinker() not use percpu semaphore,
  i.e., not to wait RCU synchronization. This just makes register_shrinker()
  faster. So, we introduce 2 semaphores instead of 1:
  shrinker_rwsem to protect IDR and percpu_shrinker_rwsem.

2)rcu_read_lock() -- to synchronize idr_find() with idr_alloc().
  Not sure, we really need this. It's possible, lockless idr_find()
  is OK in parallel with allocation of new ID. Parallel removing
  is not possible because of percpu rwsem.

3)Places, which are performance critical to unregister_shrinker() speed
  (e.g., like deactivate_locked_super(), as we want umount() to be fast),
  may just call it delayed from work:

diff --git a/fs/super.c b/fs/super.c
index 13647d4fd262..b4a98cb00166 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -324,19 +324,7 @@ void deactivate_locked_super(struct super_block *s)
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
 		cleancache_invalidate_fs(s);
-		unregister_shrinker(&s->s_shrink);
-		fs->kill_sb(s);
-
-		/*
-		 * Since list_lru_destroy() may sleep, we cannot call it from
-		 * put_super(), where we hold the sb_lock. Therefore we destroy
-		 * the lru lists right now.
-		 */
-		list_lru_destroy(&s->s_dentry_lru);
-		list_lru_destroy(&s->s_inode_lru);
-
-		put_filesystem(fs);
-		put_super(s);
+		schedule_delayed_deactivate_super(s)
 	} else {
 		up_write(&s->s_umount);
 	}


Kirill
