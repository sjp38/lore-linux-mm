Date: Sat, 15 Dec 2007 01:09:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-ID: <20071215010940.GB28613@csn.ul.ie>
References: <476188C4.9030802@rtr.ca> <20071213193937.GG10104@kernel.dk> <47618B0B.8020203@rtr.ca> <20071213195350.GH10104@kernel.dk> <20071213200219.GI10104@kernel.dk> <476190BE.9010405@rtr.ca> <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071213142935.47ff19d9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, jens.axboe@oracle.com, liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/12/07 14:29), Andrew Morton didst pronounce:
> > The simple way seems to be to malloc a large area, touch every page and
> > then look at the physical pages assigned ... they now mostly seem to be
> > descending in physical address.
> > 
> 
> OIC.  -mm's /proc/pid/pagemap can be used to get the pfn's...
> 

I tried using pagemap to verify the patch but it triggered BUG_ON
checks. Perhaps I am using the interface wrong but I would still not
expect it to break in this fashion. I tried 2.6.24-rc4-mm1, 2.6.24-rc5-mm1,
2.6.24-rc5 with just the maps4 patches applied and 2.6.23 with maps4 patches
applied. Each time I get errors like this;

[   90.108315] BUG: sleeping function called from invalid context at include/asm/uaccess_32.h:457
[   90.211227] in_atomic():1, irqs_disabled():0
[   90.262251] no locks held by showcontiguous/2814.
[   90.318475] Pid: 2814, comm: showcontiguous Not tainted 2.6.24-rc5 #1
[   90.395344]  [<c010522a>] show_trace_log_lvl+0x1a/0x30
[   90.456948]  [<c0105bb2>] show_trace+0x12/0x20
[   90.510173]  [<c0105eee>] dump_stack+0x6e/0x80
[   90.563409]  [<c01205b3>] __might_sleep+0xc3/0xe0
[   90.619765]  [<c02264fd>] copy_to_user+0x3d/0x60
[   90.675153]  [<c01b3e9c>] add_to_pagemap+0x5c/0x80
[   90.732513]  [<c01b43e8>] pagemap_pte_range+0x68/0xb0
[   90.793010]  [<c0175ed2>] walk_page_range+0x112/0x210
[   90.853482]  [<c01b47c6>] pagemap_read+0x176/0x220
[   90.910863]  [<c0182dc4>] vfs_read+0x94/0x150
[   90.963058]  [<c01832fd>] sys_read+0x3d/0x70
[   91.014219]  [<c0104262>] syscall_call+0x7/0xb
[   91.067433]  =======================
[   91.110137] BUG: scheduling while atomic: showcontiguous/2814/0x00000001
[   91.190169] no locks held by showcontiguous/2814.
[   91.246293] Pid: 2814, comm: showcontiguous Not tainted 2.6.24-rc5 #1
[   91.323145]  [<c010522a>] show_trace_log_lvl+0x1a/0x30
[   91.384633]  [<c0105bb2>] show_trace+0x12/0x20
[   91.437878]  [<c0105eee>] dump_stack+0x6e/0x80
[   91.491116]  [<c0123816>] __schedule_bug+0x66/0x70
[   91.548467]  [<c033ba96>] schedule+0x556/0x7b0
[   91.601698]  [<c01042e6>] work_resched+0x5/0x21
[   91.655977]  =======================
[   91.704927] showcontiguous[2814]: segfault at b7eaa900 eip b7eaa900 esp bfa02e8c error 4
[   91.801633] BUG: scheduling while atomic: showcontiguous/2814/0x00000001
[   91.881634] no locks held by showcontiguous/2814.
[   91.937779] Pid: 2814, comm: showcontiguous Not tainted 2.6.24-rc5 #1
[   92.014606]  [<c010522a>] show_trace_log_lvl+0x1a/0x30
[   92.076123]  [<c0105bb2>] show_trace+0x12/0x20
[   92.129354]  [<c0105eee>] dump_stack+0x6e/0x80
[   92.182567]  [<c0123816>] __schedule_bug+0x66/0x70
[   92.239959]  [<c033ba96>] schedule+0x556/0x7b0
[   92.293187]  [<c01042e6>] work_resched+0x5/0x21
[   92.347452]  =======================
[   92.392697] note: showcontiguous[2814] exited with preempt_count 1
[   92.468611] BUG: scheduling while atomic: showcontiguous/2814/0x10000001
[   92.548588] no locks held by showcontiguous/2814.
[   92.604732] Pid: 2814, comm: showcontiguous Not tainted 2.6.24-rc5 #1
[   92.681665]  [<c010522a>] show_trace_log_lvl+0x1a/0x30
[   92.743180]  [<c0105bb2>] show_trace+0x12/0x20
[   92.796409]  [<c0105eee>] dump_stack+0x6e/0x80
[   92.849621]  [<c0123816>] __schedule_bug+0x66/0x70
[   92.907014]  [<c033ba96>] schedule+0x556/0x7b0
[   92.960349]  [<c0123847>] __cond_resched+0x27/0x40
[   93.017804]  [<c033be3a>] cond_resched+0x2a/0x40
[   93.073122]  [<c016e22c>] unmap_vmas+0x4ec/0x540
[   93.128418]  [<c017132f>] exit_mmap+0x6f/0xf0
[   93.180611]  [<c01254d1>] mmput+0x31/0xb0
[   93.228665]  [<c01295fd>] exit_mm+0x8d/0xf0
[   93.278788]  [<c012ac8f>] do_exit+0x15f/0x7e0
[   93.330965]  [<c012b339>] do_group_exit+0x29/0x70
[   93.387321]  [<c0133e07>] get_signal_to_deliver+0x2b7/0x490
[   93.454013]  [<c010373d>] do_notify_resume+0x7d/0x760
[   93.514476]  [<c0104315>] work_notifysig+0x13/0x1a
[   93.571869]  =======================

Just using cp to read the file is enough to cause problems but I included
a very basic program below that produces the BUG_ON checks. Is this a known
issue or am I using the interface incorrectly?

#include <stdio.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/types.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAPSIZE (4*1048576)
#define PM_ENTRY_BYTES sizeof(__u64)

int main(int argc, char **argv)
{
	int pagemap_fd;
	unsigned long *anonmapping;
	__u64 pagemap_entry = 0ULL;

	unsigned long vpfn, ppfn;
	size_t mmap_offset;
	int pagesize = getpagesize();

	/* Open the pagemap interface */
	pagemap_fd = open("/proc/self/pagemap", O_RDONLY);
	if (pagemap_fd == -1) {
		perror("fopen");
		exit(EXIT_FAILURE);
	}

	/* Create an anonymous mapping */
	anonmapping = mmap(NULL, MAPSIZE,
			PROT_READ|PROT_WRITE,
			MAP_PRIVATE|MAP_ANONYMOUS|MAP_POPULATE,
			-1, 0);
	if (anonmapping == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}

	/* Work out the VPN the mapping is at and seek to it in pagemap */
	vpfn = ((unsigned long)anonmapping) / pagesize;
	mmap_offset = lseek(pagemap_fd, vpfn * PM_ENTRY_BYTES, SEEK_SET);
	if (mmap_offset == -1) {
		perror("fseek");
		exit(EXIT_FAILURE);
	}

	/* Read the PFN of each page in the mapping */
	for (mmap_offset = 0; mmap_offset < MAPSIZE; mmap_offset += pagesize) {
		vpfn = ((unsigned long)anonmapping + mmap_offset) / pagesize;

		if (read(pagemap_fd, &pagemap_entry, PM_ENTRY_BYTES) == 0) {
			perror("fread");
			exit(EXIT_FAILURE);
		}

		ppfn = (unsigned long)pagemap_entry;
		printf("vpfn = %8lu ppfn = %8lu\n", vpfn, ppfn);
	}

	close(pagemap_fd);
	munmap(anonmapping, MAPSIZE);
	exit(EXIT_SUCCESS);
}

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
