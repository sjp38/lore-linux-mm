Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2CA2C6B005D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 04:23:19 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 15 Oct 2012 02:23:18 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id BFD1F19D8036
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 02:22:42 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9F8Mg0s256112
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 02:22:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9F8Md7h025578
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 02:22:42 -0600
Date: Mon, 15 Oct 2012 13:54:13 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 19/33] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
Message-ID: <20121015082413.GD17364@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-20-git-send-email-aarcange@redhat.com>
 <20121013180618.GC31442@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20121013180618.GC31442@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, pzijlstr@redhat.com, mingo@elte.hu, mel@csn.ul.ie, hughd@google.com, riel@redhat.com, hannes@cmpxchg.org, dhillf@gmail.com, drjones@redhat.com, tglx@linutronix.de, pjt@google.com, cl@linux.com, suresh.b.siddha@intel.com, efault@gmx.de, paulmck@linux.vnet.ibm.com, laijs@cn.fujitsu.com, Lee.Schermerhorn@hp.com, alex.shi@intel.com, benh@kernel.crashing.org

* Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2012-10-13 23:36:18]:

> > +
> > +bool numa_hinting_fault(struct page *page, int numpages)
> > +{
> > +	bool migrated = false;
> > +
> > +	/*
> > +	 * "current->mm" could be different from the "mm" where the
> > +	 * NUMA hinting page fault happened, if get_user_pages()
> > +	 * triggered the fault on some other process "mm". That is ok,
> > +	 * all we care about is to count the "page_nid" access on the
> > +	 * current->task_autonuma, even if the page belongs to a
> > +	 * different "mm".
> > +	 */
> > +	WARN_ON_ONCE(!current->mm);
> 
> Given the above comment, Do we really need this warn_on?
> I think I have seen this warning when using autonuma.
> 

------------[ cut here ]------------
WARNING: at ../mm/autonuma.c:359 numa_hinting_fault+0x60d/0x7c0()
Hardware name: BladeCenter HS22V -[7871AC1]-
Modules linked in: ebtable_nat ebtables autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf bridge stp llc iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vhost_net macvtap macvlan tun iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii kvm_intel kvm microcode serio_raw lpc_ich mfd_core i2c_i801 i2c_core shpchp ioatdma i7core_edac edac_core bnx2 ixgbe dca mdio sg ext4 mbcache jbd2 sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas dm_mirror dm_region_hash dm_log dm_mod
Pid: 116, comm: ksmd Tainted: G      D      3.6.0-autonuma27+ #3
Call Trace:
 [<ffffffff8105194f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810519aa>] warn_slowpath_null+0x1a/0x20
 [<ffffffff81153f0d>] numa_hinting_fault+0x60d/0x7c0
 [<ffffffff8104ae90>] ? flush_tlb_mm_range+0x250/0x250
 [<ffffffff8103b82e>] ? physflat_send_IPI_mask+0xe/0x10
 [<ffffffff81036db5>] ? native_send_call_func_ipi+0xa5/0xd0
 [<ffffffff81154255>] pmd_numa_fixup+0x195/0x350
 [<ffffffff81135ef4>] handle_mm_fault+0x2c4/0x3d0
 [<ffffffff8113139c>] ? follow_page+0x2fc/0x4f0
 [<ffffffff81156364>] break_ksm+0x74/0xa0
 [<ffffffff81156562>] break_cow+0xa2/0xb0
 [<ffffffff81158444>] ksm_scan_thread+0xb54/0xd50
 [<ffffffff81075cf0>] ? wake_up_bit+0x40/0x40
 [<ffffffff811578f0>] ? run_store+0x340/0x340
 [<ffffffff8107563e>] kthread+0x9e/0xb0
 [<ffffffff814e8c44>] kernel_thread_helper+0x4/0x10
 [<ffffffff810755a0>] ? kthread_freezable_should_stop+0x70/0x70
 [<ffffffff814e8c40>] ? gs_change+0x13/0x13
---[ end trace 8f50820d1887cf93 ]-


While running specjbb on a 2 node box. Seems pretty easy to produce this.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
