Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 182226B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:56:46 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304009438.2598.9.camel@mulgrave.site>
References: <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site>  <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
	 <1304009438.2598.9.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 11:56:17 -0500
Message-ID: <1304009778.2598.10.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 11:50 -0500, James Bottomley wrote:
> This is the output of perf record -g -a -f sleep 5
> 
> (hopefully the list won't choke)

Um, this one actually shows kswapd

James

---

# Events: 6K cycles
#
# Overhead      Command        Shared Object                                   Symbol
# ........  ...........  ...................  .......................................
#
    20.41%      kswapd0  [kernel.kallsyms]    [k] shrink_slab
                |
                --- shrink_slab
                   |          
                   |--99.91%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                    --0.09%-- [...]

     9.98%      kswapd0  [kernel.kallsyms]    [k] shrink_zone
                |
                --- shrink_zone
                   |          
                   |--99.46%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --0.54%-- kthread
                              kernel_thread_helper

     7.70%      kswapd0  [kernel.kallsyms]    [k] kswapd
                |
                --- kswapd
                    kthread
                    kernel_thread_helper

     5.40%      kswapd0  [kernel.kallsyms]    [k] zone_watermark_ok_safe
                |
                --- zone_watermark_ok_safe
                   |          
                   |--72.66%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--20.88%-- sleeping_prematurely.part.12
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --6.46%-- kthread
                              kernel_thread_helper

     4.25%      kswapd0  [kernel.kallsyms]    [k] do_raw_spin_lock
                |
                --- do_raw_spin_lock
                   |          
                   |--77.49%-- _raw_spin_lock
                   |          |          
                   |          |--51.85%-- mb_cache_shrink_fn
                   |          |          shrink_slab
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --48.15%-- mem_cgroup_soft_limit_reclaim
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--19.47%-- _raw_spin_lock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--1.73%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--0.88%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                    --0.44%-- [...]

     3.34%      kswapd0  [kernel.kallsyms]    [k] sub_preempt_count
                |
                --- sub_preempt_count
                   |          
                   |--48.58%-- _raw_spin_unlock
                   |          |          
                   |          |--80.77%-- mem_cgroup_soft_limit_reclaim
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --19.23%-- mb_cache_shrink_fn
                   |                     shrink_slab
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--17.63%-- _raw_spin_unlock_irqrestore
                   |          |          
                   |          |--52.96%-- prepare_to_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --47.04%-- finish_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--13.83%-- _raw_spin_unlock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--6.67%-- finish_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--5.54%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--2.76%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--2.24%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--1.68%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--0.55%-- irq_exit
                   |          smp_apic_timer_interrupt
                   |          apic_timer_interrupt
                   |          mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --0.54%-- mem_cgroup_charge_statistics
                              __mem_cgroup_uncharge_common
                              mem_cgroup_uncharge_cache_page
                              __remove_mapping
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     2.96%      kswapd0  [kernel.kallsyms]    [k] __zone_watermark_ok
                |
                --- __zone_watermark_ok
                   |          
                   |--85.77%-- zone_watermark_ok_safe
                   |          |          
                   |          |--74.67%-- kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --25.33%-- sleeping_prematurely.part.12
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--11.78%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --2.45%-- sleeping_prematurely.part.12
                              kswapd
                              kthread
                              kernel_thread_helper

     2.67%      kswapd0  [kernel.kallsyms]    [k] global_dirty_limits
                |
                --- global_dirty_limits
                   |          
                   |--97.28%-- throttle_vm_writeout
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --2.72%-- shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     2.30%      kswapd0  [kernel.kallsyms]    [k] add_preempt_count
                |
                --- add_preempt_count
                   |          
                   |--30.33%-- _raw_spin_lock
                   |          |          
                   |          |--52.29%-- mem_cgroup_soft_limit_reclaim
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --47.71%-- mb_cache_shrink_fn
                   |                     shrink_slab
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--28.79%-- _raw_spin_lock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--24.01%-- _raw_spin_lock_irqsave
                   |          |          
                   |          |--63.28%-- finish_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --36.72%-- prepare_to_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--6.31%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--4.82%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--3.28%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--1.64%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --0.82%-- finish_wait
                              kswapd
                              kthread
                              kernel_thread_helper

     2.02%      kswapd0  [kernel.kallsyms]    [k] up_read
                |
                --- up_read
                   |          
                   |--95.48%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --4.52%-- kswapd
                              kthread
                              kernel_thread_helper

     2.01%      kswapd0  [kernel.kallsyms]    [k] get_parent_ip
                |
                --- get_parent_ip
                   |          
                   |--37.59%-- sub_preempt_count
                   |          |          
                   |          |--66.19%-- _raw_spin_unlock
                   |          |          |          
                   |          |          |--55.77%-- mem_cgroup_soft_limit_reclaim
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --44.23%-- mb_cache_shrink_fn
                   |          |                     shrink_slab
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |          |--17.13%-- _raw_spin_unlock_irqrestore
                   |          |          |          
                   |          |          |--57.38%-- finish_wait
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --42.62%-- prepare_to_wait
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |           --16.68%-- _raw_spin_unlock_irq
                   |                     shrink_zone
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--32.16%-- add_preempt_count
                   |          |          
                   |          |--71.32%-- _raw_spin_lock
                   |          |          |          
                   |          |          |--56.02%-- mem_cgroup_soft_limit_reclaim
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --43.98%-- mb_cache_shrink_fn
                   |          |                     shrink_slab
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |          |--17.25%-- _raw_spin_lock_irqsave
                   |          |          |          
                   |          |          |--83.09%-- finish_wait
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --16.91%-- prepare_to_wait
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |           --11.43%-- _raw_spin_lock_irq
                   |                     shrink_zone
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--8.20%-- _raw_spin_unlock
                   |          |          
                   |          |--66.09%-- mem_cgroup_soft_limit_reclaim
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --33.91%-- mb_cache_shrink_fn
                   |                     shrink_slab
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--7.42%-- _raw_spin_lock
                   |          |          
                   |          |--62.14%-- mb_cache_shrink_fn
                   |          |          shrink_slab
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --37.86%-- mem_cgroup_soft_limit_reclaim
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--5.55%-- _raw_spin_lock_irqsave
                   |          |          
                   |          |--66.67%-- prepare_to_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --33.33%-- finish_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--4.53%-- _raw_spin_lock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--3.62%-- _raw_spin_unlock_irqrestore
                   |          |          
                   |          |--51.20%-- finish_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --48.80%-- prepare_to_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                    --0.94%-- _raw_spin_unlock_irq
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     1.88%      kswapd0  [kernel.kallsyms]    [k] zone_nr_lru_pages
                |
                --- zone_nr_lru_pages
                   |          
                   |--85.21%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --14.79%-- kswapd
                              kthread
                              kernel_thread_helper

     1.79%      kswapd0  [kernel.kallsyms]    [k] down_read_trylock
                |
                --- down_read_trylock
                   |          
                   |--92.80%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --7.20%-- kswapd
                              kthread
                              kernel_thread_helper

     1.69%      kswapd0  [kernel.kallsyms]    [k] mutex_trylock
                |
                --- mutex_trylock
                    i915_gem_inactive_shrink
                    shrink_slab
                    kswapd
                    kthread
                    kernel_thread_helper

     1.66%      kswapd0  [kernel.kallsyms]    [k] sleeping_prematurely.part.12
                |
                --- sleeping_prematurely.part.12
                   |          
                   |--93.41%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --6.59%-- kthread
                              kernel_thread_helper

     1.54%      kswapd0  [kernel.kallsyms]    [k] find_next_bit
                |
                --- find_next_bit
                   |          
                   |--84.45%-- cpumask_next
                   |          zone_watermark_ok_safe
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --15.55%-- zone_watermark_ok_safe
                              kswapd
                              kthread
                              kernel_thread_helper

     1.51%      kswapd0  [kernel.kallsyms]    [k] throttle_vm_writeout
                |
                --- throttle_vm_writeout
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     1.48%      kswapd0  [kernel.kallsyms]    [k] mb_cache_shrink_fn
                |
                --- mb_cache_shrink_fn
                   |          
                   |--96.31%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --3.69%-- kswapd
                              kthread
                              kernel_thread_helper

     1.31%      kswapd0  [kernel.kallsyms]    [k] mem_cgroup_soft_limit_reclaim
                |
                --- mem_cgroup_soft_limit_reclaim
                   |          
                   |--97.19%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --2.81%-- kthread
                              kernel_thread_helper

     1.26%      kswapd0  [kernel.kallsyms]    [k] mutex_unlock
                |
                --- mutex_unlock
                   |          
                   |--98.57%-- i915_gem_inactive_shrink
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --1.43%-- shrink_slab
                              kswapd
                              kthread
                              kernel_thread_helper

     1.19%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_lock_irqsave
                |
                --- _raw_spin_lock_irqsave
                   |          
                   |--47.70%-- finish_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--47.65%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --4.65%-- kswapd
                              kthread
                              kernel_thread_helper

     1.14%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_unlock
                |
                --- _raw_spin_unlock
                   |          
                   |--59.71%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--38.63%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --1.66%-- kswapd
                              kthread
                              kernel_thread_helper

     0.96%      kswapd0  [kernel.kallsyms]    [k] __mem_cgroup_largest_soft_limit_node
                |
                --- __mem_cgroup_largest_soft_limit_node
                   |          
                   |--59.47%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --40.53%-- kswapd
                              kthread
                              kernel_thread_helper

     0.88%      kswapd0  [kernel.kallsyms]    [k] in_lock_functions
                |
                --- in_lock_functions
                   |          
                   |--43.80%-- get_parent_ip
                   |          |          
                   |          |--52.47%-- add_preempt_count
                   |          |          |          
                   |          |          |--72.99%-- _raw_spin_lock
                   |          |          |          |          
                   |          |          |          |--62.71%-- mem_cgroup_soft_limit_reclaim
                   |          |          |          |          kswapd
                   |          |          |          |          kthread
                   |          |          |          |          kernel_thread_helper
                   |          |          |          |          
                   |          |          |           --37.29%-- mb_cache_shrink_fn
                   |          |          |                     shrink_slab
                   |          |          |                     kswapd
                   |          |          |                     kthread
                   |          |          |                     kernel_thread_helper
                   |          |          |          
                   |          |          |--18.30%-- _raw_spin_lock_irq
                   |          |          |          shrink_zone
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --8.71%-- _raw_spin_lock_irqsave
                   |          |                     prepare_to_wait
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |           --47.53%-- sub_preempt_count
                   |                     |          
                   |                     |--49.81%-- _raw_spin_unlock
                   |                     |          mb_cache_shrink_fn
                   |                     |          shrink_slab
                   |                     |          kswapd
                   |                     |          kthread
                   |                     |          kernel_thread_helper
                   |                     |          
                   |                     |--30.32%-- _raw_spin_unlock_irqrestore
                   |                     |          finish_wait
                   |                     |          kswapd
                   |                     |          kthread
                   |                     |          kernel_thread_helper
                   |                     |          
                   |                      --19.86%-- _raw_spin_unlock_irq
                   |                                shrink_zone
                   |                                kswapd
                   |                                kthread
                   |                                kernel_thread_helper
                   |          
                   |--29.12%-- add_preempt_count
                   |          |          
                   |          |--49.50%-- _raw_spin_lock
                   |          |          |          
                   |          |          |--56.31%-- mem_cgroup_soft_limit_reclaim
                   |          |          |          kswapd
                   |          |          |          kthread
                   |          |          |          kernel_thread_helper
                   |          |          |          
                   |          |           --43.69%-- mb_cache_shrink_fn
                   |          |                     shrink_slab
                   |          |                     kswapd
                   |          |                     kthread
                   |          |                     kernel_thread_helper
                   |          |          
                   |          |--29.19%-- _raw_spin_lock_irq
                   |          |          shrink_zone
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --21.32%-- _raw_spin_lock_irqsave
                   |                     |          
                   |                     |--65.66%-- finish_wait
                   |                     |          kswapd
                   |                     |          kthread
                   |                     |          kernel_thread_helper
                   |                     |          
                   |                      --34.34%-- prepare_to_wait
                   |                                kswapd
                   |                                kthread
                   |                                kernel_thread_helper
                   |          
                    --27.07%-- sub_preempt_count
                              |          
                              |--62.26%-- _raw_spin_unlock
                              |          |          
                              |          |--50.27%-- mb_cache_shrink_fn
                              |          |          shrink_slab
                              |          |          kswapd
                              |          |          kthread
                              |          |          kernel_thread_helper
                              |          |          
                              |           --49.73%-- mem_cgroup_soft_limit_reclaim
                              |                     kswapd
                              |                     kthread
                              |                     kernel_thread_helper
                              |          
                              |--22.85%-- _raw_spin_unlock_irqrestore
                              |          |          
                              |          |--67.34%-- finish_wait
                              |          |          kswapd
                              |          |          kthread
                              |          |          kernel_thread_helper
                              |          |          
                              |           --32.66%-- prepare_to_wait
                              |                     kswapd
                              |                     kthread
                              |                     kernel_thread_helper
                              |          
                               --14.89%-- _raw_spin_unlock_irq
                                         shrink_zone
                                         kswapd
                                         kthread
                                         kernel_thread_helper

     0.81%      kswapd0  [kernel.kallsyms]    [k] cpumask_next
                |
                --- cpumask_next
                   |          
                   |--79.81%-- zone_watermark_ok_safe
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --20.19%-- kswapd
                              kthread
                              kernel_thread_helper

     0.79%      kswapd0  [kernel.kallsyms]    [k] zone_reclaimable_pages
                |
                --- zone_reclaimable_pages
                   |          
                   |--93.08%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --6.92%-- kthread
                              kernel_thread_helper

     0.77%      kswapd0  [i915]               [k] i915_gem_inactive_shrink
                |
                --- i915_gem_inactive_shrink
                   |          
                   |--97.55%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --2.45%-- kswapd
                              kthread
                              kernel_thread_helper

     0.76%      kswapd0  [kernel.kallsyms]    [k] prepare_to_wait
                |
                --- prepare_to_wait
                   |          
                   |--97.54%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --2.46%-- kthread
                              kernel_thread_helper

     0.74%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_restore
                |
                --- arch_local_irq_restore
                   |          
                   |--79.88%-- _raw_spin_unlock_irqrestore
                   |          |          
                   |          |--62.49%-- prepare_to_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --37.51%-- finish_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--15.16%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --4.96%-- finish_wait
                              kswapd
                              kthread
                              kernel_thread_helper

     0.65%      kswapd0  [kernel.kallsyms]    [k] test_ti_thread_flag.constprop.6
                |
                --- test_ti_thread_flag.constprop.6
                   |          
                   |--20.12%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--20.09%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--14.28%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--14.16%-- _raw_spin_unlock
                   |          |          
                   |          |--80.68%-- mem_cgroup_soft_limit_reclaim
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --19.32%-- mb_cache_shrink_fn
                   |                     shrink_slab
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--11.40%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--8.63%-- finish_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--8.58%-- _raw_spin_unlock_irqrestore
                   |          |          
                   |          |--66.13%-- prepare_to_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --33.87%-- finish_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                    --2.74%-- _raw_spin_unlock_irq
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.63%          tar  [kernel.kallsyms]    [k] copy_user_generic_string
                    |
                    --- copy_user_generic_string
                       |          
                       |--56.11%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --43.89%-- generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.59%      kswapd0  [kernel.kallsyms]    [k] test_tsk_thread_flag
                |
                --- test_tsk_thread_flag
                   |          
                   |--50.16%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--46.73%-- try_to_freeze
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --3.11%-- kthread
                              kernel_thread_helper

     0.59%      kswapd0  [kernel.kallsyms]    [k] shrink_icache_memory
                |
                --- shrink_icache_memory
                   |          
                   |--81.19%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --18.81%-- kswapd
                              kthread
                              kernel_thread_helper

     0.52%      kswapd0  [kernel.kallsyms]    [k] shrink_dqcache_memory
                |
                --- shrink_dqcache_memory
                   |          
                   |--89.35%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --10.65%-- kswapd
                              kthread
                              kernel_thread_helper

     0.50%      kswapd0  [kernel.kallsyms]    [k] zone_clear_flag
                |
                --- zone_clear_flag
                   |          
                   |--77.78%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --22.22%-- kthread
                              kernel_thread_helper

     0.45%      kswapd0  [kernel.kallsyms]    [k] kthread_should_stop
                |
                --- kthread_should_stop
                   |          
                   |--54.28%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --45.72%-- kthread
                              kernel_thread_helper

     0.44%      kswapd0  [kernel.kallsyms]    [k] global_page_state
                |
                --- global_page_state
                   |          
                   |--33.60%-- throttle_vm_writeout
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--29.47%-- determine_dirtyable_memory
                   |          global_dirty_limits
                   |          throttle_vm_writeout
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--20.52%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --16.41%-- global_dirty_limits
                              throttle_vm_writeout
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.44%      kswapd0  [kernel.kallsyms]    [k] shrink_dcache_memory
                |
                --- shrink_dcache_memory
                    shrink_slab
                    kswapd
                    kthread
                    kernel_thread_helper

     0.41%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_unlock_irqrestore
                |
                --- _raw_spin_unlock_irqrestore
                   |          
                   |--59.01%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --40.99%-- finish_wait
                              kswapd
                              kthread
                              kernel_thread_helper

     0.39%      kswapd0  [kernel.kallsyms]    [k] global_reclaimable_pages
                |
                --- global_reclaimable_pages
                    determine_dirtyable_memory
                    global_dirty_limits
                    throttle_vm_writeout
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.37%      kswapd0  [kernel.kallsyms]    [k] finish_wait
                |
                --- finish_wait
                   |          
                   |--95.03%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --4.97%-- kthread
                              kernel_thread_helper

     0.33%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_lock
                |
                --- _raw_spin_lock
                   |          
                   |--60.70%-- mem_cgroup_soft_limit_reclaim
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --39.30%-- mb_cache_shrink_fn
                              shrink_slab
                              kswapd
                              kthread
                              kernel_thread_helper

     0.31%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_enable
                |
                --- arch_local_irq_enable
                   |          
                   |--76.94%-- _raw_spin_unlock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --23.06%-- shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.28%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_save
                |
                --- arch_local_irq_save
                   |          
                   |--93.18%-- _raw_spin_lock_irqsave
                   |          |          
                   |          |--64.21%-- prepare_to_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --35.79%-- finish_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                    --6.82%-- finish_wait
                              kswapd
                              kthread
                              kernel_thread_helper

     0.22%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_unlock_irq
                |
                --- _raw_spin_unlock_irq
                   |          
                   |--92.00%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --8.00%-- __remove_mapping
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.22%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_disable
                |
                --- arch_local_irq_disable
                   |          
                   |--58.81%-- arch_local_irq_save
                   |          _raw_spin_lock_irqsave
                   |          |          
                   |          |--70.97%-- finish_wait
                   |          |          kswapd
                   |          |          kthread
                   |          |          kernel_thread_helper
                   |          |          
                   |           --29.03%-- prepare_to_wait
                   |                     kswapd
                   |                     kthread
                   |                     kernel_thread_helper
                   |          
                   |--33.06%-- _raw_spin_lock_irq
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --8.13%-- shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.22%      kswapd0  [kernel.kallsyms]    [k] _raw_spin_lock_irq
                |
                --- _raw_spin_lock_irq
                   |          
                   |--58.62%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                   |--33.19%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --8.19%-- __remove_mapping
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.22%      swapper  [kernel.kallsyms]    [k] poll_idle
                |
                --- poll_idle
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.20%      kswapd0  [kernel.kallsyms]    [k] __list_add
                |
                --- __list_add
                   |          
                   |--90.97%-- prepare_to_wait
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --9.03%-- free_hot_cold_page
                              __pagevec_free
                              free_page_list
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.15%          tar  [kernel.kallsyms]    [k] zero_user_segments
                    |
                    --- zero_user_segments
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.15%      kswapd0  [kernel.kallsyms]    [k] rb_last
                |
                --- rb_last
                    mem_cgroup_soft_limit_reclaim
                    kswapd
                    kthread
                    kernel_thread_helper

     0.14%      swapper  [kernel.kallsyms]    [k] intel_idle
                |
                --- intel_idle
                    cpuidle_idle_call
                    cpu_idle
                   |          
                   |--65.05%-- rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --34.95%-- start_secondary

     0.13%      kswapd0  [kernel.kallsyms]    [k] get_reclaim_stat
                |
                --- get_reclaim_stat
                   |          
                   |--57.55%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --42.45%-- shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.12%         perf  [kernel.kallsyms]    [k] selinux_file_alloc_security
                   |
                   --- selinux_file_alloc_security
                       security_file_alloc
                       get_empty_filp
                       path_openat
                       do_filp_open
                       do_sys_open
                       sys_open
                       system_call_fastpath
                       __GI___libc_open
                       0x429beb
                       0x418709
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.12%          tar  [kernel.kallsyms]    [k] add_preempt_count
                    |
                    --- add_preempt_count
                       |          
                       |--18.90%-- _raw_spin_lock
                       |          |          
                       |          |--63.01%-- ext4_da_get_block_prep
                       |          |          __block_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |          |--20.46%-- get_page_from_freelist
                       |          |          __alloc_pages_nodemask
                       |          |          alloc_pages_current
                       |          |          __page_cache_alloc
                       |          |          grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --16.53%-- ext4_ext_map_blocks
                       |                     ext4_map_blocks
                       |                     ext4_da_get_block_prep
                       |                     __block_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--13.68%-- __lru_cache_add
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--51.23%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --48.77%-- mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--13.32%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--12.87%-- alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--9.79%-- _raw_spin_lock_irq
                       |          |          
                       |          |--62.37%-- add_to_page_cache_locked
                       |          |          add_to_page_cache_lru
                       |          |          grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --37.63%-- __set_page_dirty
                       |                     mark_buffer_dirty
                       |                     __block_commit_write
                       |                     block_write_end
                       |                     generic_write_end
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--7.52%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.32%-- lock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--3.69%-- __percpu_counter_add
                       |          __add_bdi_stat
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--3.54%-- bit_spin_lock
                       |          lock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--3.41%-- create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--3.32%-- _raw_read_lock_irqsave
                       |          dm_get_live_table
                       |          __split_and_process_bio
                       |          dm_request
                       |          generic_make_request
                       |          submit_bio
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--3.29%-- _raw_read_lock
                       |          start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --2.33%-- dput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.11%      kswapd0  [kernel.kallsyms]    [k] try_to_freeze
                |
                --- try_to_freeze
                   |          
                   |--83.76%-- kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --16.24%-- kthread
                              kernel_thread_helper

     0.10%      swapper  [kernel.kallsyms]    [k] ahci_interrupt
                |
                --- ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.09%      kswapd0  [kernel.kallsyms]    [k] determine_dirtyable_memory
                |
                --- determine_dirtyable_memory
                   |          
                   |--80.46%-- global_dirty_limits
                   |          throttle_vm_writeout
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --19.54%-- throttle_vm_writeout
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.08%          tar  [kernel.kallsyms]    [k] sub_preempt_count
                    |
                    --- sub_preempt_count
                       |          
                       |--27.37%-- _raw_spin_unlock
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--12.90%-- blk_dequeue_request
                       |          blk_start_request
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--9.76%-- bit_spin_unlock
                       |          unlock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--6.85%-- _raw_spin_unlock_irq
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--6.81%-- alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--5.86%-- _raw_spin_unlock_irqrestore
                       |          pagevec_lru_move_fn
                       |          ____pagevec_lru_add
                       |          __lru_cache_add
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--5.51%-- _raw_read_unlock
                       |          start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--5.37%-- jbd_unlock_bh_state
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_free_inode
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                       |--4.68%-- deactivate_slab
                       |          __slab_alloc
                       |          kmem_cache_alloc
                       |          alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--4.15%-- __srcu_read_unlock
                       |          fsnotify
                       |          fsnotify_modify
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--3.72%-- radix_tree_preload_end
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--3.62%-- bit_spin_unlock
                       |          jbd2_journal_add_journal_head
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --3.41%-- pagefault_enable
                                  iov_iter_copy_from_user_atomic
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.08%      swapper  [kernel.kallsyms]    [k] add_preempt_count
                |
                --- add_preempt_count
                   |          
                   |--52.45%-- _raw_spin_lock
                   |          get_next_timer_interrupt
                   |          tick_nohz_stop_sched_tick
                   |          irq_exit
                   |          smp_call_function_single_interrupt
                   |          call_function_single_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          start_secondary
                   |          
                   |--26.09%-- bit_spin_lock.constprop.22
                   |          __slab_free
                   |          kmem_cache_free
                   |          ext4_free_io_end
                   |          ext4_end_bio
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --21.46%-- __percpu_counter_add
                              __prop_inc_percpu_max
                              test_clear_page_writeback
                              end_page_writeback
                              put_io_page
                              ext4_end_bio
                              bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.08%          tar  [kernel.kallsyms]    [k] kmem_cache_alloc
                    |
                    --- kmem_cache_alloc
                       |          
                       |--74.26%-- alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--12.98%-- jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--6.88%-- mempool_alloc_slab
                       |          mempool_alloc
                       |          scsi_sg_alloc
                       |          __sg_alloc_table
                       |          scsi_alloc_sgtable
                       |          scsi_init_sgtable
                       |          scsi_init_io
                       |          scsi_setup_fs_cmnd
                       |          sd_prep_fn
                       |          blk_peek_request
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --5.87%-- selinux_inode_alloc_security
                                  security_inode_alloc
                                  inode_init_always
                                  alloc_inode
                                  new_inode
                                  ext4_new_inode
                                  ext4_create
                                  vfs_create
                                  do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     0.07%      kswapd0  [kernel.kallsyms]    [k] __free_one_page
                |
                --- __free_one_page
                    free_pcppages_bulk
                    free_hot_cold_page
                    __pagevec_free
                    free_page_list
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.07%      swapper  [kernel.kallsyms]    [k] sub_preempt_count
                |
                --- sub_preempt_count
                   |          
                   |--56.43%-- __percpu_counter_add
                   |          __add_bdi_stat
                   |          test_clear_page_writeback
                   |          end_page_writeback
                   |          put_io_page
                   |          ext4_end_bio
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--17.99%-- _raw_spin_unlock_irqrestore
                   |          __hrtimer_start_range_ns
                   |          hrtimer_start_range_ns
                   |          hrtimer_start_expires.constprop.1
                   |          tick_nohz_restart_sched_tick
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--15.61%-- _raw_spin_unlock
                   |          |          
                   |          |--55.21%-- handle_irq_event
                   |          |          handle_edge_irq
                   |          |          handle_irq
                   |          |          do_IRQ
                   |          |          common_interrupt
                   |          |          cpuidle_idle_call
                   |          |          cpu_idle
                   |          |          rest_init
                   |          |          start_kernel
                   |          |          x86_64_start_reservations
                   |          |          x86_64_start_kernel
                   |          |          
                   |           --44.79%-- scheduler_tick
                   |                     update_process_times
                   |                     tick_sched_timer
                   |                     __run_hrtimer
                   |                     hrtimer_interrupt
                   |                     smp_apic_timer_interrupt
                   |                     apic_timer_interrupt
                   |                     cpuidle_idle_call
                   |                     cpu_idle
                   |                     rest_init
                   |                     start_kernel
                   |                     x86_64_start_reservations
                   |                     x86_64_start_kernel
                   |          
                   |--5.91%-- try_to_wake_up
                   |          default_wake_function
                   |          autoremove_wake_function
                   |          wake_bit_function
                   |          __wake_up_common
                   |          __wake_up
                   |          __wake_up_bit
                   |          unlock_page
                   |          mpage_end_io
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --4.06%-- default_wake_function
                              autoremove_wake_function
                              wake_bit_function
                              __wake_up_common
                              __wake_up
                              __wake_up_bit
                              unlock_page
                              mpage_end_io
                              bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.06%          tar  [kernel.kallsyms]    [k] mark_page_accessed
                    |
                    --- mark_page_accessed
                       |          
                       |--87.24%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--6.42%-- __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --6.35%-- __find_get_block
                                  __getblk
                                  __ext4_get_inode_loc
                                  ext4_get_inode_loc
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.06%          tar  [kernel.kallsyms]    [k] get_page_from_freelist
                    |
                    --- get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--54.79%-- __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --45.21%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.06%          tar  [kernel.kallsyms]    [k] __ext4_get_inode_loc
                    |
                    --- __ext4_get_inode_loc
                        ext4_get_inode_loc
                       |          
                       |--55.97%-- ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          |          
                       |          |--76.52%-- ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --23.48%-- ext4_ext_dirty
                       |                     ext4_ext_truncate
                       |                     ext4_truncate
                       |                     ext4_evict_inode
                       |                     evict
                       |                     iput
                       |                     do_unlinkat
                       |                     sys_unlinkat
                       |                     system_call_fastpath
                       |                     unlinkat
                       |          
                        --44.03%-- ext4_xattr_get
                                  ext4_xattr_security_get
                                  generic_getxattr
                                  cap_inode_need_killpriv
                                  security_inode_need_killpriv
                                  file_remove_suid
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.06%          tar  tar                  [.] 0x2aa04         
                    |
                    --- 0x40753f

                    |
                    --- 0x4055c7

                    |
                    --- 0x42aa04

                    |
                    --- 0x4166d8
                        0x417081

                    |
                    --- 0x40fdfb

                    |
                    --- 0x405f26

                    |
                    --- 0x4332d6

                    |
                    --- 0x40fe1a

                    |
                    --- 0x408ab1

                    |
                    --- 0x40fdb8

                    |
                    --- 0x408a87

                    |
                    --- 0x4100c5

                    |
                    --- 0x407564

     0.06%         perf  [kernel.kallsyms]    [k] _raw_spin_lock_irqsave
                   |
                   --- _raw_spin_lock_irqsave
                       __wake_up
                       jbd2_journal_stop
                       __ext4_journal_stop
                       ext4_da_write_end
                       generic_file_buffered_write
                       __generic_file_aio_write
                       generic_file_aio_write
                       ext4_file_write
                       do_sync_write
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel
                       0x4293b8
                       0x429c0a
                       0x418709
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.05%          tar  [kernel.kallsyms]    [k] do_raw_spin_lock
                    |
                    --- do_raw_spin_lock
                       |          
                       |--79.42%-- _raw_spin_lock_irq
                       |          |          
                       |          |--57.06%-- __set_page_dirty
                       |          |          mark_buffer_dirty
                       |          |          __block_commit_write
                       |          |          block_write_end
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --42.94%-- add_to_page_cache_locked
                       |                     add_to_page_cache_lru
                       |                     |          
                       |                     |--52.51%-- grab_cache_page_write_begin
                       |                     |          ext4_da_write_begin
                       |                     |          generic_file_buffered_write
                       |                     |          __generic_file_aio_write
                       |                     |          generic_file_aio_write
                       |                     |          ext4_file_write
                       |                     |          do_sync_write
                       |                     |          vfs_write
                       |                     |          sys_write
                       |                     |          system_call_fastpath
                       |                     |          __GI___libc_write
                       |                     |          
                       |                      --47.49%-- mpage_readpages
                       |                                ext4_readpages
                       |                                __do_page_cache_readahead
                       |                                ra_submit
                       |                                ondemand_readahead
                       |                                page_cache_async_readahead
                       |                                generic_file_aio_read
                       |                                do_sync_read
                       |                                vfs_read
                       |                                sys_read
                       |                                system_call_fastpath
                       |                                __GI___libc_read
                       |          
                       |--15.99%-- _raw_spin_lock
                       |          |          
                       |          |--60.63%-- ext4_ext_map_blocks
                       |          |          ext4_map_blocks
                       |          |          ext4_da_get_block_prep
                       |          |          __block_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --39.37%-- inode_add_rsv_space
                       |                     __dquot_alloc_space
                       |                     ext4_da_get_block_prep
                       |                     __block_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --4.59%-- inode_add_rsv_space
                                  __dquot_alloc_space
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.05%          tar  [kernel.kallsyms]    [k] __mem_cgroup_commit_charge.constprop.28
                    |
                    --- __mem_cgroup_commit_charge.constprop.28
                       |          
                       |--91.58%-- __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--51.67%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --48.33%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --8.42%-- mem_cgroup_cache_charge
                                  add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.05%          tar  [kernel.kallsyms]    [k] radix_tree_lookup_element
                    |
                    --- radix_tree_lookup_element
                       |          
                       |--69.74%-- radix_tree_lookup_slot
                       |          find_get_page
                       |          |          
                       |          |--58.70%-- generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --41.30%-- find_lock_page
                       |                     grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--17.45%-- radix_tree_lookup
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --12.81%-- find_get_page
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.04%          tar  [kernel.kallsyms]    [k] __alloc_pages_nodemask
                    |
                    --- __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--71.39%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --28.61%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.04%          tar  [kernel.kallsyms]    [k] put_mems_allowed
                    |
                    --- put_mems_allowed
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--70.79%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --29.21%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.04%      swapper  [kernel.kallsyms]    [k] load_balance
                |
                --- load_balance
                    rebalance_domains
                    run_rebalance_domains
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.04%  flush-253:2  [kernel.kallsyms]    [k] __bio_clone
            |
            --- __bio_clone
                clone_bio
                __split_and_process_bio
                dm_request
                generic_make_request
                submit_bio
                ext4_io_submit
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.04%          tar  [kernel.kallsyms]    [k] __wake_up_bit
                    |
                    --- __wake_up_bit
                       |          
                       |--89.40%-- unlock_page
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --10.60%-- wake_up_bit
                                  unlock_buffer
                                  do_get_write_access
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.04%          tar  [kernel.kallsyms]    [k] get_parent_ip
                    |
                    --- get_parent_ip
                       |          
                       |--29.28%-- sub_preempt_count
                       |          |          
                       |          |--59.65%-- pagefault_enable
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --40.35%-- bit_spin_unlock
                       |                     jbd2_journal_put_journal_head
                       |                     jbd2_journal_get_write_access
                       |                     __ext4_journal_get_write_access
                       |                     ext4_reserve_inode_write
                       |                     ext4_mark_inode_dirty
                       |                     ext4_dirty_inode
                       |                     __mark_inode_dirty
                       |                     generic_write_end
                       |                     ext4_da_write_end
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--19.16%-- avc_has_perm_noaudit
                       |          avc_has_perm
                       |          inode_has_perm
                       |          selinux_inode_permission
                       |          security_inode_exec_permission
                       |          exec_permission
                       |          link_path_walk
                       |          path_openat
                       |          do_filp_open
                       |          do_sys_open
                       |          sys_openat
                       |          system_call_fastpath
                       |          __GI___openat
                       |          
                       |--19.01%-- _raw_spin_lock
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--17.20%-- bit_spin_lock
                       |          lock_page_cgroup
                       |          __mem_cgroup_commit_charge.constprop.28
                       |          __mem_cgroup_commit_charge_lrucare
                       |          mem_cgroup_cache_charge
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --15.36%-- add_preempt_count
                                  file_read_actor
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.04%          tar  [kernel.kallsyms]    [k] ext4_mark_iloc_dirty
                    |
                    --- ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                       |          
                       |--77.33%-- ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--13.35%-- ext4_new_inode
                       |          ext4_create
                       |          vfs_create
                       |          do_last
                       |          path_openat
                       |          do_filp_open
                       |          do_sys_open
                       |          sys_openat
                       |          system_call_fastpath
                       |          __GI___openat
                       |          
                        --9.32%-- ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.04%      kswapd0  [kernel.kallsyms]    [k] native_write_msr_safe
                |
                --- native_write_msr_safe
                    paravirt_write_msr
                    intel_pmu_disable_all
                    x86_pmu_disable
                    perf_pmu_disable
                    perf_event_task_tick
                    scheduler_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                   |          
                   |--50.07%-- zone_watermark_ok_safe
                   |          sleeping_prematurely.part.12
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --49.93%-- kswapd
                              kthread
                              kernel_thread_helper

     0.04%      swapper  [kernel.kallsyms]    [k] ext4_end_bio
                |
                --- ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.04%      kswapd0  [kernel.kallsyms]    [k] __list_del_entry
                |
                --- __list_del_entry
                    finish_wait
                    kswapd
                    kthread
                    kernel_thread_helper

     0.04%      kswapd0  [kernel.kallsyms]    [k] mcount
                |
                --- mcount
                    _raw_spin_lock_irq
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.04%          tar  [kernel.kallsyms]    [k] __percpu_counter_add
                    |
                    --- __percpu_counter_add
                       |          
                       |--87.00%-- ext4_claim_free_blocks
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --13.00%-- __prop_inc_single
                                  task_dirty_inc
                                  account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.04%          tar  [kernel.kallsyms]    [k] arch_read_unlock
                    |
                    --- arch_read_unlock
                       |          
                       |--57.64%-- _raw_read_unlock_irqrestore
                       |          dm_get_live_table
                       |          dm_merge_bvec
                       |          __bio_add_page.part.2
                       |          bio_add_page
                       |          do_mpage_readpage
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--31.54%-- _raw_read_unlock
                       |          start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --10.82%-- start_this_handle
                                  jbd2__journal_start
                                  jbd2_journal_start
                                  ext4_journal_start_sb
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.04%      kswapd0  [kernel.kallsyms]    [k] mem_cgroup_del_lru_list
                |
                --- mem_cgroup_del_lru_list
                    mem_cgroup_del_lru
                    isolate_lru_pages
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.04%      kswapd0  [kernel.kallsyms]    [k] test_and_set_bit
                |
                --- test_and_set_bit
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.04%          tar  [kernel.kallsyms]    [k] __might_sleep
                    |
                    --- __might_sleep
                       |          
                       |--22.45%-- kmem_cache_alloc
                       |          |          
                       |          |--59.27%-- getname_flags
                       |          |          getname
                       |          |          do_sys_open
                       |          |          sys_openat
                       |          |          system_call_fastpath
                       |          |          __GI___openat
                       |          |          
                       |           --40.73%-- jbd2__journal_start
                       |                     jbd2_journal_start
                       |                     ext4_journal_start_sb
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--22.30%-- __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--54.37%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --45.63%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--15.00%-- lock_buffer
                       |          do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--11.33%-- __getblk
                       |          __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--11.31%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--10.36%-- unmap_underlying_metadata
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --7.25%-- __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.04%      kswapd0  [kernel.kallsyms]    [k] debug_smp_processor_id
                |
                --- debug_smp_processor_id
                   |          
                   |--50.69%-- __pagevec_free
                   |          free_page_list
                   |          shrink_page_list
                   |          shrink_inactive_list
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --49.31%-- free_hot_cold_page
                              __pagevec_free
                              free_page_list
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.04%      kswapd0  [kernel.kallsyms]    [k] __mem_cgroup_uncharge_common
                |
                --- __mem_cgroup_uncharge_common
                    mem_cgroup_uncharge_cache_page
                    __remove_mapping
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.04%      kswapd0  [kernel.kallsyms]    [k] tag_get
                |
                --- tag_get
                   |          
                   |--50.59%-- radix_tree_delete
                   |          __delete_from_page_cache
                   |          __remove_mapping
                   |          shrink_page_list
                   |          shrink_inactive_list
                   |          shrink_zone
                   |          kswapd
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --49.41%-- __delete_from_page_cache
                              __remove_mapping
                              shrink_page_list
                              shrink_inactive_list
                              shrink_zone
                              kswapd
                              kthread
                              kernel_thread_helper

     0.03%  flush-253:2  [kernel.kallsyms]    [k] add_preempt_count
            |
            --- add_preempt_count
               |          
               |--51.77%-- _raw_read_lock_irqsave
               |          dm_get_live_table
               |          dm_merge_bvec
               |          __bio_add_page.part.2
               |          bio_add_page
               |          ext4_bio_write_page
               |          mpage_da_submit_io
               |          mpage_da_map_and_submit
               |          ext4_da_writepages
               |          do_writepages
               |          writeback_single_inode
               |          writeback_sb_inodes
               |          writeback_inodes_wb
               |          wb_writeback
               |          wb_do_writeback
               |          bdi_writeback_thread
               |          kthread
               |          kernel_thread_helper
               |          
                --48.23%-- blk_throtl_bio
                          generic_make_request
                          submit_bio
                          ext4_io_submit
                          mpage_da_submit_io
                          mpage_da_map_and_submit
                          ext4_da_writepages
                          do_writepages
                          writeback_single_inode
                          writeback_sb_inodes
                          writeback_inodes_wb
                          wb_writeback
                          wb_do_writeback
                          bdi_writeback_thread
                          kthread
                          kernel_thread_helper

     0.03%          tar  [kernel.kallsyms]    [k] __inc_zone_state
                    |
                    --- __inc_zone_state
                       |          
                       |--49.98%-- __inc_zone_page_state
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--79.48%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --20.52%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                       |--32.04%-- zone_statistics
                       |          get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --17.98%-- account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%          tar  [kernel.kallsyms]    [k] __list_del_entry
                    |
                    --- __list_del_entry
                       |          
                       |--56.86%-- list_del
                       |          __rmqueue
                       |          get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--78.10%-- __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --21.90%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --43.14%-- __rmqueue
                                  get_page_from_freelist
                                  __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.03%  flush-253:2  [kernel.kallsyms]    [k] dm_table_find_target
            |
            --- dm_table_find_target
                dm_merge_bvec
                __bio_add_page.part.2
                bio_add_page
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%          tar  [kernel.kallsyms]    [k] jbd_lock_bh_state
                    |
                    --- jbd_lock_bh_state
                       |          
                       |--61.84%-- do_get_write_access
                       |          jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          |          
                       |          |--72.93%-- generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --27.07%-- ext4_free_blocks
                       |                     ext4_ext_truncate
                       |                     ext4_truncate
                       |                     ext4_evict_inode
                       |                     evict
                       |                     iput
                       |                     do_unlinkat
                       |                     sys_unlinkat
                       |                     system_call_fastpath
                       |                     unlinkat
                       |          
                        --38.16%-- jbd2_journal_dirty_metadata
                                  __ext4_handle_dirty_metadata
                                  ext4_mark_iloc_dirty
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%  flush-253:2  [kernel.kallsyms]    [k] page_waitqueue
            |
            --- page_waitqueue
                ext4_num_dirty_pages
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%  flush-253:2  [kernel.kallsyms]    [k] radix_tree_lookup_element
            |
            --- radix_tree_lookup_element
                radix_tree_lookup_slot
                find_get_page
                __find_get_block_slow
                unmap_underlying_metadata
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%          tar  [kernel.kallsyms]    [k] fcheck_files
                    |
                    --- fcheck_files
                        fget_light
                       |          
                       |--71.87%-- sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --28.13%-- sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%  flush-253:2  [kernel.kallsyms]    [k] atomic_inc
            |
            --- atomic_inc
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%  flush-253:2  [kernel.kallsyms]    [k] lock_page
            |
            --- lock_page
                ext4_num_dirty_pages
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%          tar  [kernel.kallsyms]    [k] put_page_testzero
                    |
                    --- put_page_testzero
                       |          
                       |--70.70%-- release_pages
                       |          pagevec_lru_move_fn
                       |          ____pagevec_lru_add
                       |          __lru_cache_add
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--77.62%-- mpage_readpages
                       |          |          ext4_readpages
                       |          |          __do_page_cache_readahead
                       |          |          ra_submit
                       |          |          ondemand_readahead
                       |          |          page_cache_async_readahead
                       |          |          generic_file_aio_read
                       |          |          do_sync_read
                       |          |          vfs_read
                       |          |          sys_read
                       |          |          system_call_fastpath
                       |          |          __GI___libc_read
                       |          |          
                       |           --22.38%-- grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --29.30%-- put_page
                                  mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.03%          tar  [kernel.kallsyms]    [k] zone_watermark_ok
                    |
                    --- zone_watermark_ok
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--84.29%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --15.71%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.03%          tar  [kernel.kallsyms]    [k] start_this_handle
                    |
                    --- start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                       |          
                       |--86.30%-- ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --13.70%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%  flush-253:2  [kernel.kallsyms]    [k] ext4_num_dirty_pages
            |
            --- ext4_num_dirty_pages
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.03%          tar  [kernel.kallsyms]    [k] put_mems_allowed
                    |
                    --- put_mems_allowed
                       |          
                       |--74.79%-- __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--65.17%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --34.83%-- __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                        --25.21%-- alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%          tar  [kernel.kallsyms]    [k] debug_smp_processor_id
                    |
                    --- debug_smp_processor_id
                       |          
                       |--57.28%-- load_balance
                       |          schedule
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--25.57%-- radix_tree_preload
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --17.15%-- get_page_from_freelist
                                  __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.03%      swapper  [kernel.kallsyms]    [k] __wake_up_bit
                |
                --- __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.03%          tar  [kernel.kallsyms]    [k] avc_has_perm_noaudit
                    |
                    --- avc_has_perm_noaudit
                        avc_has_perm
                       |          
                       |--82.82%-- inode_has_perm
                       |          |          
                       |          |--71.72%-- dentry_has_perm
                       |          |          selinux_inode_getattr
                       |          |          security_inode_getattr
                       |          |          vfs_getattr
                       |          |          vfs_fstat
                       |          |          sys_newfstat
                       |          |          system_call_fastpath
                       |          |          __GI___fxstat64
                       |          |          
                       |           --28.28%-- selinux_inode_permission
                       |                     security_inode_exec_permission
                       |                     exec_permission
                       |                     link_path_walk
                       |                     path_openat
                       |                     do_filp_open
                       |                     do_sys_open
                       |                     sys_openat
                       |                     system_call_fastpath
                       |                     __GI___openat
                       |          
                        --17.18%-- may_create
                                  selinux_inode_create
                                  security_inode_create
                                  vfs_create
                                  do_last
                                  path_openat
                                  do_filp_open
                                  do_sys_open
                                  sys_openat
                                  system_call_fastpath
                                  __GI___openat

     0.03%          tar  [kernel.kallsyms]    [k] _raw_spin_lock_irqsave
                    |
                    --- _raw_spin_lock_irqsave
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.03%          tar  [kernel.kallsyms]    [k] do_mpage_readpage
                    |
                    --- do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.03%          tar  [kernel.kallsyms]    [k] list_del
                    |
                    --- list_del
                       |          
                       |--55.44%-- get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          |          
                       |          |--67.14%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --32.86%-- __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                       |--28.53%-- ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --16.02%-- __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] __rmqueue
                    |
                    --- __rmqueue
                       |          
                       |--77.01%-- get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --22.99%-- __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] __mem_cgroup_commit_charge_lrucare
                    |
                    --- __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--83.13%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --16.87%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] update_page_reclaim_stat
                    |
                    --- update_page_reclaim_stat
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                       |          
                       |--75.26%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --24.74%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.02%          tar  [kernel.kallsyms]    [k] radix_tree_insert
                    |
                    --- radix_tree_insert
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--81.25%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --18.75%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] add_to_page_cache_locked
                    |
                    --- add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--62.06%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --37.94%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] page_waitqueue
                    |
                    --- page_waitqueue
                       |          
                       |--58.60%-- generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --41.40%-- unlock_page
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] up_read
                    |
                    --- up_read
                       |          
                       |--52.38%-- ext4_map_blocks
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.62%-- ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%      swapper  [kernel.kallsyms]    [k] elv_completed_request
                |
                --- elv_completed_request
                    blk_finish_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%          tar  [kernel.kallsyms]    [k] arch_local_irq_save
                    |
                    --- arch_local_irq_save
                       |          
                       |--84.09%-- task_dirty_inc
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --15.91%-- account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] ext4_map_blocks
                    |
                    --- ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%  flush-253:2  [kernel.kallsyms]    [k] mcount
            |
            --- mcount
                _raw_spin_unlock_irqrestore
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] clear_buffer_dirty
            |
            --- clear_buffer_dirty
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] mem_cgroup_add_lru_list
                    |
                    --- mem_cgroup_add_lru_list
                        add_page_to_lru_list
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.02%      swapper  [kernel.kallsyms]    [k] blk_complete_request
                |
                --- blk_complete_request
                    scsi_done
                    ata_scsi_qc_complete
                    __ata_qc_complete
                    ata_qc_complete
                    ata_qc_complete_multiple
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%      swapper  [kernel.kallsyms]    [k] sg_init_table
                |
                --- sg_init_table
                    scsi_alloc_sgtable
                    scsi_init_sgtable
                    scsi_init_io
                    scsi_setup_fs_cmnd
                    sd_prep_fn
                    blk_peek_request
                    scsi_request_fn
                    __blk_run_queue
                    blk_run_queue
                    scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%          tar  [kernel.kallsyms]    [k] _raw_spin_lock
                    |
                    --- _raw_spin_lock
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] touch_atime
                    |
                    --- touch_atime
                       |          
                       |--90.35%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --9.65%-- do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.02%         perf  ld-2.13.90.so        [.] _dl_fixup
                   |
                   --- _dl_fixup

     0.02%          tar  [kernel.kallsyms]    [k] __block_write_begin
                    |
                    --- __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%      kswapd0  [kernel.kallsyms]    [k] irqtime_account_process_tick
                |
                --- irqtime_account_process_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    i915_gem_inactive_shrink
                    shrink_slab
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] apic_timer_interrupt
                |
                --- apic_timer_interrupt
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%  kworker/2:1  [kernel.kallsyms]    [k] ns_to_timeval
            |
            --- ns_to_timeval
                get_cpu_iowait_time_us
                do_dbs_timer
                process_one_work
                worker_thread
                kthread
                kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] task_rq_lock
                |
                --- task_rq_lock
                    try_to_wake_up
                    wake_up_process
                    wake_up_worker
                    insert_work
                    __queue_work
                    delayed_work_timer_fn
                    run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    zone_watermark_ok_safe
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] hrtimer_run_queues
                |
                --- hrtimer_run_queues
                    run_local_timers
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    kthread
                    kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] next_zones_zonelist
                    |
                    --- next_zones_zonelist
                       |          
                       |--71.41%-- get_page_from_freelist
                       |          __alloc_pages_nodemask
                       |          alloc_pages_current
                       |          __page_cache_alloc
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --28.59%-- __alloc_pages_nodemask
                                  alloc_pages_current
                                  __page_cache_alloc
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_disable
                |
                --- arch_local_irq_disable
                    run_local_timers
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] __rcu_pending
                |
                --- __rcu_pending
                    rcu_check_callbacks
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] write_cache_pages_da
            |
            --- write_cache_pages_da
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] intel_pmu_disable_all
                |
                --- intel_pmu_disable_all
                    x86_pmu_disable
                    perf_pmu_disable
                    perf_event_task_tick
                    scheduler_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    sleeping_prematurely.part.12
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      swapper  [kernel.kallsyms]    [k] arch_local_save_flags
                |
                --- arch_local_save_flags
                    arch_local_irq_save
                    irqtime_account_process_tick
                    account_process_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%      kswapd0  [kernel.kallsyms]    [k] arch_local_irq_restore
                |
                --- arch_local_irq_restore
                    call_rcu
                    d_free
                    dentry_kill
                    shrink_dentry_list
                    __shrink_dcache_sb
                    shrink_dcache_memory
                    shrink_slab
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] SetPageLRU
                    |
                    --- SetPageLRU
                       |          
                       |--66.95%-- ____pagevec_lru_add_fn
                       |          pagevec_lru_move_fn
                       |          ____pagevec_lru_add
                       |          __lru_cache_add
                       |          add_to_page_cache_lru
                       |          |          
                       |          |--56.88%-- grab_cache_page_write_begin
                       |          |          ext4_da_write_begin
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --43.12%-- mpage_readpages
                       |                     ext4_readpages
                       |                     __do_page_cache_readahead
                       |                     ra_submit
                       |                     ondemand_readahead
                       |                     page_cache_async_readahead
                       |                     generic_file_aio_read
                       |                     do_sync_read
                       |                     vfs_read
                       |                     sys_read
                       |                     system_call_fastpath
                       |                     __GI___libc_read
                       |          
                        --33.05%-- pagevec_lru_move_fn
                                  ____pagevec_lru_add
                                  __lru_cache_add
                                  add_to_page_cache_lru
                                  mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.02%      kswapd0  [kernel.kallsyms]    [k] run_timer_softirq
                |
                --- run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    i915_gem_inactive_shrink
                    shrink_slab
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] __isolate_lru_page
                |
                --- __isolate_lru_page
                    isolate_lru_pages
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] arch_local_save_flags
                |
                --- arch_local_save_flags
                    __might_sleep
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] radix_tree_delete
                |
                --- radix_tree_delete
                    __delete_from_page_cache
                    __remove_mapping
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] radix_tree_tag_clear
            |
            --- radix_tree_tag_clear
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] ext4_map_blocks
            |
            --- ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] arch_local_save_flags
                    |
                    --- arch_local_save_flags
                        __might_sleep
                       |          
                       |--51.15%-- __getblk
                       |          __ext4_get_inode_loc
                       |          ext4_get_inode_loc
                       |          |          
                       |          |--50.51%-- ext4_reserve_inode_write
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_ext_truncate
                       |          |          ext4_truncate
                       |          |          ext4_evict_inode
                       |          |          evict
                       |          |          iput
                       |          |          do_unlinkat
                       |          |          sys_unlinkat
                       |          |          system_call_fastpath
                       |          |          unlinkat
                       |          |          
                       |           --49.49%-- ext4_xattr_get
                       |                     ext4_xattr_security_get
                       |                     generic_getxattr
                       |                     cap_inode_need_killpriv
                       |                     security_inode_need_killpriv
                       |                     file_remove_suid
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --48.85%-- kmem_cache_alloc
                                  jbd2__journal_start
                                  jbd2_journal_start
                                  ext4_journal_start_sb
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%      kswapd0  [kernel.kallsyms]    [k] mem_cgroup_uncharge_cache_page
                |
                --- mem_cgroup_uncharge_cache_page
                    shrink_page_list
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] update_curr
                |
                --- update_curr
                    task_tick_fair
                    scheduler_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] timerqueue_del
                |
                --- timerqueue_del
                    __remove_hrtimer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    _raw_spin_unlock_irqrestore
                    prepare_to_wait
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] ack_APIC_irq
                |
                --- ack_APIC_irq
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%  kworker/2:1  [kernel.kallsyms]    [k] too_many_workers
            |
            --- too_many_workers
                worker_enter_idle
                worker_thread
                kthread
                kernel_thread_helper

     0.02%      kswapd0  [kernel.kallsyms]    [k] update_isolated_counts
                |
                --- update_isolated_counts
                    shrink_inactive_list
                    shrink_zone
                    kswapd
                    kthread
                    kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] test_ti_thread_flag.constprop.6
            |
            --- test_ti_thread_flag.constprop.6
                _raw_spin_unlock_irqrestore
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] jbd2_journal_get_write_access
            |
            --- jbd2_journal_get_write_access
                __ext4_journal_get_write_access
                ext4_reserve_inode_write
                ext4_mark_inode_dirty
                ext4_ext_dirty
                ext4_ext_insert_extent
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] radix_tree_tag_set
            |
            --- radix_tree_tag_set
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] __lookup
            |
            --- __lookup
                radix_tree_gang_lookup_slot
                find_get_pages
                pagevec_lookup
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] page_cache_get_speculative
            |
            --- page_cache_get_speculative
                find_get_pages_tag
                pagevec_lookup_tag
                ext4_num_dirty_pages
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] arch_local_irq_restore
            |
            --- arch_local_irq_restore
                _raw_spin_unlock_irqrestore
                test_set_page_writeback
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] ext4_ext_map_blocks
            |
            --- ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] jbd_lock_bh_state
            |
            --- jbd_lock_bh_state
                jbd2_journal_dirty_metadata
                __ext4_handle_dirty_metadata
                ext4_mb_mark_diskspace_used
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] sub_preempt_count
            |
            --- sub_preempt_count
                jbd_unlock_bh_state
                jbd2_journal_dirty_metadata
                __ext4_handle_dirty_metadata
                ext4_mb_mark_diskspace_used
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] alloc_pages_current
                    |
                    --- alloc_pages_current
                        __page_cache_alloc
                       |          
                       |--72.21%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --27.79%-- __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.02%  flush-253:2  [kernel.kallsyms]    [k] ext4_bio_write_page
            |
            --- ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%  flush-253:2  [kernel.kallsyms]    [k] ext4_mb_complex_scan_group
            |
            --- ext4_mb_complex_scan_group
                ext4_mb_regular_allocator
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          top  [kernel.kallsyms]    [k] __d_lookup
                    |
                    --- __d_lookup
                        d_lookup
                        proc_fill_cache
                        proc_pid_readdir
                        proc_root_readdir
                        vfs_readdir
                        sys_getdents
                        system_call_fastpath
                        __getdents64

     0.02%  flush-253:2  [kernel.kallsyms]    [k] kmem_cache_alloc
            |
            --- kmem_cache_alloc
                ext4_init_io_end
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] page_cache_get_speculative
                    |
                    --- page_cache_get_speculative
                        find_get_page
                       |          
                       |--51.46%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --48.54%-- find_lock_page
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%  flush-253:2  [kernel.kallsyms]    [k] mb_find_extent.constprop.12
            |
            --- mb_find_extent.constprop.12
                ext4_mb_complex_scan_group
                ext4_mb_regular_allocator
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] generic_file_buffered_write
                    |
                    --- generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%          top  libc-2.13.90.so      [.] __GI_vfprintf
                    |
                    --- __GI_vfprintf
                        ___vsprintf_chk

     0.02%          tar  [kernel.kallsyms]    [k] ext4_da_get_block_prep
                    |
                    --- ext4_da_get_block_prep
                       |          
                       |--75.27%-- __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --24.73%-- ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          top  [kernel.kallsyms]    [k] getname_flags
                    |
                    --- getname_flags
                        getname
                        do_sys_open
                        sys_open
                        system_call_fastpath
                        __GI___libc_open

     0.02%      swapper  [kernel.kallsyms]    [k] __count_vm_events
                |
                --- __count_vm_events
                    __free_pages
                    __free_slab
                    discard_slab
                    __slab_free
                    kmem_cache_free
                    ext4_free_io_end
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%      swapper  [kernel.kallsyms]    [k] tick_check_idle
                |
                --- tick_check_idle
                    irq_enter
                   |          
                   |--73.47%-- smp_call_function_single_interrupt
                   |          call_function_single_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          start_secondary
                   |          
                    --26.53%-- smp_apic_timer_interrupt
                              apic_timer_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.02%  flush-253:2  [kernel.kallsyms]    [k] find_next_zero_bit
            |
            --- find_next_zero_bit
                mb_find_next_zero_bit
                ext4_mb_complex_scan_group
                ext4_mb_regular_allocator
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%          tar  [kernel.kallsyms]    [k] arch_read_lock
                    |
                    --- arch_read_lock
                        _raw_read_lock
                        start_this_handle
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%  flush-253:2  [kernel.kallsyms]    [k] mb_find_buddy
            |
            --- mb_find_buddy
                mb_mark_used
                ext4_mb_use_best_found
                ext4_mb_check_limits
                ext4_mb_complex_scan_group
                ext4_mb_regular_allocator
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.02%      swapper  [kernel.kallsyms]    [k] __rcu_read_unlock
                |
                --- __rcu_read_unlock
                    __prop_inc_percpu_max
                    test_clear_page_writeback
                    end_page_writeback
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%          tar  [kernel.kallsyms]    [k] mark_buffer_dirty
                    |
                    --- mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] new_slab
                    |
                    --- new_slab
                        __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%      swapper  [kernel.kallsyms]    [k] __do_softirq
                |
                --- __do_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%      swapper  [kernel.kallsyms]    [k] select_task_rq_fair
                |
                --- select_task_rq_fair
                    select_task_rq
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.02%          tar  [kernel.kallsyms]    [k] do_get_write_access
                    |
                    --- do_get_write_access
                       |          
                       |--70.88%-- jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          |          
                       |          |--54.37%-- ext4_new_inode
                       |          |          ext4_create
                       |          |          vfs_create
                       |          |          do_last
                       |          |          path_openat
                       |          |          do_filp_open
                       |          |          do_sys_open
                       |          |          sys_openat
                       |          |          system_call_fastpath
                       |          |          __GI___openat
                       |          |          
                       |           --45.63%-- ext4_reserve_inode_write
                       |                     ext4_orphan_add
                       |                     ext4_unlink
                       |                     vfs_unlink
                       |                     do_unlinkat
                       |                     sys_unlinkat
                       |                     system_call_fastpath
                       |                     unlinkat
                       |          
                        --29.12%-- __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] in_lock_functions
                    |
                    --- in_lock_functions
                       |          
                       |--58.27%-- get_parent_ip
                       |          add_preempt_count
                       |          |          
                       |          |--56.37%-- jbd_lock_bh_state
                       |          |          jbd2_journal_dirty_metadata
                       |          |          __ext4_handle_dirty_metadata
                       |          |          ext4_mark_iloc_dirty
                       |          |          ext4_mark_inode_dirty
                       |          |          ext4_dirty_inode
                       |          |          __mark_inode_dirty
                       |          |          generic_write_end
                       |          |          ext4_da_write_end
                       |          |          generic_file_buffered_write
                       |          |          __generic_file_aio_write
                       |          |          generic_file_aio_write
                       |          |          ext4_file_write
                       |          |          do_sync_write
                       |          |          vfs_write
                       |          |          sys_write
                       |          |          system_call_fastpath
                       |          |          __GI___libc_write
                       |          |          
                       |           --43.63%-- radix_tree_preload
                       |                     add_to_page_cache_locked
                       |                     add_to_page_cache_lru
                       |                     grab_cache_page_write_begin
                       |                     ext4_da_write_begin
                       |                     generic_file_buffered_write
                       |                     __generic_file_aio_write
                       |                     generic_file_aio_write
                       |                     ext4_file_write
                       |                     do_sync_write
                       |                     vfs_write
                       |                     sys_write
                       |                     system_call_fastpath
                       |                     __GI___libc_write
                       |          
                        --41.73%-- sub_preempt_count
                                  bit_spin_unlock
                                  jbd2_journal_add_journal_head
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] jbd2_journal_dirty_metadata
                    |
                    --- jbd2_journal_dirty_metadata
                        __ext4_handle_dirty_metadata
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] ext4_ext_map_blocks
                    |
                    --- ext4_ext_map_blocks
                        ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.02%          tar  [kernel.kallsyms]    [k] block_write_end
                    |
                    --- block_write_end
                       |          
                       |--67.22%-- ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --32.78%-- generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.02%  flush-253:2  [kernel.kallsyms]    [k] mb_test_bit
            |
            --- mb_test_bit
                mb_find_order_for_block
                mb_find_extent.constprop.12
                ext4_mb_complex_scan_group
                ext4_mb_regular_allocator
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] attach_page_buffers
                    |
                    --- attach_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __phys_addr
                    |
                    --- __phys_addr
                        virt_to_head_page
                        kmem_cache_free
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] do_sync_read
                    |
                    --- do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] swiotlb_map_sg_attrs
                    |
                    --- swiotlb_map_sg_attrs
                        ata_qc_issue
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] jbd2__journal_start
                    |
                    --- jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                       |          
                       |--73.97%-- ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --26.03%-- ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] iov_iter_advance
                    |
                    --- iov_iter_advance
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] generic_getxattr
                    |
                    --- generic_getxattr
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%  jbd2/dm-2-8  [kernel.kallsyms]    [k] elv_rq_merge_ok
            |
            --- elv_rq_merge_ok
                elv_try_merge
                __make_request
                generic_make_request
                submit_bio
                submit_bh
                jbd2_journal_commit_transaction
                kjournald2
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] clear_bit_unlock
                    |
                    --- clear_bit_unlock
                        unlock_buffer
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] page_waitqueue
                |
                --- page_waitqueue
                   |          
                   |--52.26%-- unlock_page
                   |          mpage_end_io
                   |          bio_endio
                   |          dec_pending
                   |          clone_endio
                   |          bio_endio
                   |          req_bio_endio
                   |          blk_update_request
                   |          blk_update_bidi_request
                   |          blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --47.74%-- mpage_end_io
                              bio_endio
                              dec_pending
                              clone_endio
                              bio_endio
                              req_bio_endio
                              blk_update_request
                              blk_update_bidi_request
                              blk_end_bidi_request
                              blk_end_request
                              scsi_io_completion
                              scsi_finish_command
                              scsi_softirq_done
                              blk_done_softirq
                              __do_softirq
                              call_softirq
                              do_softirq
                              irq_exit
                              do_IRQ
                              common_interrupt
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] ext4_xattr_find_entry
                    |
                    --- ext4_xattr_find_entry
                        ext4_xattr_get
                        ext4_xattr_security_get
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] bit_spin_lock
                    |
                    --- bit_spin_lock
                        lock_page_cgroup
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--76.11%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --23.89%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%  flush-253:2  [kernel.kallsyms]    [k] writeback_single_inode
            |
            --- writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] find_get_page
                    |
                    --- find_get_page
                       |          
                       |--70.62%-- __find_get_block_slow
                       |          __find_get_block
                       |          ext4_free_blocks
                       |          ext4_ext_truncate
                       |          ext4_truncate
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                        --29.38%-- generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%  flush-253:2  [kernel.kallsyms]    [k] __ext4_get_inode_loc
            |
            --- __ext4_get_inode_loc
                ext4_get_inode_loc
                ext4_reserve_inode_write
                ext4_mark_inode_dirty
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] fsnotify_modify
                    |
                    --- fsnotify_modify
                       |          
                       |--73.71%-- vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --26.29%-- sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] blk_rq_map_sg
                |
                --- blk_rq_map_sg
                    scsi_init_sgtable
                    scsi_init_io
                    scsi_setup_fs_cmnd
                    sd_prep_fn
                    blk_peek_request
                    scsi_request_fn
                    __blk_run_queue
                    blk_run_queue
                    scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] get_page
                    |
                    --- get_page
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] _raw_spin_lock_irqsave
                |
                --- _raw_spin_lock_irqsave
                   |          
                   |--44.23%-- blk_end_bidi_request
                   |          blk_end_request
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                   |--32.84%-- blk_run_queue
                   |          scsi_run_queue
                   |          scsi_next_command
                   |          scsi_io_completion
                   |          scsi_finish_command
                   |          scsi_softirq_done
                   |          blk_done_softirq
                   |          __do_softirq
                   |          call_softirq
                   |          do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --22.93%-- pm_qos_request
                              menu_select
                              cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] __bio_clone
                    |
                    --- __bio_clone
                        clone_bio
                        __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] sg_next
                    |
                    --- sg_next
                       |          
                       |--36.30%-- ata_qc_issue
                       |          __ata_scsi_queuecmd
                       |          ata_scsi_queuecmd
                       |          scsi_dispatch_cmd
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                       |--32.06%-- swiotlb_map_sg_attrs
                       |          ata_qc_issue
                       |          __ata_scsi_queuecmd
                       |          ata_scsi_queuecmd
                       |          scsi_dispatch_cmd
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --31.64%-- blk_rq_map_sg
                                  scsi_init_sgtable
                                  scsi_init_io
                                  scsi_setup_fs_cmnd
                                  sd_prep_fn
                                  blk_peek_request
                                  scsi_request_fn
                                  __blk_run_queue
                                  queue_unplugged
                                  blk_flush_plug_list
                                  io_schedule
                                  sleep_on_page_killable
                                  __wait_on_bit_lock
                                  __lock_page_killable
                                  lock_page_killable
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] __rcu_read_unlock
                    |
                    --- __rcu_read_unlock
                       |          
                       |--70.72%-- __prop_inc_single
                       |          task_dirty_inc
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --29.28%-- avc_has_perm_noaudit
                                  task_has_capability
                                  selinux_capable
                                  security_capable
                                  ns_capable
                                  capable
                                  setattr_copy
                                  ext4_setattr
                                  notify_change
                                  sys_fchmod
                                  system_call_fastpath
                                  __GI___fchmod

     0.01%          tar  [kernel.kallsyms]    [k] _raw_spin_unlock
                    |
                    --- _raw_spin_unlock
                       |          
                       |--36.11%-- smp_apic_timer_interrupt
                       |          apic_timer_interrupt
                       |          __find_get_block_slow
                       |          unmap_underlying_metadata
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                       |--34.75%-- scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --29.14%-- __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] generic_file_aio_read
                    |
                    --- generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] map_bh
                    |
                    --- map_bh
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] memcmp
                    |
                    --- memcmp
                       |          
                       |--67.73%-- ext4_dx_find_entry
                       |          ext4_find_entry
                       |          ext4_lookup
                       |          d_alloc_and_lookup
                       |          __lookup_hash.part.3
                       |          lookup_hash
                       |          do_last
                       |          path_openat
                       |          do_filp_open
                       |          do_sys_open
                       |          sys_openat
                       |          system_call_fastpath
                       |          __GI___openat
                       |          
                        --32.27%-- search_dirblock
                                  ext4_dx_find_entry
                                  ext4_find_entry
                                  ext4_unlink
                                  vfs_unlink
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.01%      swapper  [kernel.kallsyms]    [k] test_ti_thread_flag
                |
                --- test_ti_thread_flag
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] clone_endio
                |
                --- clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] __slab_free
                |
                --- __slab_free
                    kmem_cache_free
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] nr_iowait_cpu
                |
                --- nr_iowait_cpu
                    tick_nohz_stop_idle
                    tick_check_idle
                    irq_enter
                    smp_call_function_single_interrupt
                    call_function_single_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.01%      swapper  [kernel.kallsyms]    [k] timekeeping_get_ns
                |
                --- timekeeping_get_ns
                    getnstimeofday
                    ktime_get_real
                    intel_idle
                    cpuidle_idle_call
                    cpu_idle
                    start_secondary

     0.01%  flush-253:2  [kernel.kallsyms]    [k] crc16
            |
            --- crc16
                ext4_group_desc_csum
                ext4_mb_mark_diskspace_used
                ext4_mb_new_blocks
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] ata_scsi_queuecmd
                    |
                    --- ata_scsi_queuecmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] jbd2_journal_put_journal_head
                    |
                    --- jbd2_journal_put_journal_head
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                       |          
                       |--60.89%-- generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --39.11%-- ext4_free_blocks
                                  ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] ext4_da_write_end
                    |
                    --- ext4_da_write_end
                       |          
                       |--68.79%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --31.21%-- __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] acct_update_integrals
                    |
                    --- acct_update_integrals
                        __account_system_time
                        irqtime_account_process_tick
                        account_process_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                       |          
                       |--51.45%-- get_parent_ip
                       |          add_preempt_count
                       |          __lru_cache_add
                       |          add_to_page_cache_lru
                       |          mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --48.55%-- find_get_page
                                  __find_get_block_slow
                                  __find_get_block
                                  ext4_free_blocks
                                  ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] __inc_zone_page_state
                    |
                    --- __inc_zone_page_state
                       |          
                       |--61.16%-- account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --38.84%-- add_to_page_cache_locked
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] account_idle_time
                |
                --- account_idle_time
                    account_idle_ticks
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] recalc_bh_state
                    |
                    --- recalc_bh_state
                       |          
                       |--62.12%-- alloc_buffer_head
                       |          alloc_page_buffers
                       |          create_empty_buffers
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --37.88%-- alloc_page_buffers
                                  create_empty_buffers
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] put_page_testzero
                |
                --- put_page_testzero
                    put_page
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] generic_segment_checks
                    |
                    --- generic_segment_checks
                       |          
                       |--56.32%-- generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --43.68%-- __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] arch_local_irq_save
                |
                --- arch_local_irq_save
                    __free_pages
                    __free_slab
                    discard_slab
                    __slab_free
                    kmem_cache_free
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] rw_verify_area
                    |
                    --- rw_verify_area
                       |          
                       |--65.20%-- vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --34.80%-- vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] file_update_time
                    |
                    --- file_update_time
                       |          
                       |--70.97%-- __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --29.03%-- generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%  flush-253:2  [kernel.kallsyms]    [k] alloc_tio
            |
            --- alloc_tio
                dm_request
                generic_make_request
                submit_bio
                ext4_io_submit
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] __mark_inode_dirty
                    |
                    --- __mark_inode_dirty
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] _raw_spin_unlock_irqrestore
                    |
                    --- _raw_spin_unlock_irqrestore
                        __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] jbd2_journal_cancel_revoke
                    |
                    --- jbd2_journal_cancel_revoke
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] lookup_page_cgroup
                    |
                    --- lookup_page_cgroup
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--53.32%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --46.68%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] _raw_spin_unlock_irq
                    |
                    --- _raw_spin_unlock_irq
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--69.09%-- mpage_readpages
                       |          ext4_readpages
                       |          __do_page_cache_readahead
                       |          ra_submit
                       |          ondemand_readahead
                       |          page_cache_async_readahead
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --30.91%-- grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __do_page_cache_readahead
                    |
                    --- __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] ext4_acl_chmod
                    |
                    --- ext4_acl_chmod
                        notify_change
                        sys_fchmod
                        system_call_fastpath
                        __GI___fchmod

     0.01%  flush-253:2  [kernel.kallsyms]    [k] start_this_handle
            |
            --- start_this_handle
                jbd2__journal_start
                jbd2_journal_start
                ext4_journal_start_sb
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] _raw_read_lock
                    |
                    --- _raw_read_lock
                       |          
                       |--56.63%-- start_this_handle
                       |          jbd2__journal_start
                       |          jbd2_journal_start
                       |          ext4_journal_start_sb
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --43.37%-- jbd2__journal_start
                                  jbd2_journal_start
                                  ext4_journal_start_sb
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] mix_pool_bytes_extract
                |
                --- mix_pool_bytes_extract
                    add_timer_randomness
                    add_disk_randomness
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] system_call_after_swapgs
                    |
                    --- system_call_after_swapgs
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] ext4_claim_free_blocks
                    |
                    --- ext4_claim_free_blocks
                       |          
                       |--53.08%-- __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --46.92%-- ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] sys_write
                    |
                    --- sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] mcount
                    |
                    --- mcount
                       |          
                       |--52.17%-- radix_tree_preload_end
                       |          add_to_page_cache_locked
                       |          add_to_page_cache_lru
                       |          grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.83%-- _raw_spin_unlock
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] pagevec_lru_move_fn
                    |
                    --- pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] jbd2_journal_add_journal_head
                    |
                    --- jbd2_journal_add_journal_head
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __block_commit_write
                    |
                    --- __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] virt_to_head_page
                    |
                    --- virt_to_head_page
                       |          
                       |--57.98%-- kmem_cache_free
                       |          jbd2_journal_stop
                       |          __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --42.02%-- jbd2_journal_stop
                                  __ext4_journal_stop
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] mb_test_bit
                    |
                    --- mb_test_bit
                       |          
                       |--53.79%-- ext4_free_blocks
                       |          ext4_ext_truncate
                       |          ext4_truncate
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                        --46.21%-- mb_free_blocks
                                  ext4_free_blocks
                                  ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] atomic_inc
                    |
                    --- atomic_inc
                       |          
                       |--57.00%-- ext4_mark_iloc_dirty
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --43.00%-- ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ahci_qc_prep
                    |
                    --- ahci_qc_prep
                       |          
                       |--56.69%-- __ata_scsi_queuecmd
                       |          ata_scsi_queuecmd
                       |          scsi_dispatch_cmd
                       |          scsi_request_fn
                       |          __blk_run_queue
                       |          queue_unplugged
                       |          blk_flush_plug_list
                       |          io_schedule
                       |          sleep_on_page_killable
                       |          __wait_on_bit_lock
                       |          __lock_page_killable
                       |          lock_page_killable
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --43.31%-- ata_qc_issue
                                  __ata_scsi_queuecmd
                                  ata_scsi_queuecmd
                                  scsi_dispatch_cmd
                                  scsi_request_fn
                                  __blk_run_queue
                                  queue_unplugged
                                  blk_flush_plug_list
                                  io_schedule
                                  sleep_on_page_killable
                                  __wait_on_bit_lock
                                  __lock_page_killable
                                  lock_page_killable
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] generic_write_end
                    |
                    --- generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] iov_iter_fault_in_readable
                    |
                    --- iov_iter_fault_in_readable
                       |          
                       |--51.45%-- generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --48.55%-- __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] inode_reserved_space
                    |
                    --- inode_reserved_space
                       |          
                       |--54.74%-- inode_add_rsv_space
                       |          __dquot_alloc_space
                       |          ext4_da_get_block_prep
                       |          __block_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --45.26%-- __dquot_alloc_space
                                  ext4_da_get_block_prep
                                  __block_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] update_curr
                    |
                    --- update_curr
                        dequeue_task_fair
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] atomic_sub
                    |
                    --- atomic_sub
                       |          
                       |--56.22%-- __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --43.78%-- jbd2_journal_stop
                                  __ext4_journal_stop
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_get_inode_flags
                    |
                    --- ext4_get_inode_flags
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] prop_norm_single
                    |
                    --- prop_norm_single
                       |          
                       |--55.85%-- task_dirty_inc
                       |          account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --44.15%-- __prop_inc_single
                                  task_dirty_inc
                                  account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] jbd_unlock_bh_state
                    |
                    --- jbd_unlock_bh_state
                       |          
                       |--50.48%-- jbd2_journal_dirty_metadata
                       |          __ext4_handle_dirty_metadata
                       |          ext4_mark_iloc_dirty
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --49.52%-- do_get_write_access
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] arch_local_irq_disable
                    |
                    --- arch_local_irq_disable
                        arch_local_irq_save
                        _raw_spin_lock_irqsave
                       |          
                       |--65.53%-- __wake_up
                       |          jbd2_journal_stop
                       |          __ext4_journal_stop
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --34.47%-- pagevec_lru_move_fn
                                  ____pagevec_lru_add
                                  __lru_cache_add
                                  add_to_page_cache_lru
                                  grab_cache_page_write_begin
                                  ext4_da_write_begin
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __generic_file_aio_write
                    |
                    --- __generic_file_aio_write
                       |          
                       |--53.33%-- generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --46.67%-- ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] test_and_set_bit
                    |
                    --- test_and_set_bit
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%  flush-253:2  [kernel.kallsyms]    [k] _raw_read_lock_irqsave
            |
            --- _raw_read_lock_irqsave
                dm_merge_bvec
                __bio_add_page.part.2
                bio_add_page
                ext4_bio_write_page
                mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] __find_get_block
                    |
                    --- __find_get_block
                        __getblk
                        __ext4_get_inode_loc
                        ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                       |          
                       |--64.27%-- file_update_time
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --35.73%-- generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __split_and_process_bio
                    |
                    --- __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] memcg_check_events
                    |
                    --- memcg_check_events
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                       |          
                       |--52.26%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.74%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] xattr_resolve_name
                    |
                    --- xattr_resolve_name
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%  kworker/0:2  [kernel.kallsyms]    [k] bit_cursor
            |
            --- bit_cursor
                fb_flashcursor
                process_one_work
                worker_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] __set_page_dirty
                    |
                    --- __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_file_write
                    |
                    --- ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] bit_spin_unlock
                    |
                    --- bit_spin_unlock
                        jbd2_journal_put_journal_head
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] fget_light
                    |
                    --- fget_light
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%  flush-253:2  [kernel.kallsyms]    [k] ext4_clear_inode_state
            |
            --- ext4_clear_inode_state
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%      swapper  [kernel.kallsyms]    [k] ahci_scr_read
                |
                --- ahci_scr_read
                    sata_scr_read
                    sata_async_notification
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] add_to_page_cache_lru
                    |
                    --- add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] arch_local_save_flags
                |
                --- arch_local_save_flags
                    _local_bh_enable
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] current_fs_time
                    |
                    --- current_fs_time
                       |          
                       |--50.34%-- touch_atime
                       |          generic_file_aio_read
                       |          do_sync_read
                       |          vfs_read
                       |          sys_read
                       |          system_call_fastpath
                       |          __GI___libc_read
                       |          
                        --49.66%-- file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] need_resched
                    |
                    --- need_resched
                        _cond_resched
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] mb_clear_bit
                    |
                    --- mb_clear_bit
                       |          
                       |--57.54%-- ext4_free_blocks
                       |          ext4_ext_truncate
                       |          ext4_truncate
                       |          ext4_evict_inode
                       |          evict
                       |          iput
                       |          do_unlinkat
                       |          sys_unlinkat
                       |          system_call_fastpath
                       |          unlinkat
                       |          
                        --42.46%-- mb_free_blocks
                                  ext4_free_blocks
                                  ext4_ext_truncate
                                  ext4_truncate
                                  ext4_evict_inode
                                  evict
                                  iput
                                  do_unlinkat
                                  sys_unlinkat
                                  system_call_fastpath
                                  unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] __list_add
                    |
                    --- __list_add
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] task_dirty_inc
                    |
                    --- task_dirty_inc
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] vfs_read
                    |
                    --- vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] bit_spin_lock
                    |
                    --- bit_spin_lock
                       |          
                       |--55.69%-- jbd2_journal_get_write_access
                       |          __ext4_journal_get_write_access
                       |          ext4_reserve_inode_write
                       |          ext4_mark_inode_dirty
                       |          ext4_dirty_inode
                       |          __mark_inode_dirty
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --44.31%-- jbd2_journal_add_journal_head
                                  jbd2_journal_get_write_access
                                  __ext4_journal_get_write_access
                                  ext4_reserve_inode_write
                                  ext4_mark_inode_dirty
                                  ext4_dirty_inode
                                  __mark_inode_dirty
                                  file_update_time
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] paravirt_read_tsc
                |
                --- paravirt_read_tsc
                    read_tsc
                    timekeeping_get_ns
                    ktime_get
                    tick_nohz_stop_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] irq_entries_start
                |
                --- irq_entries_start
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] iov_iter_copy_from_user_atomic
                    |
                    --- iov_iter_copy_from_user_atomic
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] clear_buffer_new
                    |
                    --- clear_buffer_new
                       |          
                       |--57.80%-- __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --42.20%-- block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] _raw_read_lock_irqsave
                    |
                    --- _raw_read_lock_irqsave
                        dm_get_live_table
                        dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] __prop_inc_single
                    |
                    --- __prop_inc_single
                       |          
                       |--52.30%-- account_page_dirtied
                       |          __set_page_dirty
                       |          mark_buffer_dirty
                       |          __block_commit_write
                       |          block_write_end
                       |          generic_write_end
                       |          ext4_da_write_end
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --47.70%-- task_dirty_inc
                                  account_page_dirtied
                                  __set_page_dirty
                                  mark_buffer_dirty
                                  __block_commit_write
                                  block_write_end
                                  generic_write_end
                                  ext4_da_write_end
                                  generic_file_buffered_write
                                  __generic_file_aio_write
                                  generic_file_aio_write
                                  ext4_file_write
                                  do_sync_write
                                  vfs_write
                                  sys_write
                                  system_call_fastpath
                                  __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] dm_merge_bvec
                    |
                    --- dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] menu_select
                |
                --- menu_select
                   |          
                   |--59.21%-- cpu_idle
                   |          rest_init
                   |          start_kernel
                   |          x86_64_start_reservations
                   |          x86_64_start_kernel
                   |          
                    --40.79%-- cpuidle_idle_call
                              cpu_idle
                              rest_init
                              start_kernel
                              x86_64_start_reservations
                              x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] scsi_decide_disposition
                |
                --- scsi_decide_disposition
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] bit_spin_trylock.constprop.23
                    |
                    --- bit_spin_trylock.constprop.23
                        get_partial_node
                        __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] exit_idle
                |
                --- exit_idle
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%  flush-253:2  [kernel.kallsyms]    [k] mpage_da_submit_io
            |
            --- mpage_da_submit_io
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%      swapper  [kernel.kallsyms]    [k] do_raw_spin_lock
                |
                --- do_raw_spin_lock
                    _raw_spin_lock_irq
                    schedule
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] get_cwq
                    |
                    --- get_cwq
                        __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        _raw_spin_lock
                        inode_add_rsv_space
                        __dquot_alloc_space
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ____pagevec_lru_add_fn
                    |
                    --- ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                       |          
                       |--57.19%-- grab_cache_page_write_begin
                       |          ext4_da_write_begin
                       |          generic_file_buffered_write
                       |          __generic_file_aio_write
                       |          generic_file_aio_write
                       |          ext4_file_write
                       |          do_sync_write
                       |          vfs_write
                       |          sys_write
                       |          system_call_fastpath
                       |          __GI___libc_write
                       |          
                        --42.81%-- mpage_readpages
                                  ext4_readpages
                                  __do_page_cache_readahead
                                  ra_submit
                                  ondemand_readahead
                                  page_cache_async_readahead
                                  generic_file_aio_read
                                  do_sync_read
                                  vfs_read
                                  sys_read
                                  system_call_fastpath
                                  __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] alloc_buffer_head
                    |
                    --- alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] generic_make_request
                    |
                    --- generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] rcu_irq_enter
                |
                --- rcu_irq_enter
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%      swapper  [kernel.kallsyms]    [k] leave_mm
                |
                --- leave_mm
                    intel_idle
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] __lru_cache_add
                    |
                    --- __lru_cache_add
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  libc-2.13.90.so      [.] __GI___libc_write
                    |
                    --- __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] task_rq_lock
                |
                --- task_rq_lock
                    try_to_wake_up
                    wake_up_process
                    wake_up_worker
                    insert_work
                    __queue_work
                    delayed_work_timer_fn
                    run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] __elv_add_request
                    |
                    --- __elv_add_request
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] may_link
                    |
                    --- may_link
                        selinux_inode_unlink
                        security_inode_unlink
                        vfs_unlink
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] __find_get_block_slow
                    |
                    --- __find_get_block_slow
                        unmap_underlying_metadata
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] radix_tree_tag_set
                    |
                    --- radix_tree_tag_set
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%  flush-253:2  [kernel.kallsyms]    [k] do_raw_spin_lock
            |
            --- do_raw_spin_lock
                _raw_spin_lock
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] delayacct_blkio_start
                    |
                    --- delayacct_blkio_start
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] current_umask
                    |
                    --- current_umask
                        ext4_init_acl
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.01%          tar  [kernel.kallsyms]    [k] linear_merge
                    |
                    --- linear_merge
                        dm_merge_bvec
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%  flush-253:2  [kernel.kallsyms]    [k] get_parent_ip
            |
            --- get_parent_ip
                _raw_spin_lock
                ext4_discard_preallocations
                ext4_da_update_reserve_space
                ext4_ext_map_blocks
                ext4_map_blocks
                mpage_da_map_and_submit
                ext4_da_writepages
                do_writepages
                writeback_single_inode
                writeback_sb_inodes
                writeback_inodes_wb
                wb_writeback
                wb_do_writeback
                bdi_writeback_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] __blk_run_queue
                    |
                    --- __blk_run_queue
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] __page_cache_alloc
                    |
                    --- __page_cache_alloc
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] arch_local_irq_restore
                |
                --- arch_local_irq_restore
                    account_system_vtime
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] ext4_new_inode
                    |
                    --- ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.01%          tar  [kernel.kallsyms]    [k] __slab_alloc
                    |
                    --- __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_ext_calc_metadata_amount
                    |
                    --- ext4_ext_calc_metadata_amount
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] task_of
                    |
                    --- task_of
                        dequeue_task_fair
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] tick_program_event
                |
                --- tick_program_event
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%         perf  [kernel.kallsyms]    [k] __wake_up_bit
                   |
                   --- __wake_up_bit
                       unlock_page
                       generic_write_end
                       ext4_da_write_end
                       generic_file_buffered_write
                       __generic_file_aio_write
                       generic_file_aio_write
                       ext4_file_write
                       do_sync_write
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.01%         perf  [kernel.kallsyms]    [k] generic_write_end
                   |
                   --- generic_write_end
                       ext4_da_write_end
                       generic_file_buffered_write
                       __generic_file_aio_write
                       generic_file_aio_write
                       ext4_file_write
                       do_sync_write
                       vfs_write
                       sys_write
                       system_call_fastpath
                       __write_nocancel
                       0x4191c6
                       0x40f7a9
                       0x40ef8c
                       __libc_start_main

     0.01%  kworker/0:2  [kernel.kallsyms]    [k] native_read_msr_safe
            |
            --- native_read_msr_safe
                acpi_cpufreq_init
                do_drv_write
                acpi_cpufreq_target
                __cpufreq_driver_target
                do_dbs_timer
                process_one_work
                worker_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] kmem_cache_free
                    |
                    --- kmem_cache_free
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_journal_start_sb
                    |
                    --- ext4_journal_start_sb
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_get_inode_loc
                    |
                    --- ext4_get_inode_loc
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] __mem_cgroup_try_charge.constprop.27
                    |
                    --- __mem_cgroup_try_charge.constprop.27
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] hrtick_update
                |
                --- hrtick_update
                    enqueue_task
                    activate_task
                    try_to_wake_up
                    wake_up_process
                    wake_up_worker
                    insert_work
                    __queue_work
                    delayed_work_timer_fn
                    run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] mem_cgroup_get_reclaim_stat_from_page
                    |
                    --- mem_cgroup_get_reclaim_stat_from_page
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] bio_endio
                |
                --- bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] kfree
                    |
                    --- kfree
                        jbd2__journal_start
                        jbd2_journal_start
                        ext4_journal_start_sb
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_free_blocks
                    |
                    --- ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] ext4_test_inode_flag
                    |
                    --- ext4_test_inode_flag
                        ext4_map_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%      swapper  [kernel.kallsyms]    [k] scsi_run_queue
                |
                --- scsi_run_queue
                    scsi_next_command
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%  kworker/0:2  [cpufreq_ondemand]   [k] do_dbs_timer
            |
            --- do_dbs_timer
                worker_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] alloc_page_buffers
                    |
                    --- alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] linear_map
                    |
                    --- linear_map
                        __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%      swapper  [kernel.kallsyms]    [k] test_ti_thread_flag.constprop.7
                |
                --- test_ti_thread_flag.constprop.7
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.01%          tar  [kernel.kallsyms]    [k] delayacct_blkio_end
                    |
                    --- delayacct_blkio_end
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.01%          tar  [kernel.kallsyms]    [k] inode_permission
                    |
                    --- inode_permission
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.01%  kworker/0:2  [kernel.kallsyms]    [k] kobject_get
            |
            --- kobject_get
                __cpufreq_driver_getavg
                do_dbs_timer
                process_one_work
                worker_thread
                kthread
                kernel_thread_helper

     0.01%          tar  [kernel.kallsyms]    [k] __wake_up_common
                    |
                    --- __wake_up_common
                        __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_dirty_inode
                        __mark_inode_dirty
                        file_update_time
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.01%          tar  [kernel.kallsyms]    [k] ext4_read_inode_bitmap
                    |
                    --- ext4_read_inode_bitmap
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.01%          tar  [kernel.kallsyms]    [k] mnt_add_count
                    |
                    --- mnt_add_count
                        mntget
                        path_get
                        nameidata_to_filp
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.01%          tar  [kernel.kallsyms]    [k] schedule
                    |
                    --- schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] try_to_wake_up
                |
                --- try_to_wake_up
                    wake_up_process
                    wake_up_worker
                    insert_work
                    __queue_work
                    delayed_work_timer_fn
                    run_timer_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] inode_doinit_with_dentry
                    |
                    --- inode_doinit_with_dentry
                        selinux_d_instantiate
                        security_d_instantiate
                        d_instantiate
                        ext4_add_nondir
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.00%          tar  [kernel.kallsyms]    [k] radix_tree_preload
                    |
                    --- radix_tree_preload
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] __mod_zone_page_state
                    |
                    --- __mod_zone_page_state
                        add_page_to_lru_list
                        ____pagevec_lru_add_fn
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] unmap_single
                |
                --- unmap_single
                    swiotlb_unmap_sg_attrs
                    ata_sg_clean
                    __ata_qc_complete
                    ata_qc_complete
                    ata_qc_complete_multiple
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  libc-2.13.90.so      [.] _int_malloc
                    |
                    --- _int_malloc

     0.00%          tar  [kernel.kallsyms]    [k] ext4_test_inode_state
                    |
                    --- ext4_test_inode_state
                        ext4_xattr_get
                        ext4_xattr_security_get
                        generic_getxattr
                        cap_inode_need_killpriv
                        security_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] test_ti_thread_flag.constprop.6
                    |
                    --- test_ti_thread_flag.constprop.6
                        __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] __ext4_handle_dirty_metadata
                    |
                    --- __ext4_handle_dirty_metadata
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] queue_unplugged
                    |
                    --- queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] mutex_lock
                    |
                    --- mutex_lock
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] crc16
                    |
                    --- crc16
                        ext4_group_desc_csum
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.00%          tar  [kernel.kallsyms]    [k] lock_page_killable
                    |
                    --- lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] lock_page
                    |
                    --- lock_page
                        find_lock_page
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] balance_dirty_pages_ratelimited_nr
                    |
                    --- balance_dirty_pages_ratelimited_nr
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] setup_object
                    |
                    --- setup_object
                        new_slab
                        __slab_alloc
                        kmem_cache_alloc
                        alloc_buffer_head
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] sd_prep_fn
                    |
                    --- sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] system_call_fastpath
                    |
                    --- system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] unlock_page
                    |
                    --- unlock_page
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] blk_throtl_bio
                    |
                    --- blk_throtl_bio
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] ihold
                    |
                    --- ihold
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.00%          tar  [kernel.kallsyms]    [k] mb_find_buddy
                    |
                    --- mb_find_buddy
                        mb_free_blocks
                        ext4_free_blocks
                        ext4_ext_truncate
                        ext4_truncate
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.00%          tar  [kernel.kallsyms]    [k] jbd2_journal_get_write_access
                    |
                    --- jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] _raw_spin_unlock
                |
                --- _raw_spin_unlock
                    scheduler_tick
                    update_process_times
                    tick_sched_timer
                    __run_hrtimer
                    hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] bit_spin_unlock
                    |
                    --- bit_spin_unlock
                        unlock_page_cgroup
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] fput_light
                    |
                    --- fput_light
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] audit_inode.constprop.6
                    |
                    --- audit_inode.constprop.6
                        system_call_fastpath
                        __GI___fchown

     0.00%          tar  [kernel.kallsyms]    [k] ext4_test_inode_state
                    |
                    --- ext4_test_inode_state
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] system_call
                    |
                    --- system_call
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] ktime_get
                |
                --- ktime_get
                    tick_check_idle
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] radix_tree_lookup_slot
                    |
                    --- radix_tree_lookup_slot
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] apic_timer_interrupt
                    |
                    --- apic_timer_interrupt
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] __rcu_read_lock
                    |
                    --- __rcu_read_lock
                        __prop_inc_single
                        task_dirty_inc
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] arch_local_irq_enable
                    |
                    --- arch_local_irq_enable
                        _raw_spin_unlock_irq
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] file_read_actor
                    |
                    --- file_read_actor
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] dquot_active
                    |
                    --- dquot_active
                        __dquot_alloc_space
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%        sleep  [kernel.kallsyms]    [k] tlb_gather_mmu
                  |
                  --- tlb_gather_mmu
                      mmput
                      exit_mm
                      do_exit
                      do_group_exit
                      __wake_up_parent
                      system_call_fastpath

     0.00%          tar  [kernel.kallsyms]    [k] test_ti_thread_flag
                    |
                    --- test_ti_thread_flag
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] bvec_free_bs
                |
                --- bvec_free_bs
                    dm_bio_destructor
                    bio_put
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] ktime_get_real
                |
                --- ktime_get_real
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] generic_write_sync
                    |
                    --- generic_write_sync
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] _raw_spin_lock_irq
                    |
                    --- _raw_spin_lock_irq
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] posix_acl_release
                    |
                    --- posix_acl_release
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.00%          tar  [kernel.kallsyms]    [k] ext4_dirty_inode
                    |
                    --- ext4_dirty_inode
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] test_clear_page_writeback
                |
                --- test_clear_page_writeback
                    end_page_writeback
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] deadline_dispatch_requests
                    |
                    --- deadline_dispatch_requests
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] deadline_move_request
                    |
                    --- deadline_move_request
                        deadline_dispatch_requests
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%  kworker/0:2  [kernel.kallsyms]    [k] schedule
            |
            --- schedule
                worker_thread
                kthread
                kernel_thread_helper

     0.00%          tar  [kernel.kallsyms]    [k] blk_start_plug
                    |
                    --- blk_start_plug
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] set_buffer_uptodate
                    |
                    --- set_buffer_uptodate
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] strncpy_from_user
                    |
                    --- strncpy_from_user
                        getname
                        user_path_parent
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.00%          tar  [kernel.kallsyms]    [k] atomic_inc
                    |
                    --- atomic_inc
                        drive_stat_acct
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] update_curr
                |
                --- update_curr
                    enqueue_task_fair
                    enqueue_task
                    activate_task
                    try_to_wake_up
                    default_wake_function
                    autoremove_wake_function
                    wake_bit_function
                    __wake_up_common
                    __wake_up
                    __wake_up_bit
                    unlock_page
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] debug_smp_processor_id
                |
                --- debug_smp_processor_id
                    rcu_process_callbacks
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] page_cache_async_readahead
                    |
                    --- page_cache_async_readahead
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] bvec_alloc_bs
                    |
                    --- bvec_alloc_bs
                        clone_bio
                        __split_and_process_bio
                        dm_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] page_mapping
                |
                --- page_mapping
                    test_clear_page_writeback
                    end_page_writeback
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] kmem_cache_free
                |
                --- kmem_cache_free
                    mempool_free_slab
                    mempool_free
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] prop_norm_percpu
                |
                --- prop_norm_percpu
                    __prop_inc_percpu_max
                    test_clear_page_writeback
                    end_page_writeback
                    put_io_page
                    ext4_end_bio
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] sg_init_table
                    |
                    --- sg_init_table
                        scsi_alloc_sgtable
                        scsi_init_sgtable
                        scsi_init_io
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] atomic_inc
                    |
                    --- atomic_inc
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] bit_waitqueue
                    |
                    --- bit_waitqueue
                        wake_up_bit
                        unlock_buffer
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] apic_write
                |
                --- apic_write
                    ack_APIC_irq
                    ack_apic_edge
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] native_write_msr_safe
                |
                --- native_write_msr_safe

     0.00%      swapper  [kernel.kallsyms]    [k] req_bio_endio
                |
                --- req_bio_endio
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] __wake_up
                    |
                    --- __wake_up
                        jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] mem_cgroup_disabled
                    |
                    --- mem_cgroup_disabled
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] __make_request
                    |
                    --- __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] tick_check_oneshot_broadcast
                |
                --- tick_check_oneshot_broadcast
                    tick_check_idle
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] raise_softirq
                    |
                    --- raise_softirq
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        radix_tree_preload_end
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] ext4_setattr
                    |
                    --- ext4_setattr
                        notify_change
                        utimes_common
                        do_utimes
                        sys_utimensat
                        system_call_fastpath
                        futimens

     0.00%      swapper  [kernel.kallsyms]    [k] native_sched_clock
                |
                --- native_sched_clock
                    sched_clock_cpu
                    account_system_vtime
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%      swapper  [kernel.kallsyms]    [k] read_tsc
                |
                --- read_tsc
                    timekeeping_get_ns
                    ktime_get
                    tick_check_idle
                    irq_enter
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] cap_inode_need_killpriv
                    |
                    --- cap_inode_need_killpriv
                        file_remove_suid
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] __cycles_2_ns
                    |
                    --- __cycles_2_ns
                        native_sched_clock
                        sched_clock
                        blk_rq_init
                        get_request
                        get_request_wait
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] load_balance
                    |
                    --- load_balance
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] read_tsc
                    |
                    --- read_tsc
                        ktime_get_ts
                        delayacct_end
                        __delayacct_blkio_end
                        delayacct_blkio_end
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] scsi_sg_alloc
                    |
                    --- scsi_sg_alloc
                        __sg_alloc_table
                        scsi_alloc_sgtable
                        scsi_init_sgtable
                        scsi_init_io
                        scsi_setup_fs_cmnd
                        sd_prep_fn
                        blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] cpuacct_charge
                    |
                    --- cpuacct_charge
                        update_curr
                        dequeue_task_fair
                        dequeue_task
                        deactivate_task
                        schedule
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] elv_rqhash_add
                    |
                    --- elv_rqhash_add
                        __elv_add_request
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] test_ti_thread_flag.constprop.22
                    |
                    --- test_ti_thread_flag.constprop.22
                        alloc_page_buffers
                        create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] ata_find_dev.part.3
                    |
                    --- ata_find_dev.part.3
                        __ata_scsi_find_dev
                        ata_scsi_find_dev
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] fsnotify
                    |
                    --- fsnotify
                        fsnotify_modify
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%  kworker/0:2  [kernel.kallsyms]    [k] ns_to_timeval
            |
            --- ns_to_timeval
                get_cpu_iowait_time_us
                do_dbs_timer
                process_one_work
                worker_thread
                kthread
                kernel_thread_helper

     0.00%          tar  [kernel.kallsyms]    [k] expand
                    |
                    --- expand
                        __rmqueue
                        get_page_from_freelist
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] preempt_schedule
                |
                --- preempt_schedule
                    blk_finish_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] max_io_len
                    |
                    --- max_io_len
                        __bio_add_page.part.2
                        bio_add_page
                        do_mpage_readpage
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] release_pages
                    |
                    --- release_pages
                        pagevec_lru_move_fn
                        ____pagevec_lru_add
                        __lru_cache_add
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] irqtime_account_process_tick
                    |
                    --- irqtime_account_process_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] atomic_long_add
                    |
                    --- atomic_long_add
                        zone_page_state_add
                        __inc_zone_state
                        __inc_zone_page_state
                        account_page_dirtied
                        __set_page_dirty
                        mark_buffer_dirty
                        __block_commit_write
                        block_write_end
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] zone_statistics
                    |
                    --- zone_statistics
                        __alloc_pages_nodemask
                        alloc_pages_current
                        __page_cache_alloc
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] str2hashbuf_signed
                    |
                    --- str2hashbuf_signed
                        ext4fs_dirhash
                        dx_probe
                        ext4_dx_find_entry
                        ext4_find_entry
                        ext4_unlink
                        vfs_unlink
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.00%      swapper  [kernel.kallsyms]    [k] ata_scsi_qc_complete
                |
                --- ata_scsi_qc_complete
                    __ata_qc_complete
                    ata_qc_complete
                    ata_qc_complete_multiple
                    ahci_interrupt
                    handle_irq_event_percpu
                    handle_irq_event
                    handle_edge_irq
                    handle_irq
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] ext4_has_free_blocks
                    |
                    --- ext4_has_free_blocks
                        ext4_da_get_block_prep
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] deadline_add_request
                    |
                    --- deadline_add_request
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] pagefault_enable
                    |
                    --- pagefault_enable
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] deadline_merge
                    |
                    --- deadline_merge
                        elv_merge
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] rb_next
                |
                --- rb_next
                    timerqueue_del
                    __remove_hrtimer
                    remove_hrtimer.part.4
                    hrtimer_try_to_cancel
                    hrtimer_cancel
                    tick_nohz_restart_sched_tick
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] mem_cgroup_cache_charge
                    |
                    --- mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] sched_clock_tick
                |
                --- sched_clock_tick
                    sched_clock_idle_wakeup_event
                    tick_nohz_stop_idle
                    tick_check_idle
                    irq_enter
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] put_bh
                    |
                    --- put_bh
                        __brelse
                        brelse
                        ext4_mark_iloc_dirty
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] get_page
                    |
                    --- get_page
                        __lru_cache_add
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] hashtab_search
                    |
                    --- hashtab_search
                        string_to_context_struct
                        security_context_to_sid_core
                        security_context_to_sid_default
                        inode_doinit_with_dentry
                        selinux_d_instantiate
                        security_d_instantiate
                        d_instantiate
                        d_splice_alias
                        ext4_lookup
                        d_alloc_and_lookup
                        __lookup_hash.part.3
                        lookup_hash
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.00%          tar  [kernel.kallsyms]    [k] ata_qc_new_init
                    |
                    --- ata_qc_new_init
                        __ata_scsi_queuecmd
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] sd_done
                |
                --- sd_done
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%        sleep  [kernel.kallsyms]    [k] get_parent_ip
                  |
                  --- get_parent_ip
                      add_preempt_count
                      get_page_from_freelist
                      __alloc_pages_nodemask
                      alloc_pages_current
                      pte_alloc_one
                      __pte_alloc
                      handle_mm_fault
                      do_page_fault
                      page_fault
                      _dl_vdso_vsym
                      0x7fff16d617f5
                      0x535345535f474458

     0.00%        sleep  [kernel.kallsyms]    [k] policy_zonelist
                  |
                  --- policy_zonelist
                      pte_alloc_one
                      __pte_alloc
                      handle_mm_fault
                      do_page_fault
                      page_fault
                      _dl_init_paths
                      _dl_sysdep_start

     0.00%          tar  [kernel.kallsyms]    [k] find_lock_page
                    |
                    --- find_lock_page
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] lock_buffer
                    |
                    --- lock_buffer
                        do_get_write_access
                        jbd2_journal_get_write_access
                        __ext4_journal_get_write_access
                        ext4_reserve_inode_write
                        ext4_mark_inode_dirty
                        ext4_dirty_inode
                        __mark_inode_dirty
                        generic_write_end
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] _cond_resched
                    |
                    --- _cond_resched
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] ext4_da_write_begin
                    |
                    --- ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] dquot_free_inode
                    |
                    --- dquot_free_inode
                        ext4_free_inode
                        ext4_evict_inode
                        evict
                        iput
                        do_unlinkat
                        sys_unlinkat
                        system_call_fastpath
                        unlinkat

     0.00%          tar  [kernel.kallsyms]    [k] get_request_wait
                    |
                    --- get_request_wait
                        __make_request
                        generic_make_request
                        submit_bio
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%      swapper  [kernel.kallsyms]    [k] __local_bh_enable
                |
                --- __local_bh_enable
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] mutex_unlock
                    |
                    --- mutex_unlock
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%      swapper  [kernel.kallsyms]    [k] hrtimer_interrupt
                |
                --- hrtimer_interrupt
                    smp_apic_timer_interrupt
                    apic_timer_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] create_empty_buffers
                    |
                    --- create_empty_buffers
                        __block_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] radix_tree_preload_end
                    |
                    --- radix_tree_preload_end
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        grab_cache_page_write_begin
                        ext4_da_write_begin
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] ext4_xattr_set_entry
                    |
                    --- ext4_xattr_set_entry
                        ext4_xattr_ibody_set
                        ext4_xattr_set_handle
                        ext4_init_security
                        ext4_new_inode
                        ext4_create
                        vfs_create
                        do_last
                        path_openat
                        do_filp_open
                        do_sys_open
                        sys_openat
                        system_call_fastpath
                        __GI___openat

     0.00%      swapper  [kernel.kallsyms]    [k] SetPageUptodate
                |
                --- SetPageUptodate
                    mpage_end_io
                    bio_endio
                    dec_pending
                    clone_endio
                    bio_endio
                    req_bio_endio
                    blk_update_request
                    blk_update_bidi_request
                    blk_end_bidi_request
                    blk_end_request
                    scsi_io_completion
                    scsi_finish_command
                    scsi_softirq_done
                    blk_done_softirq
                    __do_softirq
                    call_softirq
                    do_softirq
                    irq_exit
                    do_IRQ
                    common_interrupt
                    cpuidle_idle_call
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] mem_cgroup_charge_statistics
                    |
                    --- mem_cgroup_charge_statistics
                        __mem_cgroup_commit_charge.constprop.28
                        __mem_cgroup_commit_charge_lrucare
                        mem_cgroup_cache_charge
                        add_to_page_cache_locked
                        add_to_page_cache_lru
                        mpage_readpages
                        ext4_readpages
                        __do_page_cache_readahead
                        ra_submit
                        ondemand_readahead
                        page_cache_async_readahead
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  libc-2.13.90.so      [.] _int_free
                    |
                    --- _int_free

     0.00%      swapper  [kernel.kallsyms]    [k] schedule
                |
                --- schedule
                    cpu_idle
                    rest_init
                    start_kernel
                    x86_64_start_reservations
                    x86_64_start_kernel

     0.00%          tar  [kernel.kallsyms]    [k] sysret_check
                    |
                    --- sysret_check
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] blk_peek_request
                    |
                    --- blk_peek_request
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] ata_scsi_rw_xlat
                    |
                    --- ata_scsi_rw_xlat
                        ata_scsi_queuecmd
                        scsi_dispatch_cmd
                        scsi_request_fn
                        __blk_run_queue
                        queue_unplugged
                        blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] blk_flush_plug_list
                    |
                    --- blk_flush_plug_list
                        io_schedule
                        sleep_on_page_killable
                        __wait_on_bit_lock
                        __lock_page_killable
                        lock_page_killable
                        generic_file_aio_read
                        do_sync_read
                        vfs_read
                        sys_read
                        system_call_fastpath
                        __GI___libc_read

     0.00%          tar  [kernel.kallsyms]    [k] jbd2_journal_stop
                    |
                    --- jbd2_journal_stop
                        __ext4_journal_stop
                        ext4_da_write_end
                        generic_file_buffered_write
                        __generic_file_aio_write
                        generic_file_aio_write
                        ext4_file_write
                        do_sync_write
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write

     0.00%          tar  [kernel.kallsyms]    [k] __srcu_read_lock
                    |
                    --- __srcu_read_lock
                        fsnotify
                        fsnotify_modify
                        vfs_write
                        sys_write
                        system_call_fastpath
                        __GI___libc_write



#
# (For a higher level overview, try: perf report --sort comm,dso)
#


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
