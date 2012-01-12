Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 849186B006E
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 00:21:55 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 12 Jan 2012 10:51:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0C5Lipo3751992
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:51:45 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0C5LhhP028528
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:51:44 +0530
Message-ID: <4F0E6DE5.4080806@linux.vnet.ibm.com>
Date: Thu, 12 Jan 2012 10:51:41 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Several bugs in latest kernel
References: <4F0DCFFC.5040805@linux.vnet.ibm.com> <20120111190829.GG4118@suse.de>
In-Reply-To: <20120111190829.GG4118@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 01/12/2012 12:38 AM, Mel Gorman wrote:

> On Wed, Jan 11, 2012 at 11:37:56PM +0530, Srivatsa S. Bhat wrote:
>> Hi,
>> I was running the latest kernel and not doing anything in particular.
>> Eventually the machine locked up hard and due to my config setting
>> (panic on hard-lockup), I got a kernel panic.
>>
>> Looks like there are several issues involved.
>>
> 
> Not sure why you are sending this directly to me but anyway;


No particular reason. I was just Cc'ing mm developers and you just happened
to come first on my list :-)

> 
> When you say "not doing anything in particular", what do you mean? Does
> this happen early in boot or just when running even light loads?
> 

This happened only once and at that time, I was not running any jobs at all.
The system was idle. I was working on some other system and when I got
back to this one, I saw that it was completely hung and then I observed the
hard-lockup and kernel panic on the console.

> By latest kernel, your log says 3.2.0-0.0.0.28.36b5ec9-default. The
> 3.2.0 is clear enough. What is 0.0.0.28.36b5ec9? It does not look like a
> mainline git commit so have you applied some other patches or tree on
> top?
> 

This is the latest mainline tree as of yesterday when I tested it
(git commit e343a895a) and this is after 3.2. (Ignore what the log says please).

There were 2 quite unrelated patches I had applied on top of this:
- a patch related to bnx2 (broadcom) to get my network working.
- the MCE related rcu splat fix patch posted in
  https://lkml.org/lkml/2012/1/11/177
  

> If there are other patches applied, can you try vanilla 3.2? If that
> fails, did 3.1 work? If yes, can you you bisect it? If you do not have
> time for a full bisect, it might help to begin the bisect near commit
> [02125a8: fix apparmor dereferencing potentially freed dentry, sanitize
> __d_path() API]. Alternatively testing with apparmor=0 might be useful.
> 


I had not hit this problem with 3.2-rc7 (the last kernel I ran before running
this one). Commit 02125a8 seems to be from 3.2-rc5.

> The first bug triggered in mm/slab.c and everything after that looks
> like fallout from the first BUG_ON so that is worth figuring out first.
> 
>> Here is the log:
>>
>> [ 7314.423828] ------------[ cut here ]------------
>> [ 7314.427769] kernel BUG at mm/slab.c:3111!
>> [ 7314.427769] invalid opcode: 0000 [#1] SMP 
> 
> This in itself is suspicious. On kernel 3.2, this does not correspond
> to a BUG_ON (the closest BUG_ON is in line 3109). In the latest git,
> there is a BUG_ON on 3111 but that does not match your commit. Test
> again with vanilla 3.2.
> 
> 

As I said, my kernel _is_ the latest git. Please ignore what the log says.
Thank you very much for your inputs, I will see if this problem occurs
on vanilla 3.2 as well.

> 
>> [ 7314.427769] CPU 3 
>> [ 7314.427769] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf microcode fuse loop dm_mod bnx2 ioatdma tpm_tis tpm cdc_ether usbnet i2c_i801 iTCO_wdt mii i7core_edac i2c_core dca edac_core iTCO_vendor_support rtc_cmos tpm_bios shpchp pci_hotplug button pcspkr serio_raw sg uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
>> [ 7314.427769] 
>> [ 7314.427769] Pid: 6699, comm: cron Tainted: G        W    3.2.0-0.0.0.28.36b5ec9-default #3 IBM IBM System x -[7870C4Q]-/68Y8033     
>> [ 7314.427769] RIP: 0010:[<ffffffff8115bcf9>]  [<ffffffff8115bcf9>] cache_alloc_refill+0x1e9/0x290
>> [ 7314.427769] RSP: 0018:ffff8808c881bc48  EFLAGS: 00010046
>> [ 7314.427769] RAX: 000000000000000f RBX: ffff8808ca66b000 RCX: 0000000000000018
>> [ 7314.427769] RDX: ffff8808c7e2d040 RSI: ffff8808c8f60040 RDI: 0000000000000024
>> [ 7314.427769] RBP: ffff8808c881bc88 R08: ffff8808ff802510 R09: ffff8808ff802520
>> [ 7314.427769] R10: dead000000200200 R11: dead000000100100 R12: 0000000000000024
>> [ 7314.427769] R13: ffff8808ff800880 R14: ffff8808ff802500 R15: 0000000000000000
>> [ 7314.427769] FS:  00007fdcd8f54780(0000) GS:ffff8808ffcc0000(0000) knlGS:0000000000000000
>> [ 7314.427769] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 7314.427769] CR2: ffffffffff600400 CR3: 00000008c6e95000 CR4: 00000000000006e0
>> [ 7314.427769] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [ 7314.427769] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [ 7314.427769] Process cron (pid: 6699, threadinfo ffff8808c881a000, task ffff8808c68a0380)
>> [ 7314.427769] Stack:
>> [ 7314.427769]  ffffffff81785cf1 00000000000412d0 ffff8808ff802540 ffff8808ff800880
>> [ 7314.427769]  ffff8808ff800880 0000000000000100 00000000000000d0 00000000000000d0
>> [ 7314.427769]  ffff8808c881bcd8 ffffffff8115c7e7 ffff8808c881bd26 ffffffff81230418
>> [ 7314.427769] Call Trace:
>> [ 7314.427769]  [<ffffffff8115c7e7>] __kmalloc+0x327/0x330
>> [ 7314.427769]  [<ffffffff81230418>] ? aa_get_name+0x58/0x100
>> [ 7314.427769]  [<ffffffff81230418>] aa_get_name+0x58/0x100
>> [ 7314.427769]  [<ffffffff8120c229>] ? cap_bprm_set_creds+0x239/0x2a0
>> [ 7314.427769]  [<ffffffff81230d92>] apparmor_bprm_set_creds+0x112/0x580
>> [ 7314.427769]  [<ffffffff8109b44e>] ? __lock_release+0x7e/0x170
>> [ 7314.427769]  [<ffffffff81131e2e>] ? might_fault+0x4e/0xa0
>> [ 7314.427769]  [<ffffffff8120cbae>] security_bprm_set_creds+0xe/0x10
>> [ 7314.427769]  [<ffffffff8117b48a>] prepare_binprm+0xca/0x140
>> [ 7314.427769]  [<ffffffff8117d624>] do_execve_common+0x204/0x320
>> [ 7314.427769]  [<ffffffff8117d7ca>] do_execve+0x3a/0x40
>> [ 7314.427769]  [<ffffffff8100b079>] sys_execve+0x49/0x70
>> [ 7314.427769]  [<ffffffff8149c0fc>] stub_execve+0x6c/0xc0
>> [ 7314.427769] Code: 08 49 89 76 10 eb a6 0f 1f 00 49 8b 76 20 41 c7 86 90 00 00 00 01 00 00 00 49 39 f1 74 97 8b 46 20 41 3b 45 18 0f 82 02 ff ff ff <0f> 0b eb fe 0f 1f 00 41 39 c4 41 89 c7 45 0f 46 fc e9 ab fe ff 
>> [ 7314.427769] RIP  [<ffffffff8115bcf9>] cache_alloc_refill+0x1e9/0x290
>> [ 7314.427769]  RSP <ffff8808c881bc48>
> 
> This does not look familiar but I am not up to date on linux-mm. Pekka,
> does this ring a bell?
> 

 
Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
