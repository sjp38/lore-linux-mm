Date: Wed, 6 Dec 2006 20:12:46 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
Message-Id: <20061206201246.be7fb860.akpm@osdl.org>
In-Reply-To: <200612070355.kB73tGf4021820@fire-2.osdl.org>
References: <200612070355.kB73tGf4021820@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org, Ramiro.Voicu@cern.ch
List-ID: <linux-mm.kvack.org>

(switching to email - please retain all cc's).

On Wed, 6 Dec 2006 19:55:16 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7645
> 
>            Summary: Kernel BUG at mm/memory.c:1124
>     Kernel Version: 2.6.19
>             Status: NEW
>           Severity: high
>              Owner: akpm@osdl.org
>          Submitter: Ramiro.Voicu@cern.ch
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.17 ... as far as I
> remember ( for sure it works fine with 2.6.15.4 )
> 
> Distribution: Red Hat Enterprise Linux AS release 4 (Nahant Update 4) & Slackware 11
> 
> cat /proc/version
> Linux version 2.6.19-RH-server-250-lock (root@xxxx.cern.ch) (gcc version 3.4.6
> 20060404 (Red Hat 3.4.6-3)) #2 SMP Tue Dec 5 16:29:12 CET 2006
> 
> Hardware Environment:
> 
> CPU: 2CPU-s Dual core Opteron ( 4 entries in /proc/cpuinfo )
> <snip>
> model name      : Dual Core AMD Opteron(tm) Processor 275
> 
> cat /proc/modules
> myri10ge 41296 0 - Live 0xffffffff8806a000
> af_packet 19788 0 - Live 0xffffffff88064000
> binfmt_misc 10764 1 - Live 0xffffffff88060000
> dm_mirror 19776 0 - Live 0xffffffff8805a000
> dm_mod 55696 1 dm_mirror, Live 0xffffffff8804b000
> ohci_hcd 20292 0 - Live 0xffffffff88045000
> ehci_hcd 31304 0 - Live 0xffffffff8803c000
> usbcore 132840 3 ohci_hcd,ehci_hcd, Live 0xffffffff8801a000
> i2c_nforce2 7872 0 - Live 0xffffffff88017000
> i2c_core 20288 1 i2c_nforce2, Live 0xffffffff88011000
> floppy 62632 0 - Live 0xffffffff88000000
> 
> 
> Problem Description:
> 
> I am using a Java program ( based on NIO ) to do some data transfers. I have
> encountered the problem since 2.6.18 ( with all 2.6.18.x versions and all the
> -rc versions from 2.6.19 )
> 
> The problem appeared not only on the machine above, but also on my desktop
> machine with the same error in /var/log/messages. With 2.6.19-rc6 my machine
> freezes completly with no error reports.
> 
> When the kernel gets stuck I got the following message in the console:
> Message from syslogd@xxxxx at Thu Dec  7 04:17:21 2006 ...
> xxxxx kernel: [128531.708976] invalid opcode: 0000 [1] SMP
> 
> And in /var/log/messages:
> 
> Dec  7 04:17:21 xxxxx kernel: [128531.708947] ----------- [cut here ] ---------
> [please bite here ] ---------
> Dec  7 04:17:21 xxxxx kernel: [128531.708967] Kernel BUG at mm/memory.c:1124
> Dec  7 04:17:21 xxxxx kernel: [128531.708976] invalid opcode: 0000 [1] SMP
> Dec  7 04:17:21 xxxxx kernel: [128531.708988] CPU 0
> Dec  7 04:17:21 xxxxx kernel: [128531.708995] Modules linked in: myri10ge
> af_packet binfmt_misc dm_mirror dm_mod ohci_hcd ehci_hcd usbcore i2c_nforce2
> i2c_core floppy
> Dec  7 04:17:21 xxxxx kernel: [128531.709032] Pid: 21891, comm: java Not tainted
> 2.6.19-RH-server-250-lock #2
> Dec  7 04:17:21 xxxxx kernel: [128531.709045] RIP: 0010:[<ffffffff8026722b>] 
> [<ffffffff8026722b>] zeromap_page_range+0x2ab/0x330
> Dec  7 04:17:21 xxxxx kernel: [128531.709066] RSP: 0018:ffff81011639be38 
> EFLAGS: 00010202
> Dec  7 04:17:21 xxxxx kernel: [128531.709076] RAX: 0000000000000400 RBX:
> 8000000000629025 RCX: 000000000000001f
> Dec  7 04:17:21 xxxxx kernel: [128531.709090] RDX: ffff8100006a88f8 RSI:
> 00002aaaad781000 RDI: ffff8100006a88f8
> Dec  7 04:17:21 xxxxx kernel: [128531.709104] RBP: ffff8100006a88f8 R08:
> 0000000000000000 R09: 0000000000000000
> Dec  7 04:17:21 xxxxx kernel: [128531.709118] R10: 0000000000000002 R11:
> 0000000000000202 R12: ffff810062b20fa0
> Dec  7 04:17:21 xxxxx kernel: [128531.709161] R13: 00002aaaadbf4000 R14:
> ffff810065a81240 R15: ffff810069f21b68
> Dec  7 04:17:21 xxxxx kernel: [128531.709205] FS:  0000000043686960(0063)
> GS:ffffffff805b7000(0000) knlGS:00000000f7f1c6c0
> Dec  7 04:17:21 xxxxx kernel: [128531.709250] CS:  0010 DS: 0000 ES: 0000 CR0:
> 0000000080050033
> Dec  7 04:17:21 xxxxx kernel: [128531.709277] CR2: 00002b7df12d7f58 CR3:
> 0000000069888000 CR4: 00000000000006e0
> Dec  7 04:17:21 xxxxx kernel: [128531.709321] Process java (pid: 21891,
> threadinfo ffff81011639a000, task ffff81011bb7c100)
> Dec  7 04:17:21 xxxxx kernel: [128531.709365] Stack:  00002aaaadf80fff
> 00002aaaadf80fff 00002aaaadf80fff ffff810001c29f10
> Dec  7 04:17:21 xxxxx kernel: [128531.709413]  00002aaaadc00000 00002aaaadf81000
> ffff8100654ec550 00002aaaadf81000
> Dec  7 04:17:21 xxxxx kernel: [128531.709460]  00002aaaadf81000 ffff8100698882a8
> 8000000000000025 0000000000800000
> Dec  7 04:17:21 xxxxx kernel: [128531.709491] Call Trace:
> Dec  7 04:17:21 xxxxx kernel: [128531.709532]  [<ffffffff803b751f>]
> read_zero+0x14f/0x230
> Dec  7 04:17:21 xxxxx kernel: [128531.709561]  [<ffffffff802801f9>]
> vfs_read+0xe9/0x1b0
> Dec  7 04:17:21 xxxxx kernel: [128531.709587]  [<ffffffff802805e3>]
> sys_read+0x53/0x90
> Dec  7 04:17:21 xxxxx kernel: [128531.709615]  [<ffffffff80209b5e>]
> system_call+0x7e/0x83
> Dec  7 04:17:21 xxxxx kernel: [128531.709641]
> Dec  7 04:17:21 xxxxx kernel: [128531.709658]
> Dec  7 04:17:21 xxxxx kernel: [128531.709659] Code: 0f 0b 68 f0 9f 4e 80 c2 64
> 04 49 89 1c 24 49 81 c5 00 10 00
> Dec  7 04:17:21 xxxxx kernel: [128531.709737] RIP  [<ffffffff8026722b>]
> zeromap_page_range+0x2ab/0x330
> Dec  7 04:17:21 xxxxx kernel: [128531.709765]  RSP <ffff81011639be38>
> 
> 
>  My desktop machine is an Intel(R) Pentium(R) 4 CPU 3.20GHz with HT. The same
> application runs fine on Solaris10 ( also on my desktop ) and on older versions
> of Linux kernel.
> 


This is

	BUG_ON(!pte_none(*pte));

in zeromap_pte_range().

Could you please add this?

--- a/mm/memory.c~a
+++ a/mm/memory.c
@@ -1121,7 +1121,10 @@ static int zeromap_pte_range(struct mm_s
 		page_cache_get(page);
 		page_add_file_rmap(page);
 		inc_mm_counter(mm, file_rss);
-		BUG_ON(!pte_none(*pte));
+		if (!pte_none(*pte)) {
+			printk("pte_val: %lx\n", pte_val(*pte));
+			BUG();
+		}
 		set_pte_at(mm, addr, pte, zero_pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
