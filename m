Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 383EE6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 03:49:39 -0400 (EDT)
Date: Thu, 28 Mar 2013 03:49:37 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <2093011648.7646491.1364456977704.JavaMail.root@redhat.com>
In-Reply-To: <20130326195344.GA1578@redhat.com>
Subject: Re: BUG at kmem_cache_alloc
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>



----- Original Message -----
> From: "Dave Jones" <davej@redhat.com>
> To: "CAI Qian" <caiqian@redhat.com>
> Cc: "Christoph Lameter" <cl@linux.com>, "David Rientjes" <rientjes@google.com>, "linux-mm" <linux-mm@kvack.org>,
> linux-kernel@vger.kernel.org, "Oleg Nesterov" <oleg@redhat.com>
> Sent: Wednesday, March 27, 2013 3:53:44 AM
> Subject: Re: BUG at kmem_cache_alloc
> 
> On Tue, Mar 26, 2013 at 05:32:27AM -0400, CAI Qian wrote:
> 
>  > Still running and will update ASAP. One thing I noticed was that
>  > trinity
>  > threw out this error before the kernel crash.
>  > 
>  > BUG!:
>  > CHILD (pid:28825) GOT REPARENTED! parent pid:19380. Watchdog
>  > pid:19379
>  >       
>  > BUG!:
>  > Last syscalls:
>  > [0]  pid:28515 call:settimeofday callno:10356
>  > [1]  pid:28822 call:setgid callno:322
>  > [2]  pid:28581 call:init_module callno:3622
>  > [3]  pid:28825 call:readlinkat callno:403
>  > child 28581 exiting
>  > child 28515 exiting
>  >  ...killed.
> 
> When this happens, it usually means that the parent segfaulted.
> I've been trying to reproduce a few reports of this for a while
> without success.  If you get time, running trinity inside gdb should
> be enough to get a useful backtrace.
> 
> (Or run with -D, and collect coredumps [there will a lot], and match
> the
>  core to the pid of the process we're interested in)
> 
> 	Dave
> 
While reproducing this, it triggered something else with SLUB_DEBUG_ON.
CAI Qian

[87295.499233] general protection fault: 0000 [#1] SMP 
[87295.500228] Modules linked in: binfmt_misc fuse tun cmtp kernelcapi rfcomm bnep hidp scsi_transport_iscsi nfnetlink ipt_ULOG nfc bluetooth rfkill af_key atm lockd sunrpc nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg kvm_amd kvm microcode amd64_edac_mod edac_mce_amd pcspkr serio_raw edac_core k10temp bnx2x netxen_nic mdio i2c_piix4 i2c_core hpilo shpchp ipmi_si ipmi_msghandler hpwdt xfs libcrc32c sd_mod crc_t10dif sata_svw libata dm_mirror dm_region_hash dm_log dm_mod
[87295.515752] CPU 1 
[87295.516184] Pid: 23211, comm: trinity-main Tainted: G        W    3.8.4 #4 HP ProLiant BL495c G5  
[87295.517810] RIP: 0010:[<ffffffff812e0b43>]  [<ffffffff812e0b43>] rb_next+0x23/0x50
[87295.519254] RSP: 0018:ffff880127f5de58  EFLAGS: 00010202
[87295.520398] RAX: 6b6b6b6b6b6b6b6b RBX: 0000000000000000 RCX: ffff88014181d9c8
[87295.521996] RDX: 6b6b6b6b6b6b6b6b RSI: ffff88014181a6e0 RDI: ffff88014181d9e0
[87295.523606] RBP: ffff880127f5de58 R08: 0000000000003d7b R09: 0000000000000008
[87295.525201] R10: ffffffff81197360 R11: 0000000000000246 R12: ffff8801314f3180
[87295.526793] R13: 0000000000000000 R14: 000000000000000f R15: ffff88014181d9c8
[87295.528465] FS:  00007f94bbc0f740(0000) GS:ffff88014fc80000(0000) knlGS:0000000000000000
[87295.530271] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[87295.531578] CR2: 0000000001f53008 CR3: 00000001129f5000 CR4: 00000000000007e0
[87295.533210] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[87295.534797] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[87295.536402] Process trinity-main (pid: 23211, threadinfo ffff880127f5c000, task ffff8801418e98a0)
[87295.538368] Stack:
[87295.538793]  ffff880127f5ded8 ffffffff811f8220 0000000000000008 0000000000003d7b
[87295.540579]  ffff880127f50001 ffff8801314f3190 0000000000020000 ffffffff81197360
[87295.542313]  ffff880127f5df40 ffff88014181a6e0 ffff880127f5ded8 ffff8801314f3180
[87295.543959] Call Trace:
[87295.544513]  [<ffffffff811f8220>] sysfs_readdir+0x150/0x280
[87295.545774]  [<ffffffff81197360>] ? fillonedir+0x100/0x100
[87295.547004]  [<ffffffff81197360>] ? fillonedir+0x100/0x100
[87295.548268]  [<ffffffff81197238>] vfs_readdir+0xb8/0xe0
[87295.549446]  [<ffffffff811a159b>] ? set_close_on_exec+0x3b/0x70
[87295.550832]  [<ffffffff8119758f>] sys_getdents+0x8f/0x110
[87295.552068]  [<ffffffff815e6419>] system_call_fastpath+0x16/0x1b
[87295.553433] Code: 48 89 70 10 eb a9 66 90 55 48 8b 17 48 89 e5 48 39 d7 74 3b 48 8b 47 08 48 85 c0 75 0e eb 1f 66 0f 1f 84 00 00 00 00 00 48 89 d0 <48> 8b 50 10 48 85 d2 75 f4 5d c3 66 90 48 8b 10 48 89 c7 48 89 
[87295.557829] RIP  [<ffffffff812e0b43>] rb_next+0x23/0x50
[87295.558960]  RSP <ffff880127f5de58>
[87295.560213] ---[ end trace d5f25cc963b1f1d9 ]---
[watchdog] Triggering periodic reseed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
