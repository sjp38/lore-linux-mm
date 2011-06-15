Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 03BF96B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:29:21 -0400 (EDT)
Subject: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 14 Jun 2011 17:29:58 -0700
Message-ID: <1308097798.17300.142.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

It seems like that the recent changes to make the anon_vma->lock into a
mutex (commit 2b575eb6) causes a 52% regression in throughput (2.6.39 vs
3.0-rc2) on exim mail server workload in the MOSBENCH test suite.

Our test setup is on a 4 socket Westmere EX system, with 10 cores per
socket.  40 clients are created on the test machine which send email
to the exim server residing on the sam test machine.

Exim forks off child processes to handle the incoming mail, and the
process exits after the mail delivery completes. We see quite a bit of
acquisition of the anon_vma->lock as a result.  

On 2.6.39, the contention of anon_vma->lock occupies 3.25% of cpu.
However, after the switch of the lock to mutex on 3.0-rc2, the mutex
acquisition jumps to 18.6% of cpu.  This seems to be the main cause of
the 52% throughput regression.

Other workloads which have a lot of forks/exits may be similarly
affected by this regression.  Workloads which are vm lock intensive
could be affected too.

I've listed the profile of 3.0-rc2 and 2.6.39 below for comparison.

Thanks.

Tim


---------------------------
3.0-rc2 profile:

-     18.60%          exim  [kernel.kallsyms]        [k] __mutex_lock_common.clone.5 
   - __mutex_lock_common.clone.5                                                     
      - 99.99% __mutex_lock_slowpath                                                 
         - mutex_lock                                                                
            - 99.54% anon_vma_lock.clone.10                                          
               + 38.99% anon_vma_clone                                               
               + 37.56% unlink_anon_vmas                                             
               + 11.92% anon_vma_fork                                                
               + 11.53% anon_vma_free                                                
+      4.03%          exim  [kernel.kallsyms]        [k] _raw_spin_lock_irqsave      
-      3.00%          exim  [kernel.kallsyms]        [k] do_raw_spin_lock            
   - do_raw_spin_lock                                                                
      - 94.11% _raw_spin_lock                                                        
         + 47.32% __mutex_lock_common.clone.5                                        
         + 14.23% __mutex_unlock_slowpath                                            
         + 4.06% handle_pte_fault                                                    
         + 3.81% __do_fault                                                          
         + 3.16% unmap_vmas                                                          
         + 2.46% lock_flocks                                                         
         + 2.43% copy_pte_range                                                      
         + 2.28% __task_rq_lock                                                      
         + 1.30% __percpu_counter_add                                                
         + 1.30% dput                                                                
         + 1.27% add_partial                                                         
         + 1.24% free_pcppages_bulk                                                  
         + 1.07% d_alloc                                                             
         + 1.07% get_page_from_freelist                                              
         + 1.02% complete_walk                                                       
         + 0.89% dget                                                                
         + 0.71% new_inode                                                           
         + 0.61% __mod_timer                                                         
         + 0.58% dup_fd                                                              
         + 0.50% double_rq_lock                                                      
      + 3.66% _raw_spin_lock_irq                                                     
      + 0.87% _raw_spin_lock_bh                                                      
+      2.90%          exim  [kernel.kallsyms]        [k] page_fault                  
+      2.25%          exim  [kernel.kallsyms]        [k] mutex_unlock     


-----------------------------------

2.6.39 profile:
+      4.84%          exim  [kernel.kallsyms]        [k] page_fault
+      3.83%          exim  [kernel.kallsyms]        [k] clear_page_c
-      3.25%          exim  [kernel.kallsyms]        [k] do_raw_spin_lock
   - do_raw_spin_lock
      - 91.86% _raw_spin_lock
         + 14.16% unlink_anon_vmas
         + 12.54% unlink_file_vma
         + 7.30% anon_vma_clone_batch
         + 6.17% dup_mm
         + 5.77% __do_fault
         + 5.77% __pte_alloc
         + 5.31% lock_flocks
        ...
+      3.22%          exim  [kernel.kallsyms]        [k] unmap_vmas
+      2.27%          exim  [kernel.kallsyms]        [k] page_cache_get_speculative
+      2.02%          exim  [kernel.kallsyms]        [k] copy_page_c
+      1.63%          exim  [kernel.kallsyms]        [k] __list_del_entry
+      1.58%          exim  [kernel.kallsyms]        [k] get_page_from_freelist



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
