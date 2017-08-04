Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E895828040C
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 19:09:59 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v49so14834856qtc.2
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 16:09:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u123si2504100qkh.59.2017.08.04.16.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 16:09:58 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
References: <20170804190730.17858-1-riel@redhat.com>
 <20170804190730.17858-3-riel@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <54eba2da-94ff-bd8a-3405-47577437550a@oracle.com>
Date: Fri, 4 Aug 2017 16:09:38 -0700
MIME-Version: 1.0
In-Reply-To: <20170804190730.17858-3-riel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

On 08/04/2017 12:07 PM, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> empty in the child process after fork. This differs from MADV_DONTFORK
> in one important way.
> 
> If a child process accesses memory that was MADV_WIPEONFORK, it
> will get zeroes. The address ranges are still valid, they are just empty.
> 
> If a child process accesses memory that was MADV_DONTFORK, it will
> get a segmentation fault, since those address ranges are no longer
> valid in the child after fork.
> 
> Since MADV_DONTFORK also seems to be used to allow very large
> programs to fork in systems with strict memory overcommit restrictions,
> changing the semantics of MADV_DONTFORK might break existing programs.
> 
> The use case is libraries that store or cache information, and
> want to know that they need to regenerate it in the child process
> after fork.
> 
> Examples of this would be:
> - systemd/pulseaudio API checks (fail after fork)
>   (replacing a getpid check, which is too slow without a PID cache)
> - PKCS#11 API reinitialization check (mandated by specification)
> - glibc's upcoming PRNG (reseed after fork)
> - OpenSSL PRNG (reseed after fork)
> 
> The security benefits of a forking server having a re-inialized
> PRNG in every child process are pretty obvious. However, due to
> libraries having all kinds of internal state, and programs getting
> compiled with many different versions of each library, it is
> unreasonable to expect calling programs to re-initialize everything
> manually after fork.
> 
> A further complication is the proliferation of clone flags,
> programs bypassing glibc's functions to call clone directly,
> and programs calling unshare, causing the glibc pthread_atfork
> hook to not get called.
> 
> It would be better to have the kernel take care of this automatically.
> 
> This is similar to the OpenBSD minherit syscall with MAP_INHERIT_ZERO:
> 
>     https://man.openbsd.org/minherit.2
> 
> Reported-by: Florian Weimer <fweimer@redhat.com>
> Reported-by: Colm MacCA!rtaigh <colm@allcosts.net>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  arch/alpha/include/uapi/asm/mman.h     |  3 +++
>  arch/mips/include/uapi/asm/mman.h      |  3 +++
>  arch/parisc/include/uapi/asm/mman.h    |  3 +++
>  arch/xtensa/include/uapi/asm/mman.h    |  3 +++
>  fs/proc/task_mmu.c                     |  1 +
>  include/linux/mm.h                     |  2 +-
>  include/uapi/asm-generic/mman-common.h |  3 +++
>  kernel/fork.c                          |  8 ++++++--
>  mm/madvise.c                           |  8 ++++++++
>  mm/memory.c                            | 10 ++++++++++
>  10 files changed, 41 insertions(+), 3 deletions(-)
> 

This didn't seem 'quite right' to me for shared mappings and/or file
backed mappings.  I wasn't exactly sure what it 'should' do in such
cases.  So, I tried it with a mapping created as follows:

addr = mmap(ADDR, page_size,
                        PROT_READ | PROT_WRITE,
                        MAP_ANONYMOUS|MAP_SHARED, -1, 0);

When setting MADV_WIPEONFORK on the vma/mapping, I got the following
at task exit time:

[  694.558290] ------------[ cut here ]------------
[  694.558978] kernel BUG at mm/filemap.c:212!
[  694.559476] invalid opcode: 0000 [#1] SMP
[  694.560023] Modules linked in: ip6t_REJECT nf_reject_ipv6 ip6t_rpfilter xt_conntrack ebtable_broute bridge stp llc ebtable_nat ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_raw ip6table_mangle ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_raw iptable_mangle 9p iptable_security ebtable_filter ebtables ip6table_filter ip6_tables snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep snd_hda_core snd_seq ppdev snd_seq_device joydev crct10dif_pclmul crc32_pclmul crc32c_intel snd_pcm ghash_clmulni_intel 9pnet_virtio virtio_balloon snd_timer 9pnet parport_pc snd parport i2c_piix4 soundcore nfsd auth_rpcgss nfs_acl lockd grace sunrpc virtio_net virtio_blk virtio_console 8139too qxl drm_kms_helper ttm drm serio_raw 8139cp
[  694.571554]  mii virtio_pci ata_generic virtio_ring virtio pata_acpi
[  694.572608] CPU: 3 PID: 1200 Comm: test_wipe2 Not tainted 4.13.0-rc3+ #8
[  694.573778] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
[  694.574917] task: ffff880137178040 task.stack: ffffc900019d4000
[  694.575650] RIP: 0010:__delete_from_page_cache+0x344/0x410
[  694.576409] RSP: 0018:ffffc900019d7a88 EFLAGS: 00010082
[  694.577238] RAX: 0000000000000021 RBX: ffffea00047d0e00 RCX: 0000000000000006
[  694.578537] RDX: 0000000000000000 RSI: 0000000000000096 RDI: ffff88023fd0db90
[  694.579774] RBP: ffffc900019d7ad8 R08: 00000000000882b6 R09: 000000000000028a
[  694.580754] R10: ffffc900019d7da8 R11: ffffffff8211184d R12: ffffea00047d0e00
[  694.582040] R13: 0000000000000000 R14: 0000000000000202 R15: ffff8801384439e8
[  694.583236] FS:  0000000000000000(0000) GS:ffff88023fd00000(0000) knlGS:0000000000000000
[  694.584607] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  694.585409] CR2: 00007ff77a8da618 CR3: 0000000001e09000 CR4: 00000000001406e0
[  694.586547] Call Trace:
[  694.586996]  delete_from_page_cache+0x54/0x110
[  694.587481]  truncate_inode_page+0xab/0x120
[  694.588110]  shmem_undo_range+0x498/0xa50
[  694.588813]  ? save_stack_trace+0x1b/0x20
[  694.589529]  ? set_track+0x70/0x140
[  694.590150]  ? init_object+0x69/0xa0
[  694.590722]  ? __inode_wait_for_writeback+0x73/0xe0
[  694.591525]  shmem_truncate_range+0x16/0x40
[  694.592268]  shmem_evict_inode+0xb1/0x190
[  694.592735]  evict+0xbb/0x1c0
[  694.593147]  iput+0x1c0/0x210
[  694.593497]  dentry_unlink_inode+0xb4/0x150
[  694.593982]  __dentry_kill+0xc1/0x150
[  694.594400]  dput+0x1c8/0x1e0
[  694.594745]  __fput+0x172/0x1e0
[  694.595103]  ____fput+0xe/0x10
[  694.595463]  task_work_run+0x80/0xa0
[  694.595886]  do_exit+0x2d6/0xb50
[  694.596323]  ? __do_page_fault+0x288/0x4a0
[  694.596818]  do_group_exit+0x47/0xb0
[  694.597249]  SyS_exit_group+0x14/0x20
[  694.597682]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[  694.598198] RIP: 0033:0x7ff77a5e78c8
[  694.598612] RSP: 002b:00007ffc5aece318 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
[  694.599804] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007ff77a5e78c8
[  694.600609] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
[  694.601424] RBP: 00007ff77a8da618 R08: 00000000000000e7 R09: ffffffffffffff98
[  694.602224] R10: 0000000000000003 R11: 0000000000000246 R12: 0000000000000001
[  694.603151] R13: 00007ff77a8dbc60 R14: 0000000000000000 R15: 0000000000000000
[  694.603984] Code: 60 f3 c5 81 e8 2e 7e 03 00 0f 0b 48 c7 c6 60 f3 c5 81 4c 89 e7 e8 1d 7e 03 00 0f 0b 48 c7 c6 00 f4 c5 81 4c 89 e7 e8 0c 7e 03 00 <0f> 0b 48 c7 c6 38 f3 c5 81 4c 89 e7 e8 fb 7d 03 00 0f 0b 48 c7 
[  694.606500] RIP: __delete_from_page_cache+0x344/0x410 RSP: ffffc900019d7a88
[  694.607426] ---[ end trace 55e6b04ae95d8ce3 ]---

BTW, this was on 4.13.0-rc3 + your patches.  Simple test program is below.

-- 
Mike Kravetz


#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <errno.h>

#define MADV_WIPEONFORK 18
#define ADDR (void *)(0x0UL)

int main(int argc, char ** argv)
{
	unsigned long page_size;
	int ret;
	void *addr;
	char foo;

	page_size = sysconf(_SC_PAGE_SIZE);

	addr = mmap(ADDR, page_size,
			PROT_READ | PROT_WRITE,
			MAP_ANONYMOUS|MAP_SHARED, -1, 0);
	if (addr == MAP_FAILED) {
		perror("mmap");
		exit (1);
	}

	printf("Parent writing 'a' to page\n");
	*((char *)addr) = 'a'; 

	ret = madvise(addr, page_size, MADV_WIPEONFORK);
	if (ret) {
		perror("madvise");
		exit (1);
	}

	if (fork()) {
		/* In parent */
		sleep(1);
	} else {
		/* In child */
		foo = *((char *)addr);
		printf("child read '%c' from page\n", foo);
	}

	return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
