Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id F37B2280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:29:55 -0400 (EDT)
Received: by qkcl188 with SMTP id l188so17393382qkc.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:29:55 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id k62si3125920qkh.116.2015.07.14.16.29.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Jul 2015 16:29:54 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 14 Jul 2015 17:29:53 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7AB8B19D8026
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:20:49 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6ENT3YD56885404
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:29:03 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6ENTnX9006522
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:29:49 -0600
Date: Tue, 14 Jul 2015 16:29:43 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: cpu_hotplug vs oom_notify_list: possible circular locking
 dependency detected
Message-ID: <20150714232943.GW3717@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150712105634.GA11708@marcin-Inspiron-7720>
 <alpine.DEB.2.10.1507141508590.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507141508590.16182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 14, 2015 at 03:35:15PM -0700, David Rientjes wrote:
> On Sun, 12 Jul 2015, Marcin A?lusarz wrote:
> 
> > [28954.363492] ======================================================
> > [28954.363492] [ INFO: possible circular locking dependency detected ]
> > [28954.363494] 4.1.2 #56 Not tainted
> > [28954.363494] -------------------------------------------------------
> > [28954.363495] pm-suspend/16647 is trying to acquire lock:
> > [28954.363502]  (s_active#22){++++.+}, at: [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
> > [28954.363502] 
> > but task is already holding lock:
> > [28954.363505]  (cpu_hotplug.lock#2){+.+.+.}, at: [<ffffffff810b6042>] cpu_hotplug_begin+0x72/0xc0
> > [28954.363506] 
> > which lock already depends on the new lock.
> > 
> > [28954.363506] 
> > the existing dependency chain (in reverse order) is:
> > [28954.363508] 
> > -> #4 (cpu_hotplug.lock#2){+.+.+.}:
> > [28954.363511]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363514]        [<ffffffff8179d194>] down_read+0x34/0x50
> > [28954.363517]        [<ffffffff810dc419>] __blocking_notifier_call_chain+0x39/0x70
> > [28954.363518]        [<ffffffff810dc466>] blocking_notifier_call_chain+0x16/0x20
> > [28954.363521]        [<ffffffff811ddaff>] __out_of_memory+0x3f/0x660
> > [28954.363522]        [<ffffffff811de2bb>] out_of_memory+0x5b/0x80
> > [28954.363524]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
> > [28954.363527]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
> > [28954.363528]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
> > [28954.363530]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
> > [28954.363531]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
> > [28954.363533]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
> > [28954.363535]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
> > [28954.363536]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
> > [28954.363538]        [<ffffffff817a1a62>] page_fault+0x22/0x30
> > [28954.363539] 
> > -> #3 ((oom_notify_list).rwsem){++++..}:
> > [28954.363541]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363542]        [<ffffffff8179d194>] down_read+0x34/0x50
> > [28954.363544]        [<ffffffff810dc419>] __blocking_notifier_call_chain+0x39/0x70
> > [28954.363546]        [<ffffffff810dc466>] blocking_notifier_call_chain+0x16/0x20
> > [28954.363547]        [<ffffffff811ddaff>] __out_of_memory+0x3f/0x660
> > [28954.363549]        [<ffffffff811de2bb>] out_of_memory+0x5b/0x80
> > [28954.363550]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
> > [28954.363552]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
> > [28954.363553]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
> > [28954.363555]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
> > [28954.363556]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
> > [28954.363557]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
> > [28954.363558]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
> > [28954.363559]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
> > [28954.363560]        [<ffffffff817a1a62>] page_fault+0x22/0x30
> > [28954.363562] 
> > -> #2 (oom_sem){++++..}:
> > [28954.363563]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363565]        [<ffffffff8179d194>] down_read+0x34/0x50
> > [28954.363566]        [<ffffffff811de294>] out_of_memory+0x34/0x80
> > [28954.363568]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
> > [28954.363570]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
> > [28954.363571]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
> > [28954.363572]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
> > [28954.363573]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
> > [28954.363574]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
> > [28954.363575]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
> > [28954.363576]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
> > [28954.363578]        [<ffffffff817a1a62>] page_fault+0x22/0x30
> > [28954.363579] 
> > -> #1 (&mm->mmap_sem){++++++}:
> > [28954.363581]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363582]        [<ffffffff812087cf>] might_fault+0x6f/0xa0
> > [28954.363583]        [<ffffffff812cf4ec>] kernfs_fop_write+0x7c/0x1a0
> > [28954.363585]        [<ffffffff81245388>] __vfs_write+0x28/0xf0
> > [28954.363587]        [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
> > [28954.363588]        [<ffffffff812468e9>] SyS_write+0x49/0xb0
> > [28954.363589]        [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
> > [28954.363591] 
> > -> #0 (s_active#22){++++.+}:
> > [28954.363593]        [<ffffffff8110f6f6>] __lock_acquire+0x1d86/0x2010
> > [28954.363594]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363596]        [<ffffffff812cd080>] __kernfs_remove+0x210/0x2f0
> > [28954.363598]        [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
> > [28954.363600]        [<ffffffff812d0a99>] sysfs_unmerge_group+0x49/0x60
> > [28954.363602]        [<ffffffff81537e89>] dpm_sysfs_remove+0x39/0x60
> > [28954.363603]        [<ffffffff8152b778>] device_del+0x58/0x280
> > [28954.363605]        [<ffffffff8152b9b6>] device_unregister+0x16/0x30
> > [28954.363606]        [<ffffffff81535b7d>] cpu_cache_sysfs_exit+0x5d/0xc0
> > [28954.363608]        [<ffffffff81536300>] cacheinfo_cpu_callback+0x40/0xa0
> > [28954.363609]        [<ffffffff810dc1f6>] notifier_call_chain+0x66/0x90
> > [28954.363611]        [<ffffffff810dc22e>] __raw_notifier_call_chain+0xe/0x10
> > [28954.363612]        [<ffffffff810b5ef3>] cpu_notify+0x23/0x50
> > [28954.363613]        [<ffffffff810b5fbe>] cpu_notify_nofail+0xe/0x20
> > [28954.363615]        [<ffffffff81792dd9>] _cpu_down+0x1d9/0x2e0
> > [28954.363616]        [<ffffffff810b65d8>] disable_nonboot_cpus+0xd8/0x530
> > [28954.363617]        [<ffffffff81117d62>] suspend_devices_and_enter+0x422/0xd60
> > [28954.363619]        [<ffffffff81118add>] pm_suspend+0x43d/0x530
> > [28954.363620]        [<ffffffff81116787>] state_store+0xa7/0xb0
> > [28954.363622]        [<ffffffff81419bdf>] kobj_attr_store+0xf/0x20
> > [28954.363623]        [<ffffffff812cfca9>] sysfs_kf_write+0x49/0x60
> > [28954.363624]        [<ffffffff812cf5b0>] kernfs_fop_write+0x140/0x1a0
> > [28954.363626]        [<ffffffff81245388>] __vfs_write+0x28/0xf0
> > [28954.363627]        [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
> > [28954.363628]        [<ffffffff812468e9>] SyS_write+0x49/0xb0
> > [28954.363630]        [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
> > [28954.363630] 
> > other info that might help us debug this:
> > 
> > [28954.363632] Chain exists of:
> >   s_active#22 --> (oom_notify_list).rwsem --> cpu_hotplug.lock#2
> > 
> > [28954.363633]  Possible unsafe locking scenario:
> > 
> > [28954.363633]        CPU0                    CPU1
> > [28954.363633]        ----                    ----
> > [28954.363635]   lock(cpu_hotplug.lock#2);
> > [28954.363635]                                lock((oom_notify_list).rwsem);
> > [28954.363636]                                lock(cpu_hotplug.lock#2);
> > [28954.363637]   lock(s_active#22);
> > [28954.363638] 
> >  *** DEADLOCK ***
> > 
> > [28954.363639] 9 locks held by pm-suspend/16647:
> > [28954.363641]  #0:  (sb_writers#6){.+.+.+}, at: [<ffffffff81245b83>] vfs_write+0x163/0x1b0
> > [28954.363643]  #1:  (&of->mutex){+.+.+.}, at: [<ffffffff812cf4d6>] kernfs_fop_write+0x66/0x1a0
> > [28954.363646]  #2:  (s_active#186){.+.+.+}, at: [<ffffffff812cf4de>] kernfs_fop_write+0x6e/0x1a0
> > [28954.363649]  #3:  (autosleep_lock){+.+...}, at: [<ffffffff8111fcb7>] pm_autosleep_lock+0x17/0x20
> > [28954.363651]  #4:  (pm_mutex){+.+...}, at: [<ffffffff8111881c>] pm_suspend+0x17c/0x530
> > [28954.363654]  #5:  (acpi_scan_lock){+.+.+.}, at: [<ffffffff81495716>] acpi_scan_lock_acquire+0x17/0x19
> > [28954.363656]  #6:  (cpu_add_remove_lock){+.+.+.}, at: [<ffffffff810b6529>] disable_nonboot_cpus+0x29/0x530
> > [28954.363658]  #7:  (cpu_hotplug.lock){++++++}, at: [<ffffffff810b5fd5>] cpu_hotplug_begin+0x5/0xc0
> > [28954.363661]  #8:  (cpu_hotplug.lock#2){+.+.+.}, at: [<ffffffff810b6042>] cpu_hotplug_begin+0x72/0xc0
> > [28954.363661] 
> > stack backtrace:
> > [28954.363663] CPU: 3 PID: 16647 Comm: pm-suspend Not tainted 4.1.2 #56
> > [28954.363663] Hardware name: Dell Inc.          Inspiron 7720/04M3YM, BIOS A07 08/16/2012
> > [28954.363666]  ffffffff826415a0 ffff88008952b838 ffffffff81796918 0000000080000001
> > [28954.363667]  ffffffff8263e150 ffff88008952b888 ffffffff8110bf8d ffff880040334cd0
> > [28954.363669]  ffff88008952b8f8 0000000000000008 ffff880040334ca8 0000000000000008
> > [28954.363669] Call Trace:
> > [28954.363671]  [<ffffffff81796918>] dump_stack+0x4f/0x7b
> > [28954.363673]  [<ffffffff8110bf8d>] print_circular_bug+0x1cd/0x230
> > [28954.363674]  [<ffffffff8110f6f6>] __lock_acquire+0x1d86/0x2010
> > [28954.363677]  [<ffffffff811103db>] lock_acquire+0xbb/0x290
> > [28954.363678]  [<ffffffff812ce269>] ? kernfs_remove_by_name_ns+0x49/0xb0
> > [28954.363680]  [<ffffffff812cd080>] __kernfs_remove+0x210/0x2f0
> > [28954.363682]  [<ffffffff812ce269>] ? kernfs_remove_by_name_ns+0x49/0xb0
> > [28954.363683]  [<ffffffff812cc5c7>] ? kernfs_name_hash+0x17/0xa0
> > [28954.363685]  [<ffffffff812cd519>] ? kernfs_find_ns+0x89/0x160
> > [28954.363687]  [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
> > [28954.363688]  [<ffffffff812d0a99>] sysfs_unmerge_group+0x49/0x60
> > [28954.363689]  [<ffffffff81537e89>] dpm_sysfs_remove+0x39/0x60
> > [28954.363691]  [<ffffffff8152b778>] device_del+0x58/0x280
> > [28954.363692]  [<ffffffff8152b9b6>] device_unregister+0x16/0x30
> > [28954.363693]  [<ffffffff81535b7d>] cpu_cache_sysfs_exit+0x5d/0xc0
> > [28954.363695]  [<ffffffff81536300>] cacheinfo_cpu_callback+0x40/0xa0
> > [28954.363696]  [<ffffffff810dc1f6>] notifier_call_chain+0x66/0x90
> > [28954.363698]  [<ffffffff810dc22e>] __raw_notifier_call_chain+0xe/0x10
> > [28954.363699]  [<ffffffff810b5ef3>] cpu_notify+0x23/0x50
> > [28954.363699]  [<ffffffff810b5fbe>] cpu_notify_nofail+0xe/0x20
> > [28954.363700]  [<ffffffff81792dd9>] _cpu_down+0x1d9/0x2e0
> > [28954.363702]  [<ffffffff8110aa48>] ? __lock_is_held+0x58/0x80
> > [28954.363703]  [<ffffffff810b65d8>] disable_nonboot_cpus+0xd8/0x530
> > [28954.363704]  [<ffffffff81117d62>] suspend_devices_and_enter+0x422/0xd60
> > [28954.363705]  [<ffffffff81795714>] ? printk+0x46/0x48
> > [28954.363707]  [<ffffffff81118add>] pm_suspend+0x43d/0x530
> > [28954.363708]  [<ffffffff81116787>] state_store+0xa7/0xb0
> > [28954.363710]  [<ffffffff81419bdf>] kobj_attr_store+0xf/0x20
> > [28954.363711]  [<ffffffff812cfca9>] sysfs_kf_write+0x49/0x60
> > [28954.363712]  [<ffffffff812cf5b0>] kernfs_fop_write+0x140/0x1a0
> > [28954.363713]  [<ffffffff81245388>] __vfs_write+0x28/0xf0
> > [28954.363714]  [<ffffffff81245b83>] ? vfs_write+0x163/0x1b0
> > [28954.363716]  [<ffffffff813cbdb8>] ? apparmor_file_permission+0x18/0x20
> > [28954.363719]  [<ffffffff813bdca3>] ? security_file_permission+0x23/0xa0
> > [28954.363720]  [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
> > [28954.363721]  [<ffffffff812468e9>] SyS_write+0x49/0xb0
> > [28954.363723]  [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
> > 
> 
> Thanks for the report.
> 
> We have pm-suspend/16647 doing cpu_hotplug_begin() in _cpu_down(), which 
> iterates the cpu down notifier list, one of which is 
> cacheinfo_cpu_callback(), which does cpu_cache_sysfs_exit() and that does 
> __kernfs_remove() which requires s_active.  That chain makes sense.
> 
> Meanwhile, an oom notifier is taking the same mutex as 
> cpu_hotplug_begin(), presumably get_online_cpus().  I'm wondering if 
> that's the rcu oom notifier.
> 
> Adding Paul and Tejun.

Well, RCU's OOM notifier definitely invokes get_online_cpus().  But it turns
out that it doesn't need to.  Please try the patch shown below.

							Thanx, Paul

------------------------------------------------------------------------

commit a1992f2f3b8e174d740a8f764d0d51344bed2eed
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Jul 14 16:24:14 2015 -0700

    rcu: Don't disable CPU hotplug during OOM notifiers
    
    RCU's rcu_oom_notify() disables CPU hotplug in order to stabilize the
    list of online CPUs, which it traverses.  However, this is completely
    pointless because smp_call_function_single() will quietly fail if invoked
    on an offline CPU.  Because the count of requests is incremented in the
    rcu_oom_notify_cpu() function that is remotely invoked, everything works
    nicely even in the face of concurrent CPU-hotplug operations.
    
    Furthermore, in recent kernels, invoking get_online_cpus() from an OOM
    notifier can result in deadlock.  This commit therefore removes the
    call to get_online_cpus() and put_online_cpus() from rcu_oom_notify().
    
    Reported-by: Marcin A?lusarz <marcin.slusarz@gmail.com>
    Reported-by: David Rientjes <rientjes@google.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 17295e44bf95..b2bf3963a0ae 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -1621,12 +1621,10 @@ static int rcu_oom_notify(struct notifier_block *self,
 	 */
 	atomic_set(&oom_callback_count, 1);
 
-	get_online_cpus();
 	for_each_online_cpu(cpu) {
 		smp_call_function_single(cpu, rcu_oom_notify_cpu, NULL, 1);
 		cond_resched_rcu_qs();
 	}
-	put_online_cpus();
 
 	/* Unconditionally decrement: no need to wake ourselves up. */
 	atomic_dec(&oom_callback_count);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
