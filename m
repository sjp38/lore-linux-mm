Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 28F816B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 16:19:29 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <BANLkTimStT22tA2YkeuYBzarnnWTnMjiKQ@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>
	 <20110615161827.GA11769@tassilo.jf.intel.com>
	 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
	 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
	 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
	 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
	 <1308255972.17300.450.camel@schen9-DESK>
	 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
	 <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
	 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
	 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
	 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
	 <1308310080.2355.19.camel@twins>
	 <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
	 <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
	 <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com>
	 <1308334688.12801.19.camel@laptop> <1308335557.12801.24.camel@laptop>
	 <BANLkTimStT22tA2YkeuYBzarnnWTnMjiKQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Jun 2011 13:19:49 -0700
Message-ID: <1308341989.17300.511.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 2011-06-17 at 11:39 -0700, Linus Torvalds wrote:

> Having gone over it a bit more, I actually think I prefer to just
> special-case the allocation instead.
> 
> We already have to drop the anon_vma lock for the "out of memory"
> case, and a slight re-organization of clone_anon_vma() makes it easy
> to just first try a NOIO allocation with the lock still held, and then
> if that fails do the "drop lock, retry, and hard-fail" case.
> 
> IOW, something like the attached (on top of the patches already posted
> except for your memory reclaim thing)
> 

Linus,

I've applied this patch, plus the other two patches on batching anon_vma
clone and anon_vma unlink.  This improved throughput further.  I now see
average throughput at 140.2% vs 2.6.39-vanilla over 10 runs.  The mutex
lock has also gone down to 3.7% of cpu in my profile.  Certainly a great
deal of improvements.

To summarize,

                        Throughput
2.6.39(vanilla)         100.0%
2.6.39+ra-patch         166.7%  (+66.7%)        
3.0-rc2(vanilla)         68.0%  (-32%)
3.0-rc2+linus (v1)      115.7%  (+15.7%)   (anon_vma clone v1)
3.0-rc2+linus+softirq    86.2%  (-17.3%)
3.0-rc2+linus (v2)      104.9%  (+4.9%)    (anon_vma clone v2)
3.0-rc2+linus (v3)      140.3%  (+40.3%)   (anon_vma clone v2 + unlink + chain_alloc_tweak)


                        (Max-Min)/avg  	Standard Dev
2.6.39(vanilla)         3%		 1.1%
2.6.39+ra-patch         3%               1.2%       
3.0-rc2(vanilla)        20%              7.3%
3.0-rc2+linus           36%             12.2%
3.0-rc2+linus+softirq   40%             15.2%
3.0-rc2+linus (v2)      53%             14.8%
3.0-rc2+linus (v3)      27%              8.1%

Thanks.

Tim


------------Profile attached--------------

Profile from latest run 3.0-rc2+linus (v3):

-      5.44%          exim  [kernel.kallsyms]             [k] _raw_spin_lock_irqsave
   - _raw_spin_lock_irqsave                                                                       
      + 87.81% cpupri_set                                                                         
      + 5.67% release_pages                                                                       
      + 1.71% pagevec_lru_move_fn                                                                 
      + 1.31% try_to_wake_up                                                                      
      + 0.85% get_page_from_freelist                                                              
+      4.15%          exim  [kernel.kallsyms]             [k] page_fault                          
-      3.76%          exim  [kernel.kallsyms]             [k] __mutex_lock_common.clone.5         
   - __mutex_lock_common.clone.5                                                                  
      - 99.97% __mutex_lock_slowpath                                                              
         - mutex_lock                                                                             
            + 55.46% lock_anon_vma_root.clone.13                                                  
            + 41.94% anon_vma_lock.clone.10                                                       
            + 1.14% dup_mm                                                                        
            + 1.02% unlink_file_vma                                                               
+      2.44%          exim  [kernel.kallsyms]             [k] unmap_vmas                          
+      2.06%          exim  [kernel.kallsyms]             [k] do_raw_spin_lock                    
+      1.91%          exim  [kernel.kallsyms]             [k] page_cache_get_speculative          
+      1.89%          exim  [kernel.kallsyms]             [k] copy_page_c                           



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
