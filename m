Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6827F6B00E7
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 10:35:11 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 08:35:09 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8095319D804C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 08:33:55 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2DEXkJM167142
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 08:33:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DEXZs7009376
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 08:33:36 -0600
Date: Tue, 13 Mar 2012 07:33:31 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU stalls in linux-next
Message-ID: <20120313143327.GA2349@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20120313134822.GA5158@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120313134822.GA5158@elgon.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 04:48:23PM +0300, Dan Carpenter wrote:
> I've been getting RCU hangs in linux-next.
> 
> Also sometimes, when I'm building my smatch database after a kernel
> compile, my system hangs.  I'm not certain if the two things are related.
> 
> regards,
> dan carpenter
> 
> Mar 13 14:32:11 elgon kernel: [265405.604199] Pid: 665, comm: kswapd0 Not tainted 3.3.0-rc6-next-20120308+ #141
> Mar 13 14:32:11 elgon kernel: [265405.604200] Call Trace:
> Mar 13 14:32:11 elgon kernel: [265405.604201]  <IRQ>  [<ffffffff810ab9da>] __rcu_pending+0x19a/0x4d0
> Mar 13 14:32:11 elgon kernel: [265405.604208]  [<ffffffff810ac1d0>] rcu_check_callbacks+0xb0/0x1a0
> Mar 13 14:32:11 elgon kernel: [265405.604210]  [<ffffffff81044293>] update_process_times+0x43/0x80
> Mar 13 14:32:11 elgon kernel: [265405.604220]  [<ffffffff8107eb0f>] tick_sched_timer+0x5f/0xb0
> Mar 13 14:32:11 elgon kernel: [265405.604230]  [<ffffffff81058f68>] __run_hrtimer+0x78/0x1d0
> Mar 13 14:32:11 elgon kernel: [265405.604232]  [<ffffffff8107eab0>] ? tick_nohz_handler+0xf0/0xf0
> Mar 13 14:32:11 elgon kernel: [265405.604234]  [<ffffffff8103ba91>] ? __do_softirq+0xf1/0x210
> Mar 13 14:32:11 elgon kernel: [265405.604235]  [<ffffffff81059843>] hrtimer_interrupt+0xe3/0x200
> Mar 13 14:32:11 elgon kernel: [265405.604238]  [<ffffffff8170c74c>] ? call_softirq+0x1c/0x30
> Mar 13 14:32:11 elgon kernel: [265405.604241]  [<ffffffff8101f7c4>] smp_apic_timer_interrupt+0x64/0xa0
> Mar 13 14:32:11 elgon kernel: [265405.604243]  [<ffffffff8170be07>] apic_timer_interrupt+0x67/0x70
> Mar 13 14:32:11 elgon kernel: [265405.604244]  <EOI>  [<ffffffff810d87ac>] ? zone_watermark_ok_safe+0x8c/0x170

Looks like kswapd is having a bad hair day, CCing linux-mm to see if they
can help.

							Thanx, Paul

> Mar 13 14:32:11 elgon kernel: [265405.604248]  [<ffffffff810e73c8>] balance_pgdat+0x1a8/0x680
> Mar 13 14:32:11 elgon kernel: [265405.604250]  [<ffffffff810e7a08>] kswapd+0x168/0x3f0
> Mar 13 14:32:11 elgon kernel: [265405.604253]  [<ffffffff81702916>] ? __schedule+0x3a6/0x750
> Mar 13 14:32:11 elgon kernel: [265405.604255]  [<ffffffff810556b0>] ? add_wait_queue+0x60/0x60
> Mar 13 14:32:11 elgon kernel: [265405.604256]  [<ffffffff810e78a0>] ? balance_pgdat+0x680/0x680
> Mar 13 14:32:11 elgon kernel: [265405.604258]  [<ffffffff81054c7e>] kthread+0x8e/0xa0
> Mar 13 14:32:11 elgon kernel: [265405.604260]  [<ffffffff8170c654>] kernel_thread_helper+0x4/0x10
> Mar 13 14:32:11 elgon kernel: [265405.604262]  [<ffffffff81054bf0>] ? kthread_freezable_should_stop+0x70/0x70
> Mar 13 14:32:11 elgon kernel: [265405.604264]  [<ffffffff8170c650>] ? gs_change+0xb/0xb
> Mar 13 14:35:11 elgon kernel: [265585.490971] Pid: 665, comm: kswapd0 Not tainted 3.3.0-rc6-next-20120308+ #141
> Mar 13 14:35:11 elgon kernel: [265585.490972] Call Trace:
> Mar 13 14:35:11 elgon kernel: [265585.490973]  <IRQ>  [<ffffffff810ab9da>] __rcu_pending+0x19a/0x4d0
> Mar 13 14:35:11 elgon kernel: [265585.490987]  [<ffffffff810ac1d0>] rcu_check_callbacks+0xb0/0x1a0
> Mar 13 14:35:11 elgon kernel: [265585.490989]  [<ffffffff81044293>] update_process_times+0x43/0x80
> Mar 13 14:35:11 elgon kernel: [265585.490991]  [<ffffffff8107eb0f>] tick_sched_timer+0x5f/0xb0
> Mar 13 14:35:11 elgon kernel: [265585.490994]  [<ffffffff81058f68>] __run_hrtimer+0x78/0x1d0
> Mar 13 14:35:11 elgon kernel: [265585.490995]  [<ffffffff8107eab0>] ? tick_nohz_handler+0xf0/0xf0
> Mar 13 14:35:11 elgon kernel: [265585.490997]  [<ffffffff8103ba91>] ? __do_softirq+0xf1/0x210
> Mar 13 14:35:11 elgon kernel: [265585.490999]  [<ffffffff81059843>] hrtimer_interrupt+0xe3/0x200
> Mar 13 14:35:11 elgon kernel: [265585.491002]  [<ffffffff8170c74c>] ? call_softirq+0x1c/0x30
> Mar 13 14:35:11 elgon kernel: [265585.491005]  [<ffffffff8101f7c4>] smp_apic_timer_interrupt+0x64/0xa0
> Mar 13 14:35:11 elgon kernel: [265585.491007]  [<ffffffff8170be07>] apic_timer_interrupt+0x67/0x70
> Mar 13 14:35:11 elgon kernel: [265585.491008]  <EOI>  [<ffffffff810d876d>] ? zone_watermark_ok_safe+0x4d/0x170
> Mar 13 14:35:11 elgon kernel: [265585.491012]  [<ffffffff810e73c8>] balance_pgdat+0x1a8/0x680
> Mar 13 14:35:11 elgon kernel: [265585.491014]  [<ffffffff810e7a08>] kswapd+0x168/0x3f0
> Mar 13 14:35:11 elgon kernel: [265585.491017]  [<ffffffff81702916>] ? __schedule+0x3a6/0x750
> Mar 13 14:35:11 elgon kernel: [265585.491019]  [<ffffffff810556b0>] ? add_wait_queue+0x60/0x60
> Mar 13 14:35:11 elgon kernel: [265585.491021]  [<ffffffff810e78a0>] ? balance_pgdat+0x680/0x680
> Mar 13 14:35:11 elgon kernel: [265585.491023]  [<ffffffff81054c7e>] kthread+0x8e/0xa0
> Mar 13 14:35:11 elgon kernel: [265585.491024]  [<ffffffff8170c654>] kernel_thread_helper+0x4/0x10
> Mar 13 14:35:11 elgon kernel: [265585.491026]  [<ffffffff81054bf0>] ? kthread_freezable_should_stop+0x70/0x70
> Mar 13 14:35:11 elgon kernel: [265585.491028]  [<ffffffff8170c650>] ? gs_change+0xb/0xb
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
