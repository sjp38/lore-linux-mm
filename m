Message-ID: <47CD4CE9.9060901@sgi.com>
Date: Tue, 04 Mar 2008 05:21:45 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86_64: Cleanup non-smp usage of cpu maps v3
References: <20080219203335.866324000@polaris-admin.engr.sgi.com>	<20080219203336.177905000@polaris-admin.engr.sgi.com> <20080303170235.4334e841.akpm@linux-foundation.org>
In-Reply-To: <20080303170235.4334e841.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, tglx@linutronix.de, ak@suse.de, clameter@sgi.com, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Andrew for catching this, I'll take a look.  Our "big box amd" system still has
a failing serial port, so I haven't been able to remotely test on it.

Regards,
Mike

Andrew Morton wrote:
> On Tue, 19 Feb 2008 12:33:37 -0800
> Mike Travis <travis@sgi.com> wrote:
> 
>> Cleanup references to the early cpu maps for the non-SMP configuration
>> and remove some functions called for SMP configurations only.
>>
>> Based on git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>>
> 
> My 8-way x86_64 box is crashing with this patch series applied.
> 
> Quite late in boot, when modules are being loaded:
> 
> 
> SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
> SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
> SELinux: policy loaded with handle_unknown=deny
> type=1403 audit(1204590434.779:3): policy loaded auid=4294967295 ses=4294967295
> BUG: unable to handle kernel paging request at ffff80ff81959078
> IP: [<ffffffff8025062d>] sys_init_module+0x135e/0x1a24
> PGD 0 
> Oops: 0002 [1] SMP 
> last sysfs file: /sys/devices/pnp0/00:17/id
> CPU 7 
> Modules linked in: dm_mirror dm_multipath dm_mod sbs sbshc dock battery ac parport_pc lp parport snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event floppy snd_seq snd_seq_device snd_pcm_oss sg snd_mixer_oss snd_pcm serio_raw ide_cd_mod cdrom snd_timer shpchp snd soundcore snd_page_alloc button pcspkr i2c_i801 i2c_core ehci_hcd ohci_hcd uhci_hcd
> Pid: 2969, comm: modprobe Not tainted 2.6.25-rc3-mm1 #9
> RIP: 0010:[<ffffffff8025062d>]  [<ffffffff8025062d>] sys_init_module+0x135e/0x1a24
> RSP: 0018:ffff81025a50de08  EFLAGS: 00010287
> RAX: ffff810001004000 RBX: 000000000000001c RCX: 000000000000001c
> RDX: 0000000000000000 RSI: ffffc20001b281b0 RDI: ffff80ff81959078
> RBP: ffffc20001b281b0 R08: 0000000000000000 R09: ffffc20001e8d800
> R10: ffffc20001e6d818 R11: 0000000000000002 R12: ffffffffa0300900
> R13: ffffc20001e6cfd8 R14: ffffffff80955078 R15: ffffc20001af3000
> FS:  00007f50a14066f0(0000) GS:ffff81000107b000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffff80ff81959078 CR3: 000000025b565000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process modprobe (pid: 2969, threadinfo ffff81025a50c000, task ffff81025dbbf380)
> Stack:  0000000000000000 00000000006180e0 ffffc20001e6dd98 ffffc20001e6d7d8
>  ffffc20001e6dd58 ffff81025b4f2e20 ffffc200021aef80 0000000000000036
>  0000000f00000000 0000000a00000000 0000000d00000011 0000000000000000
> Call Trace:
>  [<ffffffff80454696>] ? neigh_lookup+0x0/0xc0
>  [<ffffffff80310ca7>] ? selinux_file_permission+0x54/0x127
>  [<ffffffff8028cc93>] ? vfs_read+0xa8/0x131
>  [<ffffffff8020bceb>] ? system_call_after_swapgs+0x7b/0x80
> 
> 
> Code: 48 8b 58 20 48 8b 68 10 e8 ad 1b 0e 00 eb 2d 48 8b 05 70 56 5f 00 49 63 d0 4c 89 f7 fc 48 89 ee 48 89 d9 48 8b 04 d0 48 03 78 08 <f3> a4 48 c7 c6 40 d7 96 80 44 89 c7 e8 98 1b 0e 00 3d fe 00 00 
> RIP  [<ffffffff8025062d>] sys_init_module+0x135e/0x1a24
>  RSP <ffff81025a50de08>
> CR2: ffff80ff81959078
> ---[ end trace d72a6bcf35cfd5e6 ]---
> 
> 
> 
> 
> In percpu_modcopy():
> 
> (gdb) l *0xffffffff8025062d
> 0xffffffff8025062d is in sys_init_module (kernel/module.c:436).
> 431     static void percpu_modcopy(void *pcpudest, const void *from, unsigned long size)
> 432     {
> 433             int cpu;
> 434     
> 435             for_each_possible_cpu(cpu)
> 436                     memcpy(pcpudest + per_cpu_offset(cpu), from, size);
> 437     }
> 438     
> 439     static int percpu_modinit(void)
> 440     {
> 
> 
> Full boot log: http://userweb.kernel.org/~akpm/dmesg-akpm2.txt
> 
> .config: http://userweb.kernel.org/~akpm/config-akpm2.txt
> 
> 
> I was unable to bisect it more finely than this:
> 
> init-move-setup-of-nr_cpu_ids-to-as-early-as-possible-v3.patch
> generic-percpu-infrastructure-to-rebase-the-per-cpu-area-to-zero-v3.patch OK
> x86_64-fold-pda-into-per-cpu-area-v3.patch
> x86_64-fold-pda-into-per-cpu-area-v3-fix.patch				
> x86_64-cleanup-non-smp-usage-of-cpu-maps-v3.patch			BAD
> 
> because when x86_64-cleanup-non-smp-usage-of-cpu-maps-v3.patch was removed
> the machine hung quite early, when playing around with TSC calibration I
> think.
> 
> I'll drop 'em.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
