Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 40D0B6B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 09:12:59 -0400 (EDT)
Date: Mon, 13 May 2013 15:12:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 3/3] memcg: simplify lock of memcg page stat account
Message-ID: <20130513131251.GB5246@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <1368421545-4974-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368421545-4974-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Mon 13-05-13 13:05:44, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> After removing duplicated information like PCG_* flags in
> 'struct page_cgroup'(commit 2ff76f1193), there's a problem between
> "move" and "page stat accounting"(only FILE_MAPPED is supported now
> but other stats will be added in future, and here I'd like to take
> dirty page as an example):
> 
> Assume CPU-A does "page stat accounting" and CPU-B does "move"
> 
> CPU-A                        CPU-B
> TestSet PG_dirty
> (delay)              	move_lock_mem_cgroup()
>                         if (PageDirty(page)) {
>                              old_memcg->nr_dirty --
>                              new_memcg->nr_dirty++
>                         }
>                         pc->mem_cgroup = new_memcg;
>                         move_unlock_mem_cgroup()
> 
> move_lock_mem_cgroup()
> memcg = pc->mem_cgroup
> memcg->nr_dirty++
> move_unlock_mem_cgroup()
> 
> while accounting information of new_memcg may be double-counted. So we
> use a bigger lock to solve this problem:  (commit: 89c06bd52f)
> 
>       move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
>       TestSetPageDirty(page)
>       update page stats (without any checks)
>       move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
> 
> 
> But this method also has its pros and cons: at present we use two layers
> of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
> on memcg (see mem_cgroup_begin_update_page_stat()), but the lock
> granularity is a little bigger that not only the critical section but
> also some code logic is in the range of locking which may be deadlock
> prone. While trying to add memcg dirty page accounting, it gets into
> further difficulty with page cache radix-tree lock and even worse
> mem_cgroup_begin_update_page_stat() requires nesting
> (https://lkml.org/lkml/2013/1/2/48). However, when the current patch is
> preparing, the lock nesting problem is longer possible as s390/mm has
> reworked it out(commit:abf09bed), but it should be better
> if we can make the lock simpler and recursive safe.

This patch doesn't make the charge move locking recursive safe. It
just tries to overcome the problem in the path where it doesn't exist
anymore. mem_cgroup_begin_update_page_stat would still deadlock if it
was re-entered.

It makes PageCgroupUsed usage even more tricky because it uses it out of
lock_page_cgroup context. It seems that this would work in this
particular path because atomic_inc_and_test(_mapcount) will protect from
double accounting but the whole dance around old_memcg seems pointless
to me.

I am sorry but I do not think this is the right approach. IMO we should
focus on mem_cgroup_begin_update_page_stat and make it really recursive
safe - ideally without any additional overhead (which sounds like a real
challenge)

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
