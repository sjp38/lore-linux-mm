Received: by wx-out-0506.google.com with SMTP id h29so763274wxd.11
        for <linux-mm@kvack.org>; Sat, 21 Jun 2008 19:10:08 -0700 (PDT)
Message-ID: <a4423d670806211910t2fd283aco4288502071bb119@mail.gmail.com>
Date: Sun, 22 Jun 2008 06:10:08 +0400
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
In-Reply-To: <20080621224135.GD4692@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
	 <20080621224135.GD4692@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2008/6/22 Mel Gorman <mel@csn.ul.ie>:
> 2. The circular lock itself was considered to be a false positive by David
>   Chinner (http://lkml.org/lkml/2008/5/11/253). I've added David to the
>   cc. I hate to ask the obvious, but is it possible that LOCKDEP checking
>   was not turned on for the kernels before 2.6.26-rc1?
Yes, I bisected it with about the same config (as much as possible
with changing Kconfig),
LOCKDEP was enabled for all bisected configs.

> I spotted at least one problem in the patch in a change made to SLAB that
> needs to be fixed but it is not relevant to the problem at hand as I believe
> Alexandar is using SLUB instead of SLAB.  That patch is at the end of the
> mail. Christoph, can you double check that patch please?
Yes, I use SLUB.

> I'm assuming that the few seconds are being spent in reclaim rather than
> working out lock dependency logic. Any chance there is profile information
> showing where all the time is being spent? Just in case, does the stall
> still occur with lockdep turned off?
Hm, I cannot forecast the time when I will have this message, I
gathered readprofile statistics
right after the message:
   102 add_preempt_count                          1.0303
   102 net_rx_action                              0.2991
   104 __flush_tlb_all                            2.3111
   115 __tcp_push_pending_frames                  0.0626
   129 e1000_clean_rx_irq                         0.1549
   132 _read_unlock_irq                           1.7838
   136 __rcu_read_unlock                          1.3878
   137 native_read_tsc                            7.2105
   153 tcp_ack                                    0.0261
   155 __rcu_advance_callbacks                    0.8960
   197 local_bh_enable                            0.8277
   205 e1000_clean                                0.4092
   206 free_hot_cold_page                         0.5754
   308 _write_unlock_irq                          4.1622
   352 get_page_from_freelist                     0.3157
   448 lock_acquired                              0.8854
   564 acpi_pm_read                              28.2000
   618 vprintk                                    0.6897
   738 _spin_unlock_irq                           9.9730
   863 __do_softirq                               5.2945
   993 lock_release                               2.4458
  1166 netpoll_setup                              1.5630
  1633 _spin_unlock_irqrestore                   17.0104
  1712 lock_acquire                              12.7761
  1714 kfree                                      7.6178
  1724 __kmalloc_track_caller                     7.7309
  2308 kmem_cache_free                           12.3422
  3189 kmem_cache_alloc                          18.7588
 18261 default_idle                             214.8353
 43758 total                                      0.0175

Could it be useful? I am afraid it is not.
I can try to gather it for lesser time around the event.

I did not mentioned a message from e1000 right after the lockdep message:
e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <8f>
  TDT                  <8f>
  next_to_use          <8f>
  next_to_clean        <44>
buffer_info[next_to_clean]
  time_stamp           <601d>
  next_to_watch        <44>
  jiffies              <647c>
  next_to_watch.status <1>

Perhaps, it is actually the reason for nfsd being stalled ?

I have tried the test without lockdep and it seems it does not stall.
But I am not pretty sure, it is harder to caught hanging without
lockdep message.

> At the moment, I'm a little stumped. I'm going to start looking at diffs
> between 2.6.25 and 2.6.26-rc5 and see what jumps out but alternative theories
> are welcome :/
I found it in 2.6.26-rc1, I think it does not need to search after rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
