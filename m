Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 7C6176B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 12:24:10 -0400 (EDT)
Message-ID: <51BF3827.4060606@mozilla.com>
Date: Mon, 17 Jun 2013 12:24:07 -0400
From: Dhaval Giani <dgiani@mozilla.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Volatile Ranges (v8?)
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Content-Type: multipart/mixed;
 boundary="------------010507050700080703030301"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------010507050700080703030301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi John,

I have been giving your git tree a whirl, and in order to simulate a 
limited memory environment, I was using memory cgroups.

The program I was using to test is attached here. It is your test code, 
with some changes (changing the syscall interface, reducing the memory 
pressure to be generated).

I trapped it in a memory cgroup with 1MB memory.limit_in_bytes and hit this,

[  406.207612] ------------[ cut here ]------------
[  406.207621] kernel BUG at mm/vrange.c:523!
[  406.207626] invalid opcode: 0000 [#1] SMP
[  406.207631] Modules linked in:
[  406.207637] CPU: 0 PID: 1579 Comm: volatile-test Not tainted 
3.10.0-rc5+ #2
[  406.207650] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS 
VirtualBox 12/01/2006
[  406.207655] task: ffff880006fe0000 ti: ffff88001c8b0000 task.ti: 
ffff88001c8b0000
[  406.207659] RIP: 0010:[<ffffffff81155758>] [<ffffffff81155758>] 
try_to_discard_one+0x1f8/0x210
[  406.207667] RSP: 0000:ffff88001c8b1598  EFLAGS: 00010246
[  406.207671] RAX: 0000000000000000 RBX: 00007fde082c0000 RCX: 
ffff88001f199600
[  406.207675] RDX: 0000000000000006 RSI: 0000000000000007 RDI: 
0000000000000000
[  406.207679] RBP: ffff88001c8b15f8 R08: 0000000000000591 R09: 
0000000000000055
[  406.207683] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffffea00002ae2c0
[  406.207687] R13: ffff88001ef9e540 R14: ffff88001ef9e5e0 R15: 
ffff88000b7cfda8
[  406.207692] FS:  00007fde08320740(0000) GS:ffff88001fc00000(0000) 
knlGS:0000000000000000
[  406.207696] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  406.207700] CR2: 00007fde082c0000 CR3: 000000001f131000 CR4: 
00000000000006f0
[  406.207707] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  406.207711] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  406.207715] Stack:
[  406.207719]  0000000000000006 ffff88001f199600 ffff88001ef9e5d8 
0000000081154f16
[  406.207724]  ffff880000000001 ffffea00007c6670 ffff88001c8b15f8 
ffffea00002ae2c0
[  406.207729]  ffff88001f1386c0 ffff88001ef9e5d8 ffff88000b7cfda8 
ffff880005110a10
[  406.207734] Call Trace:
[  406.207743]  [<ffffffff81155b32>] discard_vpage+0x3c2/0x410
[  406.207753]  [<ffffffff81150881>] ? page_referenced+0x241/0x2c0
[  406.207762]  [<ffffffff8112e627>] shrink_page_list+0x397/0x950
[  406.207770]  [<ffffffff8112f12f>] shrink_inactive_list+0x14f/0x400
[  406.207778]  [<ffffffff8112f959>] shrink_lruvec+0x229/0x4e0
[  406.207787]  [<ffffffff8107e597>] ? wake_up_process+0x27/0x50
[  406.207795]  [<ffffffff8112fc76>] shrink_zone+0x66/0x1a0
[  406.207803]  [<ffffffff81130130>] do_try_to_free_pages+0x110/0x5a0
[  406.207812]  [<ffffffff8113074f>] try_to_free_mem_cgroup_pages+0xbf/0x140
[  406.207821]  [<ffffffff81179f6e>] mem_cgroup_reclaim+0x4e/0xe0
[  406.207829]  [<ffffffff8117a4ef>] __mem_cgroup_try_charge+0x4ef/0xbb0
[  406.207837]  [<ffffffff8117b29d>] mem_cgroup_charge_common+0x6d/0xd0
[  406.207846]  [<ffffffff8117cbeb>] mem_cgroup_newpage_charge+0x3b/0x50
[  406.207854]  [<ffffffff81142170>] do_wp_page+0x150/0x720
[  406.207862]  [<ffffffff811448ed>] handle_pte_fault+0x98d/0xae0
[  406.207871]  [<ffffffff811452c4>] handle_mm_fault+0x264/0x5e0
[  406.207880]  [<ffffffff8161c5b1>] __do_page_fault+0x171/0x4e0
[  406.207888]  [<ffffffff8161c92e>] ? do_page_fault+0xe/0x10
[  406.207896]  [<ffffffff81619172>] ? page_fault+0x22/0x30
[  406.207905]  [<ffffffff8161c92e>] do_page_fault+0xe/0x10
[  406.207913]  [<ffffffff81619172>] page_fault+0x22/0x30
[  406.207917] Code: c1 e7 39 48 09 c7 f0 49 ff 8d e8 02 00 00 48 89 55 
a0 48 89 4d a8 e8 78 42 00 00 85 c0 48 8b 55 a0 48 8b 4d a8 0f 85 50 ff 
ff ff <0f> 0b 66 0f 1f 44 00 00 31 db e9 7a fe ff ff 0f 0b e8 c1 aa 4b
[  406.207937] RIP  [<ffffffff81155758>] try_to_discard_one+0x1f8/0x210
[  406.207941]  RSP <ffff88001c8b1598>
[  406.207946] ---[ end trace fe9729b910a78aff ]---
[  406.207951] ------------[ cut here ]------------
[  406.207957] WARNING: at kernel/exit.c:715 do_exit+0x55/0xa30()
[  406.207960] Modules linked in:
[  406.207965] CPU: 0 PID: 1579 Comm: volatile-test Tainted: G D      
3.10.0-rc5+ #2
[  406.207969] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS 
VirtualBox 12/01/2006
[  406.207973]  0000000000000009 ffff88001c8b1288 ffffffff81612a03 
ffff88001c8b12c8
[  406.207978]  ffffffff81049bb0 ffff88001c8b14e8 000000000000000b 
ffff88001c8b14e8
[  406.207983]  0000000000000246 0000000000000000 ffff880006fe0000 
ffff88001c8b12d8
[  406.207988] Call Trace:
[  406.207997]  [<ffffffff81612a03>] dump_stack+0x19/0x1b
[  406.208189]  [<ffffffff81049bb0>] warn_slowpath_common+0x70/0xa0
[  406.208207]  [<ffffffff81049bfa>] warn_slowpath_null+0x1a/0x20
[  406.208222]  [<ffffffff8104f2e5>] do_exit+0x55/0xa30
[  406.208238]  [<ffffffff8160e4e0>] ? printk+0x61/0x63
[  406.208253]  [<ffffffff81619c9b>] oops_end+0x9b/0xe0
[  406.208269]  [<ffffffff81005908>] die+0x58/0x90
[  406.208285]  [<ffffffff8161956b>] do_trap+0x6b/0x170
[  406.208298]  [<ffffffff8161c9b2>] ? 
__atomic_notifier_call_chain+0x12/0x20
[  406.208309]  [<ffffffff81002e75>] do_invalid_op+0x95/0xb0
[  406.208317]  [<ffffffff81155758>] ? try_to_discard_one+0x1f8/0x210
[  406.208328]  [<ffffffff812b882e>] ? blk_queue_bio+0x32e/0x3b0
[  406.208338]  [<ffffffff81622128>] invalid_op+0x18/0x20
[  406.208348]  [<ffffffff81155758>] ? try_to_discard_one+0x1f8/0x210
[  406.208360]  [<ffffffff81155748>] ? try_to_discard_one+0x1e8/0x210
[  406.208370]  [<ffffffff81155b32>] discard_vpage+0x3c2/0x410
[  406.208383]  [<ffffffff81150881>] ? page_referenced+0x241/0x2c0
[  406.208394]  [<ffffffff8112e627>] shrink_page_list+0x397/0x950
[  406.208405]  [<ffffffff8112f12f>] shrink_inactive_list+0x14f/0x400
[  406.208417]  [<ffffffff8112f959>] shrink_lruvec+0x229/0x4e0
[  406.208429]  [<ffffffff8107e597>] ? wake_up_process+0x27/0x50
[  406.208440]  [<ffffffff8112fc76>] shrink_zone+0x66/0x1a0
[  406.208452]  [<ffffffff81130130>] do_try_to_free_pages+0x110/0x5a0
[  406.208464]  [<ffffffff8113074f>] try_to_free_mem_cgroup_pages+0xbf/0x140
[  406.208476]  [<ffffffff81179f6e>] mem_cgroup_reclaim+0x4e/0xe0
[  406.208489]  [<ffffffff8117a4ef>] __mem_cgroup_try_charge+0x4ef/0xbb0
[  406.208501]  [<ffffffff8117b29d>] mem_cgroup_charge_common+0x6d/0xd0
[  406.208514]  [<ffffffff8117cbeb>] mem_cgroup_newpage_charge+0x3b/0x50
[  406.208533]  [<ffffffff81142170>] do_wp_page+0x150/0x720
[  406.208543]  [<ffffffff811448ed>] handle_pte_fault+0x98d/0xae0
[  406.208556]  [<ffffffff811452c4>] handle_mm_fault+0x264/0x5e0
[  406.208568]  [<ffffffff8161c5b1>] __do_page_fault+0x171/0x4e0
[  406.208579]  [<ffffffff8161c92e>] ? do_page_fault+0xe/0x10
[  406.208591]  [<ffffffff81619172>] ? page_fault+0x22/0x30
[  406.208604]  [<ffffffff8161c92e>] do_page_fault+0xe/0x10
[  406.208615]  [<ffffffff81619172>] page_fault+0x22/0x30
[  406.208621] ---[ end trace fe9729b910a78b00 ]---
[  406.208643] BUG: Bad page map in process volatile-test 
pte:800000000ab8b005 pmd:163b2067
[  406.208651] page:ffffea00002ae2c0 count:3 mapcount:-1 
mapping:ffff88001bc769c1 index:0x7fde082c0
[  406.208657] page flags: 
0x3ff00000090009(locked|uptodate|swapcache|swapbacked)
[  406.208666] pc:ffff88001e12b8b0 pc->flags:2 
pc->mem_cgroup:ffff88000329f000
[  406.208672] addr:00007fde082c0000 vm_flags:00100073 
anon_vma:ffff88001f137dc0 mapping:          (null) index:7fde082c0
[  406.208678] CPU: 0 PID: 1579 Comm: volatile-test Tainted: G D W    
3.10.0-rc5+ #2
[  406.208683] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS 
VirtualBox 12/01/2006
[  406.208688]  ffff880005110a10 ffff88001c8b10b8 ffffffff81612a03 
ffff88001c8b1108
[  406.208695]  ffffffff81140d54 800000000ab8b005 00000007fde082c0 
ffff88001c8b1108
[  406.208703]  00007fde08323000 00007fde082c0000 ffff8800163b2600 
ffffea00002ae2c0
[  406.208710] Call Trace:
[  406.208722]  [<ffffffff81612a03>] dump_stack+0x19/0x1b
[  406.208742]  [<ffffffff81140d54>] print_bad_pte+0x194/0x230
[  406.208754]  [<ffffffff81142e8b>] unmap_single_vma+0x74b/0x810
[  406.208765]  [<ffffffff81143759>] unmap_vmas+0x49/0x60
[  406.208777]  [<ffffffff8114c311>] exit_mmap+0xb1/0x150
[  406.208790]  [<ffffffff8116af53>] ? kmem_cache_free+0x1d3/0x1f0
[  406.208802]  [<ffffffff81046f7f>] mmput+0x8f/0xf0
[  406.208814]  [<ffffffff8104f507>] do_exit+0x277/0xa30
[  406.208826]  [<ffffffff8160e4e0>] ? printk+0x61/0x63
[  406.208836]  [<ffffffff81619c9b>] oops_end+0x9b/0xe0
[  406.208845]  [<ffffffff81005908>] die+0x58/0x90
[  406.208854]  [<ffffffff8161956b>] do_trap+0x6b/0x170
[  406.208863]  [<ffffffff8161c9b2>] ? 
__atomic_notifier_call_chain+0x12/0x20
[  406.208874]  [<ffffffff81002e75>] do_invalid_op+0x95/0xb0
[  406.208951]  [<ffffffff81155758>] ? try_to_discard_one+0x1f8/0x210
[  406.208964]  [<ffffffff812b882e>] ? blk_queue_bio+0x32e/0x3b0
[  406.208977]  [<ffffffff81622128>] invalid_op+0x18/0x20
[  406.208987]  [<ffffffff81155758>] ? try_to_discard_one+0x1f8/0x210
[  406.208996]  [<ffffffff81155748>] ? try_to_discard_one+0x1e8/0x210
[  406.209485]  [<ffffffff81155b32>] discard_vpage+0x3c2/0x410
[  406.209497]  [<ffffffff81150881>] ? page_referenced+0x241/0x2c0
[  406.209507]  [<ffffffff8112e627>] shrink_page_list+0x397/0x950
[  406.209532]  [<ffffffff8112f12f>] shrink_inactive_list+0x14f/0x400
[  406.209542]  [<ffffffff8112f959>] shrink_lruvec+0x229/0x4e0
[  406.209551]  [<ffffffff8107e597>] ? wake_up_process+0x27/0x50
[  406.209560]  [<ffffffff8112fc76>] shrink_zone+0x66/0x1a0
[  406.209569]  [<ffffffff81130130>] do_try_to_free_pages+0x110/0x5a0
[  406.209577]  [<ffffffff8113074f>] try_to_free_mem_cgroup_pages+0xbf/0x140
[  406.209586]  [<ffffffff81179f6e>] mem_cgroup_reclaim+0x4e/0xe0
[  406.209595]  [<ffffffff8117a4ef>] __mem_cgroup_try_charge+0x4ef/0xbb0
[  406.209605]  [<ffffffff8117b29d>] mem_cgroup_charge_common+0x6d/0xd0
[  406.209618]  [<ffffffff8117cbeb>] mem_cgroup_newpage_charge+0x3b/0x50
[  406.209629]  [<ffffffff81142170>] do_wp_page+0x150/0x720
[  406.209640]  [<ffffffff811448ed>] handle_pte_fault+0x98d/0xae0
[  406.209652]  [<ffffffff811452c4>] handle_mm_fault+0x264/0x5e0
[  406.209664]  [<ffffffff8161c5b1>] __do_page_fault+0x171/0x4e0
[  406.209758]  [<ffffffff8161c92e>] ? do_page_fault+0xe/0x10
[  406.209771]  [<ffffffff81619172>] ? page_fault+0x22/0x30
[  406.209781]  [<ffffffff8161c92e>] do_page_fault+0xe/0x10
[  406.209791]  [<ffffffff81619172>] page_fault+0x22/0x30

I can send you the full dmesg/config if you care about it. It took me 
3-4 attempts of running the code before I hit this bug. It is reproducible.

Thanks!
Dhaval

--------------010507050700080703030301
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="volatile-test.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="volatile-test.c"


#define _GNU_SOURCE
#include <stdio.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/syscall.h>

#define SYS_vrange 314

#define VRANGE_VOLATILE	0	/* unpin all pages so VM can discard them */
#define VRANGE_NOVOLATILE	1	/* pin all pages so VM can't discard them */

#define VRANGE_MODE_SHARED 0x1	/* discard all pages of the range */



#define VRANGE_MODE 0x1

static int vrange(unsigned long start, size_t length, int mode, int *purged)
{
	return syscall(SYS_vrange, start, length, mode, purged);
}


static int mvolatile(void *addr, size_t length)
{
	return vrange((long)addr, length, VRANGE_VOLATILE, 0);
}


static int mnovolatile(void *addr, size_t length, int* purged)
{
	return vrange((long)addr, length, VRANGE_NOVOLATILE, purged);
}


char* vaddr;
int is_anon = 0;
#define PAGE_SIZE (4*1024)
#define CHUNK (4*1024*4)
#define CHUNKNUM 26
#define FULLSIZE (CHUNK*CHUNKNUM + 2*PAGE_SIZE)

void generate_pressure(megs)
{
	pid_t child;
	int one_meg = 1024*1024;
	char *addr;
	int i, status;

	child = fork();


	if (!child) {
		if (is_anon) {
			/* make sure we write to all the vrange pages
			 *  in order to break the copy-on-write
	 		 */
			for(i=0; i < CHUNKNUM; i++)
				memset(vaddr + (i*CHUNK), '0', CHUNK);
		}

		for (i=0; i < megs; i++) {
			addr = malloc(one_meg);
			bzero(addr, one_meg);		
		}
		exit(0);
	}

	waitpid(child, &status, 0);
	return;
}

int main(int argc, char *argv[])
{
	int i, purged;
	char* file;
	int fd;
	int is_file = 0;
	if (argc > 1) {
		file = argv[1];
		fd = open(file, O_RDWR);
		vaddr = mmap(0, FULLSIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
		is_file = 1;
	} else {
		is_anon = 1;
		vaddr = malloc(FULLSIZE);
	}

	purged = 0;
	vaddr += PAGE_SIZE-1;
	vaddr -= (long)vaddr % PAGE_SIZE;

	for(i=0; i < CHUNKNUM; i++)
		memset(vaddr + (i*CHUNK), 'A'+i, CHUNK);


	for(i=0; i < CHUNKNUM; ) {
		mvolatile(vaddr + (i*CHUNK), CHUNK);
		i+=2;
	}

//	for(i=0; i < CHUNKNUM; i++)
//		printf("%c\n", vaddr[i*CHUNK]);

	generate_pressure(3);

//	for(i=0; i < CHUNKNUM; i++)
//		printf("%c\n", vaddr[i*CHUNK]);

	for(i=0; i < CHUNKNUM; ) {
		int ret;
		ret = mnovolatile(vaddr + (i*CHUNK), CHUNK, &purged);
		i+=2;
	}

	if (purged)
		printf("Data purged!\n");
	for(i=0; i < CHUNKNUM; i++)
		printf("%c\n", vaddr[i*CHUNK]);
	


	return 0;
}


--------------010507050700080703030301--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
