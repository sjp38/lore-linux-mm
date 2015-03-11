Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6AF900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:25:30 -0400 (EDT)
Received: by lbvp9 with SMTP id p9so10048756lbv.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 09:25:29 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id b7si2695072lbk.31.2015.03.11.09.25.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 09:25:28 -0700 (PDT)
Message-ID: <55006C75.2050604@yandex-team.ru>
Date: Wed, 11 Mar 2015 19:25:25 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: add per cgroup dirty page accounting
References: <1425876632-6681-1-git-send-email-gthelen@google.com>
In-Reply-To: <1425876632-6681-1-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Sha Zhengju <handai.szj@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 09.03.2015 07:50, Greg Thelen wrote:> When modifying PG_Dirty on 
cached file pages, update the new
 > MEM_CGROUP_STAT_DIRTY counter.  This is done in the same places where
 > global NR_FILE_DIRTY is managed.  The new memcg stat is visible in the
 > per memcg memory.stat cgroupfs file.  The most recent past attempt at
 > this was http://thread.gmane.org/gmane.linux.kernel.cgroups/8632
 >
 > The new accounting supports future efforts to add per cgroup dirty
 > page throttling and writeback.  It also helps an administrator break
 > down a container's memory usage and provides evidence to understand
 > memcg oom kills (the new dirty count is included in memcg oom kill
 > messages).
 >
 > The ability to move page accounting between memcg
 > (memory.move_charge_at_immigrate) makes this accounting more
 > complicated than the global counter.  The existing
 > mem_cgroup_{begin,end}_page_stat() lock is used to serialize move
 > accounting with stat updates.
 > Typical update operation:
 > 	memcg = mem_cgroup_begin_page_stat(page)
 > 	if (TestSetPageDirty()) {
 > 		[...]
 > 		mem_cgroup_update_page_stat(memcg)
 > 	}
 > 	mem_cgroup_end_page_stat(memcg)
 >
 > Summary of mem_cgroup_end_page_stat() overhead:
 > - Without CONFIG_MEMCG it's a no-op
 > - With CONFIG_MEMCG and no inter memcg task movement, it's just
 >    rcu_read_lock()
 > - With CONFIG_MEMCG and inter memcg  task movement, it's
 >    rcu_read_lock() + spin_lock_irqsave()
 >
 > A memcg parameter is added to several routines because their callers
 > now grab mem_cgroup_begin_page_stat() which returns the memcg later
 > needed by for mem_cgroup_update_page_stat().
 >
 > Because mem_cgroup_begin_page_stat() may disable interrupts, some
 > adjustments are needed:
 > - move __mark_inode_dirty() from __set_page_dirty() to its caller.
 >    __mark_inode_dirty() locking does not want interrupts disabled.
 > - use spin_lock_irqsave(tree_lock) rather than spin_lock_irq() in
 >    __delete_from_page_cache(), replace_page_cache_page(),
 >    invalidate_complete_page2(), and __remove_mapping().

This patch conflicts with my cleanup which is already in mm tree:
("page_writeback: clean up mess around cancel_dirty_page()")
Nothing nontrivial but I've killed cancel_dirty_page() and replaced
it which account_page_cleaned() symmetrical to account_page_dirtied().


I think this accounting can be done without mem_cgroup_begin_page_stat()
All page cleaning happens under page is lock.
Some dirtying is called without page-lock when kernel moves
dirty status from pte to page, but in this case acconting happens
under mapping->tree_lock.

Memcg already locks pages when moves them between cgroups,
maybe it could also lock mapping->tree_lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
