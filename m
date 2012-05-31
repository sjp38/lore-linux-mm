Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 773E36B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 14:09:04 -0400 (EDT)
Date: Thu, 31 May 2012 20:08:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: AutoNUMA15
Message-ID: <20120531180834.GP21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <20120529133627.GA7637@shutemov.name>
 <20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Hi,

On Tue, May 29, 2012 at 05:43:09PM +0200, Petr Holasek wrote:
> Similar problem with __autonuma_migrate_page_remove here. 
> 
> [ 1945.516632] ------------[ cut here ]------------
> [ 1945.516636] WARNING: at lib/list_debug.c:50 __list_del_entry+0x63/0xd0()
> [ 1945.516642] Hardware name: ProLiant DL585 G5   
> [ 1945.516651] list_del corruption, ffff88017d68b068->next is LIST_POISON1 (dead000000100100)
> [ 1945.516682] Modules linked in: ipt_MASQUERADE nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle lockd ip6t_REJECT sunrpc nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables iptable_nat nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack mperf freq_table kvm_amd kvm pcspkr amd64_edac_mod edac_core serio_raw bnx2 microcode edac_mce_amd shpchp k10temp hpilo ipmi_si ipmi_msghandler hpwdt qla2xxx hpsa ata_generic pata_acpi scsi_transport_fc scsi_tgt cciss pata_amd radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]
> [ 1945.516694] Pid: 150, comm: knuma_migrated0 Tainted: G        W    3.4.0aa_alpha+ #3
> [ 1945.516701] Call Trace:
> [ 1945.516710]  [<ffffffff8105788f>] warn_slowpath_common+0x7f/0xc0
> [ 1945.516717]  [<ffffffff81057986>] warn_slowpath_fmt+0x46/0x50
> [ 1945.516726]  [<ffffffff812f9713>] __list_del_entry+0x63/0xd0
> [ 1945.516735]  [<ffffffff812f9791>] list_del+0x11/0x40
> [ 1945.516743]  [<ffffffff81165b98>] __autonuma_migrate_page_remove+0x48/0x80
> [ 1945.516746]  [<ffffffff81165e66>] knuma_migrated+0x296/0x8a0
> [ 1945.516749]  [<ffffffff8107a200>] ? wake_up_bit+0x40/0x40
> [ 1945.516758]  [<ffffffff81165bd0>] ? __autonuma_migrate_page_remove+0x80/0x80
> [ 1945.516766]  [<ffffffff81079cc3>] kthread+0x93/0xa0
> [ 1945.516780]  [<ffffffff81626f24>] kernel_thread_helper+0x4/0x10
> [ 1945.516791]  [<ffffffff81079c30>] ? flush_kthread_worker+0x80/0x80
> [ 1945.516798]  [<ffffffff81626f20>] ? gs_change+0x13/0x13
> [ 1945.516800] ---[ end trace 7cab294af87bd79f ]---

I didn't manage to reproduce it on my hardware but it seems this was
caused by the autonuma_migrate_split_huge_page: the tail page list
linking wasn't surrounded by the compound lock to make list insertion
and migrate_nid setting atomic like it happens everywhere else (the
caller holding the lock on the head page wasn't enough to make the
tails stable too).

I released an AutoNUMA15 branch that includes all pending fixes:

git clone --reference linux -b autonuma15 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
