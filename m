Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 0946C6B004A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:36:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8E2323EE081
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:36:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C50045DE53
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:36:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5584045DE4D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:36:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 492C7E08005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:36:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED2CDE08002
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:36:21 +0900 (JST)
Message-ID: <4F8E6E84.90608@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:34:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/6] memcg: add PageCgroupReset()
References: <4F72EB84.7080000@jp.fujitsu.com> <4F72EE86.9030005@jp.fujitsu.com> <CALWz4iy-TM_vHCmgZ4e+DEx6WqLJD6QRYut75L4Qz681pOgvkw@mail.gmail.com>
In-Reply-To: <CALWz4iy-TM_vHCmgZ4e+DEx6WqLJD6QRYut75L4Qz681pOgvkw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

(2012/04/18 6:25), Ying Han wrote:

> On Wed, Mar 28, 2012 at 3:57 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>  A commit "memcg: simplify LRU handling by new rule" removes PCG_ACCT_LRU.
>>  and the bug introduced by it was fixed by "memcg: fix GPF when cgroup removal
>>  races with last exit"
>>
>> This was for reducing flags on pc->flags....Now, we have 3bits of flags.
>> but this patch adds a new flag, I'm sorry. (Considering alignment of
>> kmalloc(), we'll able to have 5 bits..)
>>
>> This patch adds PCG_RESET which is similar to PCG_ACCT_LRU.
> 
> 
> 
> This is set
>> when mem_cgroup_add_lru_list() finds we cannot trust the pc's mem_cgroup.
> 
> Do we still need the new flag? I assume some of the upcoming patches
> will provide the guarantee of pc->mem_cgroup.
> 


If per-lruvec locking can do reference-count GC, memcg will never be freed
there are pages which points to the memcg, and allows us to remove
whole this 'move to root' logic, I agree. We'll not require a new flag.

It means that memcg cannot be freed until there are not page(_cgroup) which
points to dead memcg. mem_cgroup_reset_owner() is removed, now.

We need to handle 2 cases.
  - newly allocated pages which linked to memcg before use.
  - unused pages but added to lru by some lazy logic.

And make a guarantee
  - pages added to LRU of dead memcg will be freed or moved to other cgroup, soon.

I have no good idea.

Thanks,
-Kame


> --Ying
>>
>> The reason why this patch adds a (renamed) flag again is for merging
>> pc->flags and pc->mem_cgroup. Assume pc's mem_cgroup is encoded as
>>
>>        mem_cgroup = pc->flags & ~0x7
>>
>> Updating multiple bits of pc->flags without talking lock_page_cgroup()
>> is very dangerous. And mem_cgroup_add_lru_list() updates pc->mem_cgroup
>> without taking lock. Then I add RESET bit. After this, pc_to_mem_cgroup()
>> is written as
>>
>>        if (PageCgroupReset(pc))
>>                return root_mem_cgroup;
>>        return pc->mem_cgroup;
>>
>> This update of Reset bit can be done in atomic by set_bit(). And
>> cleared when USED bit is set.
>>
>> Considering kmalloc()'s alignment, having 4bits of flags will be ok....
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/page_cgroup.h |   15 ++++++++-------
>>  mm/memcontrol.c             |    5 +++--
>>  2 files changed, 11 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>> index 2707809..3f3b4ff 100644
>> --- a/include/linux/page_cgroup.h
>> +++ b/include/linux/page_cgroup.h
>> @@ -8,6 +8,7 @@ enum {
>>        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
>>        PCG_USED, /* this object is in use. */
>>        PCG_MIGRATION, /* under page migration */
>> +       PCG_RESET,     /* have been reset to root_mem_cgroup */
>>        __NR_PCG_FLAGS,
>>  };
>>
>> @@ -70,6 +71,9 @@ SETPCGFLAG(Migration, MIGRATION)
>>  CLEARPCGFLAG(Migration, MIGRATION)
>>  TESTPCGFLAG(Migration, MIGRATION)
>>
>> +TESTPCGFLAG(Reset, RESET)
>> +SETPCGFLAG(Reset, RESET)
>> +
>>  static inline void lock_page_cgroup(struct page_cgroup *pc)
>>  {
>>        /*
>> @@ -84,16 +88,13 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
>>        bit_spin_unlock(PCG_LOCK, &pc->flags);
>>  }
>>
>> +extern struct mem_cgroup*  root_mem_cgroup;
>>
>>  static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
>>  {
>> -       return pc->mem_cgroup;
>> -}
>> -
>> -static inline void
>> -pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
>> -{
>> -       pc->mem_cgroup = memcg;
>> +       if (likely(!PageCgroupReset(pc)))
>> +               return pc->mem_cgroup;
>> +       return root_mem_cgroup;
>>  }
>>
>>  static inline void
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index d366b60..622fd2e 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1080,7 +1080,8 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>>         * of pc's mem_cgroup safe.
>>         */
>>        if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
>> -               pc_set_mem_cgroup(pc, root_mem_cgroup);
>> +               /* this reset bit is cleared when the page is charged */
>> +               SetPageCgroupReset(pc);
>>                memcg = root_mem_cgroup;
>>        }
>>
>> @@ -2626,7 +2627,7 @@ static int mem_cgroup_move_account(struct page *page,
>>                __mem_cgroup_cancel_charge(from, nr_pages);
>>
>>        /* caller should have done css_get */
>> -       pc_set_mem_cgroup(pc, to);
>> +       pc_set_mem_cgroup_and_flags(pc, to, BIT(PCG_USED) | BIT(PCG_LOCK));
>>        mem_cgroup_charge_statistics(to, anon, nr_pages);
>>        /*
>>         * We charges against "to" which may not have any tasks. Then, "to"
>> --
>> 1.7.4.1
>>
>>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
