Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7D646B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 06:50:01 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p14so11272357pgq.2
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 03:50:01 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g13si6633150pgq.233.2018.01.10.03.49.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 03:49:59 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801052345.JBJ82317.tJVHFFOMOLFOQS@I-love.SAKURA.ne.jp>
	<201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
Message-Id: <201801102049.BGJ13564.OOOMtJLSFQFVHF@I-love.SAKURA.ne.jp>
Date: Wed, 10 Jan 2018 20:49:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com

Tetsuo Handa wrote:
> I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
> So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
> Does anyone know what is happening?

I simplified the reproducer and succeeded to reproduce this bug with both
i7-2630QM (8 core) and i5-4440S (4 core). Thus, I think that this bug is
not architecture specific.

---------- reproducer start ----------
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	if (argc != 1) {
		unsigned long long size;
		char *buf = NULL;
		unsigned long long i;
		for (size = 1048576; size < 512ULL * (1 << 30); size += 1048576) {
			char *cp = realloc(buf, size);
			if (!cp) {
				size -= 1048576;
				break;
			}
			buf = cp;
		}
		for (i = 0; i < size; i += 4096)
			buf[i] = 0;
		_exit(0);
	} else
		while (1)
			if (fork() == 0)
				execlp(argv[0], argv[0], "", NULL);
	return 0;
}
---------- reproducer end ----------

This bug occurs immediately after a process terminated
(not limited to being killed by the OOM-killer).

----------
[  100.838906] Out of memory: Kill process 891 (a.out) score 14 or sacrifice child
[  100.841891] Killed process 891 (a.out) total-vm:2099260kB, anon-rss:47312kB, file-rss:8kB, shmem-rss:0kB
[  100.847395] BUG: Bad page state in process a.out  pfn:3e6a9
[  100.849515] page:f5d19a68 count:0 mapcount:9 mapping:f3d57c8c index:0x0
[  100.851773] flags: 0x3e010019(locked|uptodate|dirty|mappedtodisk)
[  100.853950] raw: 3e010019 f3d57c8c 00000000 00000008 00000000 00000100 00000200 00000000
[  100.856738] raw: 00000000 00000000
[  100.858510] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[  100.860880] bad because of flags: 0x1(locked)
[  100.862685] Modules linked in: xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix mptbase libata
[  100.867413] CPU: 0 PID: 919 Comm: a.out Not tainted 4.15.0-rc7+ #196
[  100.869521] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  100.874256] Call Trace:
[  100.875664]  dump_stack+0x58/0x76
[  100.878332]  bad_page+0xc4/0x140
[  100.879911]  free_pages_check_bad+0x5b/0x5e
[  100.882825]  free_unref_page+0x149/0x160
[  100.884498]  __put_page+0x2e/0x40
[  100.886089]  try_to_unmap_one+0x37d/0x590
[  100.887839]  rmap_walk_file+0x13c/0x250
[  100.890229]  rmap_walk+0x32/0x60
[  100.893452]  try_to_unmap+0x4d/0x100
[  100.895316]  ? page_remove_rmap+0x2e0/0x2e0
[  100.897142]  ? page_not_mapped+0x10/0x10
[  100.898815]  ? page_get_anon_vma+0x80/0x80
[  100.900539]  shrink_page_list+0x3a2/0x1000
[  100.902247]  shrink_inactive_list+0x1b2/0x440
[  100.904431]  shrink_node_memcg+0x34a/0x770
[  100.906126]  shrink_node+0xbb/0x2e0
[  100.910555]  do_try_to_free_pages+0xba/0x320
[  100.913526]  try_to_free_pages+0x11d/0x330
[  100.915234]  __alloc_pages_slowpath+0x303/0x6d9
[  100.916941]  ? __accumulate_pelt_segments+0x32/0x50
[  100.918991]  __alloc_pages_nodemask+0x16d/0x180
[  100.921866]  do_anonymous_page+0xab/0x4f0
[  100.926874]  handle_mm_fault+0x531/0x8d0
[  100.929028]  ? __phys_addr+0x32/0x70
[  100.930829]  ? load_new_mm_cr3+0x6a/0x90
[  100.932898]  __do_page_fault+0x1ea/0x4d0
[  100.939138]  ? __do_page_fault+0x4d0/0x4d0
[  100.944536]  do_page_fault+0x1a/0x20
[  100.948193]  common_exception+0x6f/0x76
[  100.951431] EIP: 0x8048437
[  100.952710] EFLAGS: 00010202 CPU: 0
[  100.954576] EAX: 01e7c000 EBX: 7ff00000 ECX: 39d6a008 EDX: 00000000
[  100.957048] ESI: 7ff00000 EDI: 00000000 EBP: bfc49318 ESP: bfc492e0
[  100.960794]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  100.965552] Disabling lock debugging due to kernel taint
[  100.967496] page:f5d19a68 count:0 mapcount:0 mapping:f3d57c8c index:0x0
[  100.969872] flags: 0x3e030078(uptodate|dirty|lru|active|mappedtodisk|reclaim)
[  100.976635] raw: 3e030078 f3d57c8c 00000000 ffffffff 00000000 f400f680 f400f680 00000000
[  100.979529] raw: 00000000 00000000
[  100.981347] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[  100.983838] ------------[ cut here ]------------
[  100.986268] kernel BUG at ./include/linux/mm.h:483!
[  100.990886] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  100.993122] Modules linked in: xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix mptbase libata
[  100.997779] CPU: 0 PID: 919 Comm: a.out Tainted: G    B            4.15.0-rc7+ #196
[  101.000477] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  101.004621] EIP: put_page_testzero.part.53+0xd/0xf
[  101.006692] EFLAGS: 00010086 CPU: 0
[  101.008524] EAX: 00000000 EBX: f400f668 ECX: c19dd988 EDX: 00000086
[  101.011584] ESI: f5d19a7c EDI: 00000003 EBP: f2e15bcc ESP: f2e15bcc
[  101.013808]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  101.015759] CR0: 80050033 CR2: 38a1e008 CR3: 3197e000 CR4: 001406d0
[  101.017934] Call Trace:
[  101.019235]  putback_inactive_pages+0x384/0x3c0
[  101.021417]  shrink_inactive_list+0x205/0x440
[  101.023592]  shrink_node_memcg+0x34a/0x770
[  101.025453]  shrink_node+0xbb/0x2e0
[  101.027097]  do_try_to_free_pages+0xba/0x320
[  101.028729]  try_to_free_pages+0x11d/0x330
[  101.030419]  __alloc_pages_slowpath+0x303/0x6d9
[  101.032194]  ? __accumulate_pelt_segments+0x32/0x50
[  101.034161]  __alloc_pages_nodemask+0x16d/0x180
[  101.035866]  do_anonymous_page+0xab/0x4f0
[  101.037464]  handle_mm_fault+0x531/0x8d0
[  101.039042]  ? __phys_addr+0x32/0x70
[  101.041023]  ? load_new_mm_cr3+0x6a/0x90
[  101.042784]  __do_page_fault+0x1ea/0x4d0
[  101.044805]  ? __do_page_fault+0x4d0/0x4d0
[  101.046503]  do_page_fault+0x1a/0x20
[  101.048046]  common_exception+0x6f/0x76
[  101.049637] EIP: 0x8048437
[  101.051098] EFLAGS: 00010202 CPU: 0
[  101.054732] EAX: 01e7c000 EBX: 7ff00000 ECX: 39d6a008 EDX: 00000000
[  101.058435] ESI: 7ff00000 EDI: 00000000 EBP: bfc49318 ESP: bfc492e0
[  101.062077]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  101.064576] Code: 55 ba 24 1a 7f c1 89 e5 e8 b2 2c 01 00 0f 0b 55 ba ec 2f 7f c1 89 e5 e8 a3 2c 01 00 0f 0b 55 ba a8 7b 7d c1 89 e5 e8 94 2c 01 00 <0f> 0b 55 ba b0 2e 7f c1 89 e5 e8 85 2c 01 00 0f 0b 90 90 90 55
[  101.074916] EIP: put_page_testzero.part.53+0xd/0xf SS:ESP: 0068:f2e15bcc
[  101.078189] ---[ end trace d34ac0a26b29ce39 ]---
----------

----------
[   30.998639] Out of memory: Kill process 330 (a.out) score 22 or sacrifice child
[   31.001106] Killed process 330 (a.out) total-vm:2099260kB, anon-rss:72524kB, file-rss:8kB, shmem-rss:0kB
[   31.042032] BUG: unable to handle kernel paging request at 3304001a
[   31.044552] IP: page_remove_rmap+0x14/0x2e0
[   31.046248] *pde = 00000000 
[   31.047722] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   31.049977] Modules linked in: xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix mptbase libata
[   31.054476] CPU: 0 PID: 474 Comm: a.out Not tainted 4.15.0-rc7+ #196
[   31.056620] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   31.060414] EIP: page_remove_rmap+0x14/0x2e0
[   31.062110] EFLAGS: 00010202 CPU: 0
[   31.063896] EAX: 33040016 EBX: f3096c20 ECX: 0000015a EDX: 00000000
[   31.066797] ESI: 00000159 EDI: f48b92f8 EBP: f10cda9c ESP: f10cda94
[   31.069081]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   31.071035] CR0: 80050033 CR2: 3304001a CR3: 31100000 CR4: 001406d0
[   31.073261] Call Trace:
[   31.074534]  try_to_unmap_one+0x20e/0x590
[   31.076124]  rmap_walk_file+0x13c/0x250
[   31.077652]  rmap_walk+0x32/0x60
[   31.079000]  try_to_unmap+0x4d/0x100
[   31.080381]  ? page_remove_rmap+0x2e0/0x2e0
[   31.082397]  ? page_not_mapped+0x10/0x10
[   31.084272]  ? page_get_anon_vma+0x80/0x80
[   31.085852]  shrink_page_list+0x3a2/0x1000
[   31.087260]  shrink_inactive_list+0x1b2/0x440
[   31.088728]  shrink_node_memcg+0x34a/0x770
[   31.090099]  shrink_node+0xbb/0x2e0
[   31.091376]  do_try_to_free_pages+0xba/0x320
[   31.092908]  try_to_free_pages+0x11d/0x330
[   31.094272]  ? __wake_up+0x1a/0x20
[   31.095515]  __alloc_pages_slowpath+0x303/0x6d9
[   31.097094]  ? debug_object_activate+0x126/0x1d0
[   31.099222]  ? ktime_get+0x47/0xf0
[   31.100605]  __alloc_pages_nodemask+0x16d/0x180
[   31.102142]  do_anonymous_page+0xab/0x4f0
[   31.103546]  handle_mm_fault+0x531/0x8d0
[   31.104844]  ? pick_next_task_fair+0xe1/0x490
[   31.106201]  ? irq_exit+0x45/0xb0
[   31.107822]  ? smp_apic_timer_interrupt+0x4b/0x80
[   31.109289]  __do_page_fault+0x1ea/0x4d0
[   31.110631]  ? __do_page_fault+0x4d0/0x4d0
[   31.112277]  do_page_fault+0x1a/0x20
[   31.113990]  common_exception+0x6f/0x76
[   31.115879] EIP: 0x8048437
[   31.117195] EFLAGS: 00010202 CPU: 0
[   31.118702] EAX: 00c4f000 EBX: 7ff00000 ECX: 38acc008 EDX: 00000000
[   31.120624] ESI: 7ff00000 EDI: 00000000 EBP: bf937a08 ESP: bf9379d0
[   31.122365]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   31.124045] Code: c4 fe ff ff ba ec 32 7f c1 89 d8 e8 97 e5 fe ff 0f 0b 83 e8 01 eb 8e 55 89 e5 56 53 89 c3 8b 40 14 a8 01 0f 85 be 01 00 00 89 d8 <f6> 40 04 01 74 5e 84 d2 0f 85 9e 00 00 00 3e 83 43 0c ff 78 07
[   31.129606] EIP: page_remove_rmap+0x14/0x2e0 SS:ESP: 0068:f10cda94
[   31.131409] CR2: 000000003304001a
[   31.133754] ---[ end trace bee2e936b4fd74fc ]---
----------

I can hit this bug with CONFIG_SMP=y CONFIG_PREEMPT_NONE=y nosmp init=/bin/bash
but so far I haven't hit this bug with CONFIG_SMP=n .
Config is at http://I-love.SAKURA.ne.jp/tmp/config-4.15-rc7 .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
