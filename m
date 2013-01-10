Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id F1C6D6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 23:26:49 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xn12so143643obc.18
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 20:26:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50EE247B.6090405@jp.fujitsu.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456367-14660-1-git-send-email-handai.szj@taobao.com>
	<20130102104421.GC22160@dhcp22.suse.cz>
	<CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
	<50EA7860.6030300@jp.fujitsu.com>
	<CAFj3OHXMgRG6u2YoM7y5WuPo2ZNA1yPmKRV29FYj9B6Wj_c6Lw@mail.gmail.com>
	<50EE247B.6090405@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 12:26:48 +0800
Message-ID: <CAFj3OHW=n22veXzR27qfc+10t-nETU=B78NULPXrEDT1S-KsOw@mail.gmail.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Thu, Jan 10, 2013 at 10:16 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/01/10 0:02), Sha Zhengju wrote:
>>
>> On Mon, Jan 7, 2013 at 3:25 PM, Kamezawa Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>> (2013/01/05 13:48), Sha Zhengju wrote:
>>>>
>>>>
>>>> On Wed, Jan 2, 2013 at 6:44 PM, Michal Hocko <mhocko@suse.cz> wrote:
>>>>>
>>>>>
>>>>> On Wed 26-12-12 01:26:07, Sha Zhengju wrote:
>>>>>>
>>>>>>
>>>>>> From: Sha Zhengju <handai.szj@taobao.com>
>>>>>>
>>>>>> This patch adds memcg routines to count dirty pages, which allows
>>>>>> memory
>>>>>> controller
>>>>>> to maintain an accurate view of the amount of its dirty memory and can
>>>>>> provide some
>>>>>> info for users while cgroup's direct reclaim is working.
>>>>>
>>>>>
>>>>>
>>>>> I guess you meant targeted resp. (hard/soft) limit reclaim here,
>>>>> right? It is true that this is direct reclaim but it is not clear to me
>>>>
>>>>
>>>>
>>>> Yes, I meant memcg hard/soft reclaim here which is triggered directly
>>>> by allocation and is distinct from background kswapd reclaim (global).
>>>>
>>>>> why the usefulnes should be limitted to the reclaim for users. I would
>>>>> understand this if the users was in fact in-kernel users.
>>>>>
>>>>
>>>> One of the reasons I'm trying to accounting the dirty pages is to get a
>>>> more board overall view of memory usages because memcg hard/soft
>>>> reclaim may have effect on response time of user application.
>>>> Yeah, the beneficiary can be application administrator or kernel users.
>>>> :P
>>>>
>>>>> [...]
>>>>>>
>>>>>>
>>>>>> To prevent AB/BA deadlock mentioned by Greg Thelen in previous version
>>>>>> (https://lkml.org/lkml/2012/7/30/227), we adjust the lock order:
>>>>>> ->private_lock --> mapping->tree_lock --> memcg->move_lock.
>>>>>> So we need to make mapping->tree_lock ahead of TestSetPageDirty in
>>>>>> __set_page_dirty()
>>>>>> and __set_page_dirty_nobuffers(). But in order to avoiding useless
>>>>>> spinlock contention,
>>>>>> a prepare PageDirty() checking is added.
>>>>>
>>>>>
>>>>>
>>>>> But there is another AA deadlock here I believe.
>>>>> page_remove_rmap
>>>>>     mem_cgroup_begin_update_page_stat             <<< 1
>>>>>     set_page_dirty
>>>>>       __set_page_dirty_buffers
>>>>>         __set_page_dirty
>>>>>           mem_cgroup_begin_update_page_stat       <<< 2
>>>>>             move_lock_mem_cgroup
>>>>>               spin_lock_irqsave(&memcg->move_lock, *flags);
>>>>>
>>>>> mem_cgroup_begin_update_page_stat is not recursive wrt. locking AFAICS
>>>>> because we might race with the moving charges:
>>>>>           CPU0                                            CPU1
>>>>> page_remove_rmap
>>>>>                                                   mem_cgroup_can_attach
>>>>>     mem_cgroup_begin_update_page_stat (1)
>>>>>       rcu_read_lock
>>>>>
>>>>> mem_cgroup_start_move
>>>>>
>>>>> atomic_inc(&memcg_moving)
>>>>>
>>>>> atomic_inc(&memcg->moving_account)
>>>>>                                                       synchronize_rcu
>>>>>       __mem_cgroup_begin_update_page_stat
>>>>>         mem_cgroup_stolen <<< TRUE
>>>>>         move_lock_mem_cgroup
>>>>>     [...]
>>>>>           mem_cgroup_begin_update_page_stat (2)
>>>>>             __mem_cgroup_begin_update_page_stat
>>>>>               mem_cgroup_stolen     <<< still TRUE
>>>>>               move_lock_mem_cgroup  <<< DEADLOCK
>>>>>     [...]
>>>>>     mem_cgroup_end_update_page_stat
>>>>>       rcu_unlock
>>>>>                                                     # wake up from
>>>>> synchronize_rcu
>>>>>                                                   [...]
>>>>>                                                   mem_cgroup_move_task
>>>>>
>>>>> mem_cgroup_move_charge
>>>>>                                                       walk_page_range
>>>>>
>>>>> mem_cgroup_move_account
>>>>>
>>>>> move_lock_mem_cgroup
>>>>>
>>>>>
>>>>> Maybe I have missed some other locking which would prevent this from
>>>>> happening but the locking relations are really complicated in this area
>>>>> so if mem_cgroup_{begin,end}_update_page_stat might be called
>>>>> recursively then we need a fat comment which justifies that.
>>>>>
>>>>
>>>> Ohhh...good catching!  I didn't notice there is a recursive call of
>>>> mem_cgroup_{begin,end}_update_page_stat in page_remove_rmap().
>>>> The mem_cgroup_{begin,end}_update_page_stat() design has depressed
>>>> me a lot recently as the lock granularity is a little bigger than I
>>>> thought.
>>>> Not only the resource but also some code logic is in the range of
>>>> locking
>>>> which may be deadlock prone. The problem still exists if we are trying
>>>> to
>>>> add stat account of other memcg page later, may I make bold to suggest
>>>> that we dig into the lock again...
>>>>
>>>> But with regard to the current lock implementation, I doubt if we can we
>>>> can
>>>> account MEM_CGROUP_STAT_FILE_{MAPPED, DIRTY} in one breath and just
>>>> try to get move_lock once in the beginning. IMHO we can make
>>>> mem_cgroup_{begin,end}_update_page_stat() to recursive aware and what
>>>> I'm
>>>> thinking now is changing memcg->move_lock to rw-spinlock from the
>>>> original spinlock:
>>>> mem_cgroup_{begin,end}_update_page_stat() try to get the read lock which
>>>> make it
>>>> reenterable and memcg moving task side try to get the write spinlock.
>>>> Then the race may be following:
>>>>
>>>>           CPU0                                            CPU1
>>>> page_remove_rmap
>>>>                                                   mem_cgroup_can_attach
>>>>     mem_cgroup_begin_update_page_stat (1)
>>>>       rcu_read_lock
>>>>
>>>> mem_cgroup_start_move
>>>>
>>>> atomic_inc(&memcg_moving)
>>>>
>>>> atomic_inc(&memcg->moving_account)
>>>>                                                       synchronize_rcu
>>>>       __mem_cgroup_begin_update_page_stat
>>>>         mem_cgroup_stolen   <<< TRUE
>>>>         move_lock_mem_cgroup   <<<< read-spinlock success
>>>>     [...]
>>>>        mem_cgroup_begin_update_page_stat (2)
>>>>             __mem_cgroup_begin_update_page_stat
>>>>               mem_cgroup_stolen     <<< still TRUE
>>>>               move_lock_mem_cgroup  <<<< read-spinlock success
>>>>
>>>>     [...]
>>>>     mem_cgroup_end_update_page_stat     <<< locked = true, unlock
>>>>       rcu_unlock
>>>>                                                     # wake up from
>>>> synchronize_rcu
>>>>                                                   [...]
>>>>                                                   mem_cgroup_move_task
>>>>
>>>> mem_cgroup_move_charge
>>>>                                                       walk_page_range
>>>>
>>>> mem_cgroup_move_account
>>>>
>>>> move_lock_mem_cgroup    <<< write-spinlock
>>>>
>>>>
>>>> AFAICS, the deadlock seems to be avoided by both the rcu and rwlock.
>>>> Is there anything I lost?
>>>>
>>>
>>> rwlock will work with the nest but it seems ugly do updates under
>>> read-lock.
>>>
>>> How about this straightforward ?
>>> ==
>>> /*
>>>   * Once a thread takes memcg_move_lock() on a memcg, it can take the
>>> lock on
>>>   * the memcg again for nesting calls
>>>   */
>>> static void move_lock_mem_cgroup(memcg, flags);
>>> {
>>>          current->memcg_move_lock_nested += 1;
>>>          if (current->memcg_move_lock_nested > 1) {
>>>                  VM_BUG_ON(current->move_locked_memcg != memcg);
>>>                  return;
>>>          }
>>>          spin_lock_irqsave(&memcg_move_lock, &flags);
>>>          current->move_lockdev_memcg = memcg;
>>> }
>>>
>>> static void move_unlock_mem_cgroup(memcg, flags)
>>> {
>>>          current->memcg_move_lock_nested -= 1;
>>>          if (!current->memcg_move_lock_nested) {
>>>                  current->move_locked_memcg = NULL;
>>>                  spin_unlock_irqrestore(&memcg_move_lock,flags);
>>>          }
>>> }
>>>
>> Does we need to add two
>> fields(current->memcg_move_lock_nested/move_locked_memcg) to 'struct
>> task'? Is it feasible?
>>
>> Now I'm thinking about another synchronization proposal for memcg page
>> stat updater and move_account, which seems to deal with recursion
>> issue and deadlock:
>>
>>               CPU A                                               CPU B
>>
>>    move_lock_mem_cgroup
>>    old_memcg = pc->mem_cgroup
>>    TestSetPageDirty(page)
>>    move_unlock_mem_cgroup
>>
>> move_lock_mem_cgroup
>>                                                           if (PageDirty)
>>
>> old_memcg->nr_dirty --
>>
>> new_memcg->nr_dirty ++
>>
>> pc->mem_cgroup = new_memcgy
>>
>> move_unlock_mem_cgroup
>>
>>    old_memcg->nr_dirty ++
>>
>
> I'm sorry I couldn't catch why you call TestSetPageDirty()....and what
> CPUA/CPUB is
> doing ? CPUA calls move_account() and CPUB updates stat ? If so, why
> move_account()
> is allowed to set PG_dirty ??
>

Sorry,  the layout above seems in a mess and is confusing...
>From the beginning, after removing duplicated information like PCG_*
flags in 'struct page_cgroup'(commit 2ff76f1193), there's a problem
between "move" and "page stat accounting" :
assume CPU-A does "page stat accounting" and CPU-B does "move"

CPU-A                        CPU-B
TestSet PG_dirty
(delay)                 move_lock_mem_cgroup()
                            if (PageDirty(page)) {
                                  old_memcg->nr_dirty --
                                  new_memcg->nr_dirty++
                            }
                            pc->mem_cgroup = new_memcg;
                            move_unlock_mem_cgroup()

move_lock_mem_cgroup()
memcg = pc->mem_cgroup
memcg->nr_dirty++
move_unlock_mem_cgroup()

while accounting information of new_memcg may be double-counted. So we
use a bigger lock to solve this problem:  (commit: 89c06bd52f)
         move_lock_mem_cgroup()
         TestSetPageDirty(page)
         update page stats (without any checks)
         move_unlock_mem_cgroup()

But this method also has its pros and cons(e.g. need lock nesting). So
I doubt whether the following is able to deal with these issues all
together:
(CPU-A does "page stat accounting" and CPU-B does "move")

             CPU-A                            CPU-B

move_lock_mem_cgroup()
memcg = pc->mem_cgroup
SetPageDirty(page)
move_unlock_mem_cgroup()
                                      move_lock_mem_cgroup()
                                      if (PageDirty) {
                                               old_memcg->nr_dirty --;
                                               new_memcg->nr_dirty ++;
                                       }
                                       pc->mem_cgroup = new_memcg
                                       move_unlock_mem_cgroup()

memcg->nr_dirty ++


For CPU-A, we save pc->mem_cgroup in a temporary variable just before
SetPageDirty inside move_lock and then update stats if the page is set
PG_dirty successfully. But CPU-B may do "moving" in advance that
"old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
soon CPU-A will do "memcg->nr_dirty ++" at the heels that amend the
stats.
However, there is a potential problem that old_memcg->nr_dirty  may be
minus in a very short period but not a big issue IMHO.

I hope that is clear.  : )
Thanks!

>
>>
>> So nr_dirty of old_memcg may be minus in a very short
>> period('old_memcg->nr_dirty --' by CPU B), but it will be revised soon
>> by CPU A. And the final figures of memcg->nr_dirty is correct.
>
>
> It seems both of new_memcg and old_memcg has an account for a page. Is it
> correct ?
>
>
>
>> Meanwhile the move_lock only protect saving old_memcg and
>> TestSetPageDirty in its critical section and without any irrelevant
>> logic, so the lock order or deadlock can be handled easily.
>>
>> But I'm not sure whether I've lost some race conditions, any comments
>> are welcomed. : )
>>
>
> Sorry I couldn't understand.
>
> Thanks,
> -Kame
>
>



-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
