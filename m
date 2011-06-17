Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B3696B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 14:22:16 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Jun 2011 11:22:43 -0700
Message-ID: <1308334963.17300.489.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, 2011-06-16 at 20:58 -0700, Linus Torvalds wrote:

> 
> So Tim, I'd like you to test out my first patch (that only does the
> anon_vma_clone() case) once again, but now in the cleaned-up version.
> Does this patch really make a big improvement for you? If so, this
> first step is probably worth doing regardless of the more complicated
> second step, but I'd want to really make sure it's ok, and that the
> performance improvement you saw is consistent and not a fluke.
> 
>                  Linus

Linus,

For this patch, I've run it 10 times and got an average throughput of
104.9% compared with 2.6.39 vanilla baseline.  Wide variations are seen
run to run and the difference between max and min throughput is 52% of
average value.

So to recap,

                        Throughput
2.6.39(vanilla)         100.0%
2.6.39+ra-patch         166.7%  (+66.7%)        
3.0-rc2(vanilla)         68.0%  (-32%)
3.0-rc2+linus           115.7%  (+15.7%)
3.0-rc2+linus+softirq    86.2%  (-17.3%)
3.0-rc2+linus (v2)      104.9%  (+4.9%)

The time spent in the anon_vma mutex seems to directly affect
throughput.

In one run on your patch, I got a low throughput of 90.1% vs 2.6.39
throughput. The mutex_lock occupied 15.6% of cpu.

In another run, I got a high throughput of 120.8% vs 2.6.39 throughput.
The mutex lock occupied 7.5% of cpu.

I've attached the profiles of the two runs and a 3.0-rc2 vanilla run for
your reference.

I will follow up later with numbers that has Peter's patch added.

Thanks.

Tim

----------Profiles Below-------------------------

3.0-rc2+linus(v2) run 1 (90.1% throughput vs 2.6.39)

-     15.60%          exim  [kernel.kallsyms]             [k] __mutex_lock_common.clone.5
   - __mutex_lock_common.clone.5
      - 99.99% __mutex_lock_slowpath
         - mutex_lock
            + 75.52% anon_vma_lock.clone.10
            + 23.88% anon_vma_clone
-      4.38%          exim  [kernel.kallsyms]             [k] _raw_spin_lock_irqsave
   - _raw_spin_lock_irqsave
      + 82.83% cpupri_set
      + 6.75% try_to_wake_up
      + 5.35% release_pages
      + 1.72% pagevec_lru_move_fn
      + 0.93% get_page_from_freelist
      + 0.51% lock_timer_base.clone.20
+      3.22%          exim  [kernel.kallsyms]             [k] page_fault
+      2.62%          exim  [kernel.kallsyms]             [k] do_raw_spin_lock
+      2.30%          exim  [kernel.kallsyms]             [k] mutex_unlock
+      2.02%          exim  [kernel.kallsyms]             [k] unmap_vmas


3.0-rc2_linus(v2) run 2 (120.8% throughput vs 2.6.39)

-      7.53%             exim  [kernel.kallsyms]             [k] __mutex_lock_common.clone.5
   - __mutex_lock_common.clone.5
      - 99.99% __mutex_lock_slowpath
         - mutex_lock
            + 75.99% anon_vma_lock.clone.10
            + 22.68% anon_vma_clone
            + 0.70% unlink_file_vma
-      4.15%             exim  [kernel.kallsyms]             [k] _raw_spin_lock_irqsave
   - _raw_spin_lock_irqsave
      + 83.37% cpupri_set
      + 7.06% release_pages
      + 2.74% pagevec_lru_move_fn
      + 2.18% try_to_wake_up
      + 0.99% get_page_from_freelist
      + 0.59% lock_timer_base.clone.20
      + 0.58% lock_hrtimer_base.clone.16
+      4.06%             exim  [kernel.kallsyms]             [k] page_fault
+      2.33%             exim  [kernel.kallsyms]             [k] unmap_vmas
+      2.22%             exim  [kernel.kallsyms]             [k] do_raw_spin_lock
+      2.05%             exim  [kernel.kallsyms]             [k] page_cache_get_speculative
+      1.98%             exim  [kernel.kallsyms]             [k] mutex_unlock


3.0-rc2 vanilla run 

-     18.60%          exim  [kernel.kallsyms]        [k] __mutex_lock_common.clone.5                                            a??
   - __mutex_lock_common.clone.5                                                                                                a?(R)
      - 99.99% __mutex_lock_slowpath                                                                                            a??
         - mutex_lock                                                                                                           a??
            - 99.54% anon_vma_lock.clone.10                                                                                     a??
               + 38.99% anon_vma_clone                                                                                          a??
               + 37.56% unlink_anon_vmas                                                                                        a??
               + 11.92% anon_vma_fork                                                                                           a??
               + 11.53% anon_vma_free                                                                                           a??
-      4.03%          exim  [kernel.kallsyms]        [k] _raw_spin_lock_irqsave                                                 a??
   - _raw_spin_lock_irqsave                                                                                                     a??
      + 87.25% cpupri_set                                                                                                       a??
      + 4.75% release_pages                                                                                                     a??
      + 3.68% try_to_wake_up                                                                                                    a??
      + 1.17% pagevec_lru_move_fn                                                                                               a??
      + 0.71% get_page_from_freelist                                                                                            a??
+      3.00%          exim  [kernel.kallsyms]        [k] do_raw_spin_lock                                                       a??
+      2.90%          exim  [kernel.kallsyms]        [k] page_fault                                                             a??
+      2.25%          exim  [kernel.kallsyms]        [k] mutex_unlock                                                           a??
+      1.82%          exim  [kernel.kallsyms]        [k] unmap_vmas                                                             a??
+      1.62%          exim  [kernel.kallsyms]        [k] copy_page_c                                                            a??


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
