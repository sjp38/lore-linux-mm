Message-ID: <4577A36B.6090803@cern.ch>
Date: Thu, 07 Dec 2006 06:15:23 +0100
From: Ramiro Voicu <Ramiro.Voicu@cern.ch>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
References: <200612070355.kB73tGf4021820@fire-2.osdl.org> <20061206201246.be7fb860.akpm@osdl.org>
In-Reply-To: <20061206201246.be7fb860.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

 Here is the stack trace after I've applied the patch


Dec  7 06:12:11 xxxx kernel: [  319.720340] pte_val: 629025
Dec  7 06:12:11 xxxx kernel: [  319.720422] ----------- [cut here ]
--------- [please bite here ] ---------
Dec  7 06:12:11 xxxx kernel: [  319.720467] Kernel BUG at mm/memory.c:1126
Dec  7 06:12:11 xxxx kernel: [  319.720505] invalid opcode: 0000 [1] SMP
Dec  7 06:12:11 xxxx kernel: [  319.720603] CPU 1
Dec  7 06:12:11 xxxx kernel: [  319.720666] Modules linked in: myri10ge
af_packet binfmt_misc dm_mirror dm_mod ohci_hcd ehci_hcd usbcore
i2c_nforce2 i2c_core floppy
Dec  7 06:12:11 xxxx kernel: [  319.721086] Pid: 4493, comm: java Not
tainted 2.6.19smp-250-lock-AM-patch #3
Dec  7 06:12:11 xxxx kernel: [  319.721131] RIP:
0010:[<ffffffff8026723b>]  [<ffffffff8026723b>]
zeromap_page_range+0x2bb/0x340
Dec  7 06:12:11 xxxx kernel: [  319.721213] RSP: 0018:ffff810121787e38
EFLAGS: 00010296
Dec  7 06:12:11 xxxx kernel: [  319.721254] RAX: 0000000000000022 RBX:
8000000000629025 RCX: ffffffff80541688
Dec  7 06:12:11 xxxx kernel: [  319.721299] RDX: ffffffff80541688 RSI:
0000000000000086 RDI: ffffffff80541680
Dec  7 06:12:11 xxxx kernel: [  319.721343] RBP: ffff8100006a88f8 R08:
0000000000000000 R09: 0000000000000064
Dec  7 06:12:11 xxxx kernel: [  319.721388] R10: 0000000000000080 R11:
0000000000000080 R12: ffff810078a7dae0
Dec  7 06:12:11 xxxx kernel: [  319.721433] R13: 00002aaab2f5c000 R14:
ffff81012c173240 R15: ffff81012aa31cb8
Dec  7 06:12:11 xxxx kernel: [  319.721478] FS:  0000000042676960(0063)
GS:ffff8100028dccc0(0000) knlGS:0000000000000000
Dec  7 06:12:11 xxxx kernel: [  319.721525] CS:  0010 DS: 0000 ES: 0000
CR0: 0000000080050033
Dec  7 06:12:11 xxxx kernel: [  319.721566] CR2: 00002b045ff65f2c CR3:
0000000125329000 CR4: 00000000000006e0
Dec  7 06:12:11 xxxx kernel: [  319.721625] Process java (pid: 4493,
threadinfo ffff810121786000, task ffff810122af88a0)
Dec  7 06:12:11 xxxx kernel: [  319.721696] Stack:  00002aaab350efff
00002aaab350efff 00002aaab350efff ffff8100020f7b68
Dec  7 06:12:11 xxxx kernel: [  319.721919]  00002aaab3000000
00002aaab350f000 ffff810123065550 00002aaab350f000
Dec  7 06:12:11 xxxx kernel: [  319.722109]  00002aaab350f000
ffff8101253292a8 8000000000000025 0000000000800000
Dec  7 06:12:11 xxxx kernel: [  319.722257] Call Trace:
Dec  7 06:12:11 xxxx kernel: [  319.722353]  [<ffffffff803b752f>]
read_zero+0x14f/0x230
Dec  7 06:12:11 xxxx kernel: [  319.722410]  [<ffffffff80280209>]
vfs_read+0xe9/0x1b0
Dec  7 06:12:11 xxxx kernel: [  319.722464]  [<ffffffff802805f3>]
sys_read+0x53/0x90
Dec  7 06:12:11 xxxx kernel: [  319.722520]  [<ffffffff80209b5e>]
system_call+0x7e/0x83
Dec  7 06:12:11 xxxx kernel: [  319.722575]
Dec  7 06:12:11 xxxx kernel: [  319.722620]
Dec  7 06:12:11 xxxx kernel: [  319.722621] Code: 0f 0b 68 f0 9f 4e 80
c2 66 04 49 89 1c 24 49 81 c5 00 10 00
Dec  7 06:12:11 xxxx kernel: [  319.723357] RIP  [<ffffffff8026723b>]
zeromap_page_range+0x2bb/0x340
Dec  7 06:12:11 xxxx kernel: [  319.723443]  RSP <ffff810121787e38>
Dec  7 06:12:17 xxxx ntpd[3057]: synchronized to LOCAL(0), stratum 10
Dec  7 06:12:17 xxxx ntpd[3057]: kernel time sync disabled 0041


Andrew Morton wrote:
> (switching to email - please retain all cc's).
> 
> On Wed, 6 Dec 2006 19:55:16 -0800
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=7645
>>
>>            Summary: Kernel BUG at mm/memory.c:1124
>>     Kernel Version: 2.6.19
>>             Status: NEW
>>           Severity: high
>>              Owner: akpm@osdl.org
>>          Submitter: Ramiro.Voicu@cern.ch
>>
>>
>> Most recent kernel where this bug did *NOT* occur: 2.6.17 ... as far as I
>> remember ( for sure it works fine with 2.6.15.4 )
>>
>> Distribution: Red Hat Enterprise Linux AS release 4 (Nahant Update 4) & Slackware 11
>>
>> cat /proc/version
>> Linux version 2.6.19-RH-server-250-lock (root@xxxx.cern.ch) (gcc version 3.4.6
>> 20060404 (Red Hat 3.4.6-3)) #2 SMP Tue Dec 5 16:29:12 CET 2006
>>
>> Hardware Environment:
>>
>> CPU: 2CPU-s Dual core Opteron ( 4 entries in /proc/cpuinfo )
>> <snip>
>> model name      : Dual Core AMD Opteron(tm) Processor 275
>>
>> cat /proc/modules
>> myri10ge 41296 0 - Live 0xffffffff8806a000
>> af_packet 19788 0 - Live 0xffffffff88064000
>> binfmt_misc 10764 1 - Live 0xffffffff88060000
>> dm_mirror 19776 0 - Live 0xffffffff8805a000
>> dm_mod 55696 1 dm_mirror, Live 0xffffffff8804b000
>> ohci_hcd 20292 0 - Live 0xffffffff88045000
>> ehci_hcd 31304 0 - Live 0xffffffff8803c000
>> usbcore 132840 3 ohci_hcd,ehci_hcd, Live 0xffffffff8801a000
>> i2c_nforce2 7872 0 - Live 0xffffffff88017000
>> i2c_core 20288 1 i2c_nforce2, Live 0xffffffff88011000
>> floppy 62632 0 - Live 0xffffffff88000000
>>
>>
>> Problem Description:
>>
>> I am using a Java program ( based on NIO ) to do some data transfers. I have
>> encountered the problem since 2.6.18 ( with all 2.6.18.x versions and all the
>> -rc versions from 2.6.19 )
>>
>> The problem appeared not only on the machine above, but also on my desktop
>> machine with the same error in /var/log/messages. With 2.6.19-rc6 my machine
>> freezes completly with no error reports.
>>
>> When the kernel gets stuck I got the following message in the console:
>> Message from syslogd@xxxxx at Thu Dec  7 04:17:21 2006 ...
>> xxxxx kernel: [128531.708976] invalid opcode: 0000 [1] SMP
>>
>> And in /var/log/messages:
>>
>> Dec  7 04:17:21 xxxxx kernel: [128531.708947] ----------- [cut here ] ---------
>> [please bite here ] ---------
>> Dec  7 04:17:21 xxxxx kernel: [128531.708967] Kernel BUG at mm/memory.c:1124
>> Dec  7 04:17:21 xxxxx kernel: [128531.708976] invalid opcode: 0000 [1] SMP
>> Dec  7 04:17:21 xxxxx kernel: [128531.708988] CPU 0
>> Dec  7 04:17:21 xxxxx kernel: [128531.708995] Modules linked in: myri10ge
>> af_packet binfmt_misc dm_mirror dm_mod ohci_hcd ehci_hcd usbcore i2c_nforce2
>> i2c_core floppy
>> Dec  7 04:17:21 xxxxx kernel: [128531.709032] Pid: 21891, comm: java Not tainted
>> 2.6.19-RH-server-250-lock #2
>> Dec  7 04:17:21 xxxxx kernel: [128531.709045] RIP: 0010:[<ffffffff8026722b>] 
>> [<ffffffff8026722b>] zeromap_page_range+0x2ab/0x330
>> Dec  7 04:17:21 xxxxx kernel: [128531.709066] RSP: 0018:ffff81011639be38 
>> EFLAGS: 00010202
>> Dec  7 04:17:21 xxxxx kernel: [128531.709076] RAX: 0000000000000400 RBX:
>> 8000000000629025 RCX: 000000000000001f
>> Dec  7 04:17:21 xxxxx kernel: [128531.709090] RDX: ffff8100006a88f8 RSI:
>> 00002aaaad781000 RDI: ffff8100006a88f8
>> Dec  7 04:17:21 xxxxx kernel: [128531.709104] RBP: ffff8100006a88f8 R08:
>> 0000000000000000 R09: 0000000000000000
>> Dec  7 04:17:21 xxxxx kernel: [128531.709118] R10: 0000000000000002 R11:
>> 0000000000000202 R12: ffff810062b20fa0
>> Dec  7 04:17:21 xxxxx kernel: [128531.709161] R13: 00002aaaadbf4000 R14:
>> ffff810065a81240 R15: ffff810069f21b68
>> Dec  7 04:17:21 xxxxx kernel: [128531.709205] FS:  0000000043686960(0063)
>> GS:ffffffff805b7000(0000) knlGS:00000000f7f1c6c0
>> Dec  7 04:17:21 xxxxx kernel: [128531.709250] CS:  0010 DS: 0000 ES: 0000 CR0:
>> 0000000080050033
>> Dec  7 04:17:21 xxxxx kernel: [128531.709277] CR2: 00002b7df12d7f58 CR3:
>> 0000000069888000 CR4: 00000000000006e0
>> Dec  7 04:17:21 xxxxx kernel: [128531.709321] Process java (pid: 21891,
>> threadinfo ffff81011639a000, task ffff81011bb7c100)
>> Dec  7 04:17:21 xxxxx kernel: [128531.709365] Stack:  00002aaaadf80fff
>> 00002aaaadf80fff 00002aaaadf80fff ffff810001c29f10
>> Dec  7 04:17:21 xxxxx kernel: [128531.709413]  00002aaaadc00000 00002aaaadf81000
>> ffff8100654ec550 00002aaaadf81000
>> Dec  7 04:17:21 xxxxx kernel: [128531.709460]  00002aaaadf81000 ffff8100698882a8
>> 8000000000000025 0000000000800000
>> Dec  7 04:17:21 xxxxx kernel: [128531.709491] Call Trace:
>> Dec  7 04:17:21 xxxxx kernel: [128531.709532]  [<ffffffff803b751f>]
>> read_zero+0x14f/0x230
>> Dec  7 04:17:21 xxxxx kernel: [128531.709561]  [<ffffffff802801f9>]
>> vfs_read+0xe9/0x1b0
>> Dec  7 04:17:21 xxxxx kernel: [128531.709587]  [<ffffffff802805e3>]
>> sys_read+0x53/0x90
>> Dec  7 04:17:21 xxxxx kernel: [128531.709615]  [<ffffffff80209b5e>]
>> system_call+0x7e/0x83
>> Dec  7 04:17:21 xxxxx kernel: [128531.709641]
>> Dec  7 04:17:21 xxxxx kernel: [128531.709658]
>> Dec  7 04:17:21 xxxxx kernel: [128531.709659] Code: 0f 0b 68 f0 9f 4e 80 c2 64
>> 04 49 89 1c 24 49 81 c5 00 10 00
>> Dec  7 04:17:21 xxxxx kernel: [128531.709737] RIP  [<ffffffff8026722b>]
>> zeromap_page_range+0x2ab/0x330
>> Dec  7 04:17:21 xxxxx kernel: [128531.709765]  RSP <ffff81011639be38>
>>
>>
>>  My desktop machine is an Intel(R) Pentium(R) 4 CPU 3.20GHz with HT. The same
>> application runs fine on Solaris10 ( also on my desktop ) and on older versions
>> of Linux kernel.
>>
> 
> 
> This is
> 
> 	BUG_ON(!pte_none(*pte));
> 
> in zeromap_pte_range().
> 
> Could you please add this?
> 
> --- a/mm/memory.c~a
> +++ a/mm/memory.c
> @@ -1121,7 +1121,10 @@ static int zeromap_pte_range(struct mm_s
>  		page_cache_get(page);
>  		page_add_file_rmap(page);
>  		inc_mm_counter(mm, file_rss);
> -		BUG_ON(!pte_none(*pte));
> +		if (!pte_none(*pte)) {
> +			printk("pte_val: %lx\n", pte_val(*pte));
> +			BUG();
> +		}
>  		set_pte_at(mm, addr, pte, zero_pte);
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
