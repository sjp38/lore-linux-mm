Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 3880E6B0036
	for <linux-mm@kvack.org>; Thu, 23 May 2013 10:35:36 -0400 (EDT)
Date: Thu, 23 May 2013 10:35:28 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 0/9] kdump, vmcore: support mmap() on /proc/vmcore
Message-ID: <20130523143528.GH2779@redhat.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, May 23, 2013 at 02:24:55PM +0900, HATAYAMA Daisuke wrote:
> Currently, read to /proc/vmcore is done by read_oldmem() that uses
> ioremap/iounmap per a single page. For example, if memory is 1GB,
> ioremap/iounmap is called (1GB / 4KB)-times, that is, 262144
> times. This causes big performance degradation due to repeated page
> table changes, TLB flush and build-up of VM related objects.
> 
> To address the issue, this patch implements mmap() on /proc/vmcore to
> improve read performance under sufficiently large mapping size.
> 
> In particular, the current main user of this mmap() is makedumpfile,
> which not only reads memory from /proc/vmcore but also does other
> processing like filtering, compression and I/O work.
> 

Thanks hatayam,

Thanks for the patches. This series looks good to me. I think we just
need an ack from mm folks on patch 5 which introduces
remap_vmalloc_range_partial().

Thanks
Vivek

> Benchmark
> =========
> 
> You can see two benchmarks on terabyte memory system. Both show about
> 40 seconds on 2TB system. This is almost equal to performance by
> experimental kernel-side memory filtering.
> 
> - makedumpfile mmap() benchmark, by Jingbai Ma
>   https://lkml.org/lkml/2013/3/27/19
> 
> - makedumpfile: benchmark on mmap() with /proc/vmcore on 2TB memory system
>   https://lkml.org/lkml/2013/3/26/914
> 
> ChangeLog
> =========
> 
> v7 => v8)
> 
> - Unify set_vmcore_list_offsets_elf{64,32} as set_vmcore_list_offsets.
>   [Patch 2/9]
> - Introduce update_note_header_size_elf{64,32} and cleanup
>   get_note_number_and_size_elf{64,32} and copy_notes_elf{64,32}.
>   [Patch 6/9]
> - Create new patch that sets VM_USERMAP flag in VM object for ELF note
>   segment buffer.
>   [Patch 7/9]
> - Unify get_vmcore_size_elf{64,32} as get_vmcore_size.
>   [Patch 8/9]
> 
> v6 => v7)
> 
> - Rebase 3.10-rc2.
> - Move roundup operation to note segment from patch 2/8 to patch 6/8.
> - Rewrite get_note_number_and_size_elf{64,32} and
>   copy_notes_elf{64,32} in patch 6/8.
> 
> v5 => v6)
> 
> - Change patch order: clenaup patch => PT_LOAD change patch =>
>   vmalloc-related patch => mmap patch.
> - Some cleanups: improve symbol names simply, add helper functoins for
>   processing ELF note segment and add comments for the helper
>   functions.
> - Fix patch description of patch 7/8.
> 
> v4 => v5)
> 
> - Rebase 3.10-rc1.
> - Introduce remap_vmalloc_range_partial() in order to remap vmalloc
>   memory in a part of vma area.
> - Allocate buffer for ELF note segment at 2nd kernel by vmalloc(). Use
>   remap_vmalloc_range_partial() to remap the memory to userspace.
> 
> v3 => v4)
> 
> - Rebase 3.9-rc7.
> - Drop clean-up patches orthogonal to the main topic of this patch set.
> - Copy ELF note segments in the 2nd kernel just as in v1. Allocate
>   vmcore objects per pages. => See [PATCH 5/8]
> - Map memory referenced by PT_LOAD entry directly even if the start or
>   end of the region doesn't fit inside page boundary, no longer copy
>   them as the previous v3. Then, holes, outside OS memory, are visible
>   from /proc/vmcore. => See [PATCH 7/8]
> 
> v2 => v3)
> 
> - Rebase 3.9-rc3.
> - Copy program headers separately from e_phoff in ELF note segment
>   buffer. Now there's no risk to allocate huge memory if program
>   header table positions after memory segment.
> - Add cleanup patch that removes unnecessary variable.
> - Fix wrongly using the variable that is buffer size configurable at
>   runtime. Instead, use the variable that has original buffer size.
> 
> v1 => v2)
> 
> - Clean up the existing codes: use e_phoff, and remove the assumption
>   on PT_NOTE entries.
> - Fix potential bug that ELF header size is not included in exported
>   vmcoreinfo size.
> - Divide patch modifying read_vmcore() into two: clean-up and primary
>   code change.
> - Put ELF note segments in page-size boundary on the 1st kernel
>   instead of copying them into the buffer on the 2nd kernel.
> 
> Test
> ====
> 
> This patch set is composed based on v3.10-rc2, tested on x86_64,
> x86_32 both with 1GB and with 5GB (over 4GB) memory configurations.
> 
> ---
> 
> HATAYAMA Daisuke (9):
>       vmcore: support mmap() on /proc/vmcore
>       vmcore: calculate vmcore file size from buffer size and total size of vmcore objects
>       vmcore: Allow user process to remap ELF note segment buffer
>       vmcore: allocate ELF note segment in the 2nd kernel vmalloc memory
>       vmalloc: introduce remap_vmalloc_range_partial
>       vmalloc: make find_vm_area check in range
>       vmcore: treat memory chunks referenced by PT_LOAD program header entries in page-size boundary in vmcore_list
>       vmcore: allocate buffer for ELF headers on page-size alignment
>       vmcore: clean up read_vmcore()
> 
> 
>  fs/proc/vmcore.c        |  657 +++++++++++++++++++++++++++++++++--------------
>  include/linux/vmalloc.h |    4 
>  mm/vmalloc.c            |   65 +++--
>  3 files changed, 515 insertions(+), 211 deletions(-)
> 
> -- 
> 
> Thanks.
> HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
