Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92D236B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 06:02:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k7-v6so3910122iog.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 03:02:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u53-v6si600328jaj.74.2018.07.04.03.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 03:02:50 -0700 (PDT)
Subject: Re: kernel BUG at mm/gup.c:LINE!
References: <000000000000fe4b15057024bacd@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
Date: Wed, 4 Jul 2018 19:01:51 +0900
MIME-Version: 1.0
In-Reply-To: <000000000000fe4b15057024bacd@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com, zi.yan@cs.rutgers.edu

+Michal Hocko

On 2018/07/04 13:19, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    d3bc0e67f852 Merge tag 'for-4.18-rc2-tag' of git://git.ker..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=1000077c400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=a63be0c83e84d370
> dashboard link: https://syzkaller.appspot.com/bug?extid=5dcb560fe12aa5091c06
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> userspace arch: i386
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=158577a2400000

Here is C reproducer made from syz reproducer. mlockall(MCL_FUTURE) is involved.

This problem is triggerable by an unprivileged user.
Shows different result on x86_64 (crash) and x86_32 (stall).

------------------------------------------------------------
/* Need to compile using "-m32" option if host is 64bit. */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
int uselib(const char *library);

int main(int argc, char *argv[])
{
	int fd = open("file", O_WRONLY | O_CREAT, 0644);
	write(fd, "\x7f\x45\x4c\x46\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02"
	      "\x00\x06\x00\xca\x3f\x8b\xca\x00\x00\x00\x00\x38\x00\x00\x00\x00\x00"
	      "\x00\xf7\xff\xff\xff\xff\xff\xff\x1f\x00\x02\x00\x00\x00\x00\x00\x00"
	      "\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf8\x7b"
	      "\x66\xff\x00\x00\x05\x00\x00\x00\x76\x86\x00\x00\x00\x00\x00\x00\x00"
	      "\x00\x00\x00\x31\x0f\xf3\xee\xc1\xb0\x00\x0c\x08\x53\x55\xbe\x88\x47"
	      "\xc2\x2e\x30\xf5\x62\x82\xc6\x2c\x95\x72\x3f\x06\x8f\xe4\x2d\x27\x96"
	      "\xcc", 120);
	fchmod(fd, 0755);
	close(fd);
	mlockall(MCL_FUTURE); /* Removing this line avoids the bug. */
	uselib("file");
	return 0;
}
------------------------------------------------------------

------------------------------------------------------------
CentOS Linux 7 (Core)
Kernel 4.18.0-rc3 on an x86_64

localhost login: [   81.210241] emacs (9634) used greatest stack depth: 10416 bytes left
[  140.099935] ------------[ cut here ]------------
[  140.101904] kernel BUG at mm/gup.c:1242!
[  140.103572] invalid opcode: 0000 [#1] SMP
[  140.105220] CPU: 2 PID: 9667 Comm: a.out Not tainted 4.18.0-rc3 #644
[  140.107762] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  140.112000] RIP: 0010:__mm_populate+0x1e2/0x1f0
[  140.113875] Code: 55 d0 65 48 33 14 25 28 00 00 00 89 d8 75 21 48 83 c4 20 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 75 18 f1 ff 0f 0b e8 6e 18 f1 ff <0f> 0b 31 db eb c9 e8 93 06 e0 ff 0f 1f 00 55 48 89 e5 53 48 89 fb 
[  140.121403] RSP: 0018:ffffc90000dffd78 EFLAGS: 00010293
[  140.123516] RAX: ffff8801366c63c0 RBX: 000000007bf81000 RCX: ffffffff813e4ee2
[  140.126352] RDX: 0000000000000000 RSI: 0000000000007676 RDI: 000000007bf81000
[  140.129236] RBP: ffffc90000dffdc0 R08: 0000000000000000 R09: 0000000000000000
[  140.132110] R10: ffff880135895c80 R11: 0000000000000000 R12: 0000000000007676
[  140.134955] R13: 0000000000008000 R14: 0000000000000000 R15: 0000000000007676
[  140.137785] FS:  0000000000000000(0000) GS:ffff88013a680000(0063) knlGS:00000000f7db9700
[  140.140998] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[  140.143303] CR2: 00000000f7ea56e0 CR3: 0000000134674004 CR4: 00000000000606e0
[  140.145906] Call Trace:
[  140.146728]  vm_brk_flags+0xc3/0x100
[  140.147830]  vm_brk+0x1f/0x30
[  140.148714]  load_elf_library+0x281/0x2e0
[  140.149875]  __ia32_sys_uselib+0x170/0x1e0
[  140.151028]  ? copy_overflow+0x30/0x30
[  140.152105]  ? __ia32_sys_uselib+0x170/0x1e0
[  140.153301]  do_fast_syscall_32+0xca/0x420
[  140.154455]  entry_SYSENTER_compat+0x70/0x7f
[  140.155651] RIP: 0023:0xf7f9fc99
[  140.156568] Code: 89 c8 74 02 89 0a 5b 5d c3 8b 04 24 c3 8b 0c 24 c3 8b 1c 24 c3 8b 3c 24 c3 90 90 90 90 90 90 90 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90 
[  140.161951] RSP: 002b:00000000ffcca47c EFLAGS: 00000246 ORIG_RAX: 0000000000000056
[  140.164292] RAX: ffffffffffffffda RBX: 0000000008048614 RCX: 00000000000001ed
[  140.166390] RDX: 0000000000000003 RSI: 0000000000000000 RDI: 0000000000000000
[  140.168400] RBP: 00000000ffcca4a8 R08: 0000000000000000 R09: 0000000000000000
[  140.170352] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[  140.172302] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[  140.174255] Modules linked in:
[  140.175255] ---[ end trace d38f4666ebf4809c ]---
[  140.176838] RIP: 0010:__mm_populate+0x1e2/0x1f0
[  140.178239] Code: 55 d0 65 48 33 14 25 28 00 00 00 89 d8 75 21 48 83 c4 20 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 75 18 f1 ff 0f 0b e8 6e 18 f1 ff <0f> 0b 31 db eb c9 e8 93 06 e0 ff 0f 1f 00 55 48 89 e5 53 48 89 fb 
[  140.183795] RSP: 0018:ffffc90000dffd78 EFLAGS: 00010293
[  140.185293] RAX: ffff8801366c63c0 RBX: 000000007bf81000 RCX: ffffffff813e4ee2
[  140.187285] RDX: 0000000000000000 RSI: 0000000000007676 RDI: 000000007bf81000
[  140.189282] RBP: ffffc90000dffdc0 R08: 0000000000000000 R09: 0000000000000000
[  140.191298] R10: ffff880135895c80 R11: 0000000000000000 R12: 0000000000007676
[  140.193478] R13: 0000000000008000 R14: 0000000000000000 R15: 0000000000007676
[  140.195740] FS:  0000000000000000(0000) GS:ffff88013a680000(0063) knlGS:00000000f7db9700
[  140.198178] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[  140.199864] CR2: 00000000f7ea56e0 CR3: 0000000134674004 CR4: 00000000000606e0
[  140.201998] Kernel panic - not syncing: Fatal exception
------------------------------------------------------------

------------------------------------------------------------
CentOS Linux 7 (AltArch)
Kernel 4.18.0-rc3-00113-gfc36def on an i686

localhost login: [  231.139466] INFO: rcu_sched self-detected stall on CPU
[  231.140169] INFO: rcu_sched detected stalls on CPUs/tasks:
[  231.141010] 	5-....: (20761 ticks this GP) idle=0b6/1/1073741826 softirq=1654/1654 fqs=5193 
[  231.145209] 	
[  231.145213] 	5-....: (20761 ticks this GP) idle=0b6/1/1073741826 softirq=1654/1654 fqs=5194 
[  231.145216]  (t=21003 jiffies g=884 c=883 q=12)
[  231.145777] 	
[  231.148182] NMI backtrace for cpu 5
[  231.149527] (detected by 4, t=21011 jiffies, g=884, c=883, q=12)
[  231.150049] CPU: 5 PID: 956 Comm: a.out Not tainted 4.18.0-rc3-00113-gfc36def #365
[  231.155315] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  231.158549] Call Trace:
[  231.159341]  dump_stack+0x57/0x7b
[  231.160422]  nmi_cpu_backtrace+0xc4/0xd0
[  231.161641]  nmi_trigger_cpumask_backtrace+0x9a/0xe0
[  231.163174]  ? vprintk_default+0x32/0x40
[  231.164408]  ? lapic_can_unplug_cpu+0xa0/0xa0
[  231.165760]  arch_trigger_cpumask_backtrace+0x10/0x20
[  231.167321]  rcu_dump_cpu_stacks+0x6f/0x96
[  231.168596]  rcu_check_callbacks+0x532/0x680
[  231.169994]  ? account_process_tick+0x55/0x120
[  231.171371]  ? tick_sched_do_timer+0x50/0x50
[  231.172700]  update_process_times+0x23/0x50
[  231.174016]  tick_sched_handle+0x3a/0x50
[  231.175277]  tick_sched_timer+0x34/0x80
[  231.176492]  __hrtimer_run_queues+0xe4/0x170
[  231.177822]  hrtimer_interrupt+0x10d/0x2b0
[  231.179101]  smp_apic_timer_interrupt+0x4f/0x90
[  231.180511]  ? smp_apic_timer_interrupt+0x54/0x90
[  231.181968]  apic_timer_interrupt+0x3c/0x44
[  231.183262] EIP: __get_user_pages+0x3/0x3e0
[  231.184559] Code: e4 89 f0 89 1c 24 e8 fc 1b 03 00 8b 55 e4 c6 02 00 85 c0 0f 85 b0 fb ff ff e9 21 fd ff ff 89 f6 8d bc 27 00 00 00 00 55 89 e5 <57> 56 53 83 ec 44 8b 7d 08 89 45 dc 8b 45 10 89 55 d8 89 4d e8 89 
[  231.190324] EAX: f2301300 EBX: 00001053 ECX: 7bf88000 EDX: f235c240
[  231.192259] ESI: 7bf88000 EDI: f6ebbea4 EBP: f6ebbe5c ESP: f6ebbe5c
[  231.194170] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00000206
[  231.196252]  populate_vma_page_range+0x77/0x80
[  231.197631]  __mm_populate+0x8c/0x110
[  231.198780]  vm_brk_flags+0xab/0xc0
[  231.199867]  vm_brk+0xa/0x10
[  231.200803]  load_elf_library+0x1c0/0x1e0
[  231.202073]  sys_uselib+0x11a/0x160
[  231.203266]  do_fast_syscall_32+0x95/0x188
[  231.204562]  entry_SYSENTER_32+0x4e/0x7c
[  231.205787] EIP: 0xb7f98fd1
[  231.206676] Code: c1 9e f3 ff ff 89 e5 8b 55 08 85 d2 8b 81 64 cd ff ff 74 02 89 02 5d c3 8b 0c 24 c3 8b 1c 24 c3 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 8d 76 00 58 b8 77 00 00 00 cd 80 90 8d 76 
[  231.212378] EAX: ffffffda EBX: 08048614 ECX: 000001ed EDX: 00000003
[  231.214302] ESI: 00000000 EDI: 00000000 EBP: bfbfaa28 ESP: bfbfa9fc
[  231.216223] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000246
[  231.218302] Sending NMI from CPU 4 to CPUs 5:
[  231.219719] NMI backtrace for cpu 5
[  231.219722] CPU: 5 PID: 956 Comm: a.out Not tainted 4.18.0-rc3-00113-gfc36def #365
[  231.219722] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  231.219726] EIP: queued_spin_lock_slowpath+0x32/0x200
[  231.219727] Code: 66 66 66 66 90 ba 01 00 00 00 8d b6 00 00 00 00 8b 01 85 c0 75 12 f0 0f b1 11 85 c0 75 f2 5b 5e 5f 5d c3 90 8d 74 26 00 f3 90 <eb> e4 8d 74 26 00 81 fa 00 01 00 00 66 90 0f 84 3f 01 00 00 81 e2 
[  231.219745] EAX: 00000001 EBX: 00000001 ECX: d66ce500 EDX: 00000001
[  231.219746] ESI: 00000046 EDI: d66ce500 EBP: f6ebbcf0 ESP: f6ebbce4
[  231.219747] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00000002
[  231.219748] CR0: 80050033 CR2: b7ebb3f0 CR3: 32646760 CR4: 000406f0
[  231.219788] Call Trace:
[  231.219792]  _raw_spin_lock_irqsave+0x33/0x40
[  231.219795]  rcu_check_callbacks+0x539/0x680
[  231.219798]  ? account_process_tick+0x55/0x120
[  231.219801]  ? tick_sched_do_timer+0x50/0x50
[  231.219803]  update_process_times+0x23/0x50
[  231.219804]  tick_sched_handle+0x3a/0x50
[  231.219806]  tick_sched_timer+0x34/0x80
[  231.219807]  __hrtimer_run_queues+0xe4/0x170
[  231.219809]  hrtimer_interrupt+0x10d/0x2b0
[  231.219811]  smp_apic_timer_interrupt+0x4f/0x90
[  231.219812]  ? smp_apic_timer_interrupt+0x54/0x90
[  231.219814]  apic_timer_interrupt+0x3c/0x44
[  231.219816] EIP: __get_user_pages+0x3/0x3e0
[  231.219816] Code: e4 89 f0 89 1c 24 e8 fc 1b 03 00 8b 55 e4 c6 02 00 85 c0 0f 85 b0 fb ff ff e9 21 fd ff ff 89 f6 8d bc 27 00 00 00 00 55 89 e5 <57> 56 53 83 ec 44 8b 7d 08 89 45 dc 8b 45 10 89 55 d8 89 4d e8 89 
[  231.219834] EAX: f2301300 EBX: 00001053 ECX: 7bf88000 EDX: f235c240
[  231.219835] ESI: 7bf88000 EDI: f6ebbea4 EBP: f6ebbe5c ESP: f6ebbe5c
[  231.219836] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00000206
[  231.219838]  populate_vma_page_range+0x77/0x80
[  231.219840]  __mm_populate+0x8c/0x110
[  231.219842]  vm_brk_flags+0xab/0xc0
[  231.219844]  vm_brk+0xa/0x10
[  231.219846]  load_elf_library+0x1c0/0x1e0
[  231.219849]  sys_uselib+0x11a/0x160
[  231.219850]  do_fast_syscall_32+0x95/0x188
[  231.219852]  entry_SYSENTER_32+0x4e/0x7c
[  231.219853] EIP: 0xb7f98fd1
[  231.219854] Code: c1 9e f3 ff ff 89 e5 8b 55 08 85 d2 8b 81 64 cd ff ff 74 02 89 02 5d c3 8b 0c 24 c3 8b 1c 24 c3 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 8d 76 00 58 b8 77 00 00 00 cd 80 90 8d 76 
[  231.219872] EAX: ffffffda EBX: 08048614 ECX: 000001ed EDX: 00000003
[  231.219873] ESI: 00000000 EDI: 00000000 EBP: bfbfaa28 ESP: bfbfa9fc
[  231.219874] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000246
[  294.144215] INFO: rcu_sched self-detected stall on CPU
[  294.145578] INFO: rcu_sched detected stalls on CPUs/tasks:
[  294.145926] 	5-....: (83606 ticks this GP) idle=0b6/1/1073741826 softirq=1654/1654 fqs=20101 
[  294.145927] 	
[  294.147855] 	5-....: (83606 ticks this GP) idle=0b6/1/1073741826 softirq=1654/1654 fqs=20101 
[  294.150966]  (t=84007 jiffies g=884 c=883 q=411)
[  294.151577] 	
[  294.154593] NMI backtrace for cpu 5
[  294.156334] (detected by 4, t=84007 jiffies, g=884, c=883, q=411)
[  294.156958] CPU: 5 PID: 956 Comm: a.out Not tainted 4.18.0-rc3-00113-gfc36def #365
[  294.163053] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  294.166957] Call Trace:
[  294.167772]  dump_stack+0x57/0x7b
[  294.168860]  nmi_cpu_backtrace+0xc4/0xd0
[  294.170289]  nmi_trigger_cpumask_backtrace+0x9a/0xe0
[  294.171852]  ? vprintk_default+0x32/0x40
[  294.173228]  ? lapic_can_unplug_cpu+0xa0/0xa0
[  294.174801]  arch_trigger_cpumask_backtrace+0x10/0x20
[  294.176446]  rcu_dump_cpu_stacks+0x6f/0x96
[  294.177803]  rcu_check_callbacks+0x532/0x680
[  294.179231]  ? account_process_tick+0x55/0x120
[  294.180643]  ? tick_sched_do_timer+0x50/0x50
[  294.182056]  update_process_times+0x23/0x50
[  294.183408]  tick_sched_handle+0x3a/0x50
[  294.184664]  tick_sched_timer+0x34/0x80
[  294.185874]  __hrtimer_run_queues+0xe4/0x170
[  294.187221]  hrtimer_interrupt+0x10d/0x2b0
[  294.188657]  ? apic_timer_interrupt+0x3c/0x44
[  294.190079]  smp_apic_timer_interrupt+0x4f/0x90
[  294.191720]  apic_timer_interrupt+0x3c/0x44
[  294.193175] EIP: populate_vma_page_range+0x19/0x80
[  294.194722] Code: 2d 04 f3 ff 0f 0b 0f 0b 89 f6 8d bc 27 00 00 00 00 55 89 e5 57 56 89 d6 53 29 f1 83 ec 18 8b 50 20 8b 40 2c c1 e9 0c 89 0c 24 <89> f1 c7 44 24 0c 00 00 00 00 89 55 f0 89 c3 89 c7 81 e3 00 00 08 
[  294.200571] EAX: 00102073 EBX: f600e888 ECX: 00000000 EDX: f235c240
[  294.202604] ESI: 7bf88000 EDI: 7bf88000 EBP: f6ebbe88 ESP: f6ebbe64
[  294.204756] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00000246
[  294.207295]  __mm_populate+0x8c/0x110
[  294.208653]  vm_brk_flags+0xab/0xc0
[  294.209949]  vm_brk+0xa/0x10
[  294.211018]  load_elf_library+0x1c0/0x1e0
[  294.212580]  sys_uselib+0x11a/0x160
[  294.213901]  do_fast_syscall_32+0x95/0x188
[  294.215436]  entry_SYSENTER_32+0x4e/0x7c
[  294.216955] EIP: 0xb7f98fd1
[  294.217995] Code: c1 9e f3 ff ff 89 e5 8b 55 08 85 d2 8b 81 64 cd ff ff 74 02 89 02 5d c3 8b 0c 24 c3 8b 1c 24 c3 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 8d 76 00 58 b8 77 00 00 00 cd 80 90 8d 76 
[  294.224703] EAX: ffffffda EBX: 08048614 ECX: 000001ed EDX: 00000003
[  294.226681] ESI: 00000000 EDI: 00000000 EBP: bfbfaa28 ESP: bfbfa9fc
[  294.228654] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000246
[  294.230799] Sending NMI from CPU 4 to CPUs 5:
[  294.253453] NMI backtrace for cpu 5
[  294.253458] CPU: 5 PID: 956 Comm: a.out Not tainted 4.18.0-rc3-00113-gfc36def #365
[  294.253459] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  294.253465] EIP: __mm_populate+0x7a/0x110
[  294.253466] Code: 39 7b 04 77 03 8b 5b 08 85 db 74 6c 8b 03 8b 4d e8 39 c1 76 63 8b 73 04 39 f1 0f 46 f1 f7 43 2c 00 44 00 00 75 21 39 c7 89 f1 <0f> 42 f8 8d 45 ec 89 fa 89 04 24 89 d8 e8 f4 fe ff ff 85 c0 78 40 
[  294.253495] EAX: 7bf81000 EBX: f600e888 ECX: 7bf88676 EDX: f235c240
[  294.253496] ESI: 7bf88676 EDI: 7bf88000 EBP: f6ebbeb8 ESP: f6ebbe90
[  294.253498] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00000206
[  294.253499] CR0: 80050033 CR2: b7ebb3f0 CR3: 32646760 CR4: 000406f0
[  294.253608] Call Trace:
[  294.253613]  vm_brk_flags+0xab/0xc0
[  294.253616]  vm_brk+0xa/0x10
[  294.253619]  load_elf_library+0x1c0/0x1e0
[  294.253622]  sys_uselib+0x11a/0x160
[  294.253625]  do_fast_syscall_32+0x95/0x188
[  294.253630]  entry_SYSENTER_32+0x4e/0x7c
[  294.253632] EIP: 0xb7f98fd1
[  294.253632] Code: c1 9e f3 ff ff 89 e5 8b 55 08 85 d2 8b 81 64 cd ff ff 74 02 89 02 5d c3 8b 0c 24 c3 8b 1c 24 c3 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 8d 76 00 58 b8 77 00 00 00 cd 80 90 8d 76 
[  294.253660] EAX: ffffffda EBX: 08048614 ECX: 000001ed EDX: 00000003
[  294.253662] ESI: 00000000 EDI: 00000000 EBP: bfbfaa28 ESP: bfbfa9fc
[  294.253663] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000246
------------------------------------------------------------
