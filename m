Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 17C886B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:35:27 -0500 (EST)
Message-ID: <50E5CF6C.6080305@mozilla.com>
Date: Thu, 03 Jan 2013 10:35:24 -0800
From: Taras Glek <tglek@mozilla.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/8] Introduce new system call mvolatile
References: <1357187286-18759-1-git-send-email-minchan@kernel.org> <1357187286-18759-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 1/2/2013 8:27 PM, Minchan Kim wrote:
> This patch adds new system call m[no]volatile.
> If someone asks is_volatile system call, it could be added, too.
>
> The reason why I introduced new system call instead of madvise is
> m[no]volatile vma handling is totally different with madvise's vma
> handling.
>
> 1) The m[no]volatile should be successful although the range includes
>     unmapped or non-volatile range. It just skips such range
>     without stopping with returning error although it encounters
>     invalid range. It makes user convenient without calling several
>     system call of small range - Suggested by John Stultz
>
> 2) The purged state of volatile range should be propagated out to user
>     although the range is merged with adjacent non-volatile range when
>     user calls mnovolatile.
>
> 3) mvolatile's interface could be changed with madvise
>     in future discussion.  For example, I feel needs
>     movlatile(start, len, mode).
>     'mode' means FULL_VOLATILE or PARTIAL_VOLATILE.
>     FULL volatile means that if VM decide to reclaim the range, it would
>     reclaim all of pages in the range but in case of PARTIAL_VOLATILE,
>     VM could reclaim just a few number of pages in the range.
>     In case of tmpfs-volatile, user may regenerate all images data once
>     one of page in the range is discarded so there is pointless that
>     VM discard a page in the range when memory pressure is severe.
>     In case of anon-volatile, too excess discarding cause too many minor
>     fault for the allocator so it would be better to discard part of
>     the range.
I don't understand point 3).
Are you saying that using mvolatile in conjuction with madvise could 
allow mvolatile behavior to be tweaked in the future? Or are you 
suggesting adding an extra parameter in the future(what would that have 
to do with madvise)?

4) Having a new system call makes it easier for userspace apps to detect 
kernels without this functionality.

I really like the proposed interface. I like the suggestion of having 
explicit FULL|PARTIAL_VOLATILE. Why not include PARTIAL_VOLATILE as a 
required 3rd param in first version with expectation that FULL_VOLATILE 
will be added later(and returning some not-supported error in meantime)?
>
> 3) The mvolatile system call's return value is quite different with
>     madvise. Look at below semantic explanation.
>
> So I want to separate mvolatile from madvise.
>
> mvolatile(start, len)'s semantics
>
> 1) It makes range(start, len) as volatile although the range includes
> unmapped area, speacial mapping and mlocked area which are just skipped.
>
> Return -EINVAL if range doesn't include a right vma at all.
> Return -ENOMEM with interrupting range opeartion if memory is not
> enough to merge/split vmas. In this case, some ranges would be
> volatile and others not so user may recall mvolatile after he
> cancel all range by mnovolatile.
> Return 0 if range consists of only proper vmas.
> Return 1 if part of range includes hole/huge/ksm/mlock/special area.
>
> 2) If user calls mvolatile to the range which was already volatile VMA and
> even purged state, VOLATILE attributes still remains but purged state
> is reset. I expect some user want to split volatile vma into smaller
> ranges. Although he can do it for mnovlatile(whole range) and serveral calling
> with movlatile(smaller range), this function can avoid mnovolatile if he
> doesn't care purged state. I'm not sure we really need this function so
> I hope listen opinions. Unfortunately, current implemenation doesn't split
> volatile VMA with new range in this case. I forgot implementing it
> in this version but decide to send it to listen opinions because
> implementing is rather trivial if we decided.
>
> mnovolatile(start, len)'s semantics is following as.
>
> 1) It makes range(start, len) as non-volatile although the range
> includes unmapped area, speacial mapping and non-volatile range
> which are just skipped.
>
> 2) If the range is purged, it will return 1 regardless of including
> invalid range.
If I understand this correctly:
mvolatile(0, 10);
//then range [9,10] is purged by kernel
mnovolatile(0,4) will fail?
that seems counterintuitive.

One of the uses for mnovolatile is to atomicly lock the pages(vs a racy 
proposed is_volatile) syscall. Above situation would make it less effective.


>
> 3) It returns -ENOMEM if system doesn't have enough memory for vma operation.
>
> 4) It returns -EINVAL if range doesn't include a right vma at all.
>
> 5) If user try to access purged range without mnovoatile call, it encounters
> SIGBUS which would show up next patch.
>
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Arun Sharma <asharma@fb.com>
> Cc: sanjay@google.com
> Cc: Paul Turner <pjt@google.com>
> CC: David Rientjes <rientjes@google.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   arch/x86/syscalls/syscall_64.tbl |    2 +
>   fs/exec.c                        |    4 +-
>   include/linux/mm.h               |    6 +-
>   include/linux/mm_types.h         |    4 +
>   include/linux/mvolatile.h        |   30 ++++
>   include/linux/syscalls.h         |    2 +
>   mm/Kconfig                       |   11 ++
>   mm/Makefile                      |    2 +-
>   mm/madvise.c                     |    2 +-
>   mm/mempolicy.c                   |    2 +-
>   mm/mlock.c                       |    7 +-
>   mm/mmap.c                        |   62 ++++++--
>   mm/mprotect.c                    |    3 +-
>   mm/mremap.c                      |    2 +-
>   mm/mvolatile.c                   |  312 ++++++++++++++++++++++++++++++++++++++
>   mm/rmap.c                        |    2 +
>   16 files changed, 427 insertions(+), 26 deletions(-)
>   create mode 100644 include/linux/mvolatile.h
>   create mode 100644 mm/mvolatile.c
>
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index a582bfe..568d488 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -319,6 +319,8 @@
>   310	64	process_vm_readv	sys_process_vm_readv
>   311	64	process_vm_writev	sys_process_vm_writev
>   312	common	kcmp			sys_kcmp
> +313	common	mvolatile		sys_mvolatile
> +314	common	mnovolatile		sys_mnovolatile
>   
>   #
>   # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/fs/exec.c b/fs/exec.c
> index 0039055..da677d1 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -594,7 +594,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
>   	/*
>   	 * cover the whole range: [new_start, old_end)
>   	 */
> -	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
> +	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL, NULL))
>   		return -ENOMEM;
>   
>   	/*
> @@ -628,7 +628,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
>   	/*
>   	 * Shrink the vma to just the new range.  Always succeeds.
>   	 */
> -	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL, NULL);
>   
>   	return 0;
>   }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bcaab4e..4bb59f3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -87,6 +87,7 @@ extern unsigned int kobjsize(const void *objp);
>   #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
>   #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
>   
> +#define VM_VOLATILE	0x00001000	/* Pages could be discarede without swapout */
>   #define VM_LOCKED	0x00002000
>   #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
>   
> @@ -1411,11 +1412,12 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
>   /* mmap.c */
>   extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
>   extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
> -	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
> +	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
> +	bool *purged);
>   extern struct vm_area_struct *vma_merge(struct mm_struct *,
>   	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
>   	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
> -	struct mempolicy *);
> +	struct mempolicy *, bool *purged);
>   extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
>   extern int split_vma(struct mm_struct *,
>   	struct vm_area_struct *, unsigned long addr, int new_below);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 31f8a3a..1eaf458 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -275,6 +275,10 @@ struct vm_area_struct {
>   #ifdef CONFIG_NUMA
>   	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>   #endif
> +#ifdef CONFIG_VOLATILE_PAGE
> +	/* True if more than a page in this vma is reclaimed. */
> +	bool purged;	/* Serialized by mmap_sem and anon_vma's mutex */
> +#endif
>   };
>   
>   struct core_thread {
> diff --git a/include/linux/mvolatile.h b/include/linux/mvolatile.h
> new file mode 100644
> index 0000000..cfb12b4
> --- /dev/null
> +++ b/include/linux/mvolatile.h
> @@ -0,0 +1,30 @@
> +#ifndef __LINUX_MVOLATILE_H
> +#define __LINUX_MVOLATILE_H
> +
> +#include <linux/syscalls.h>
> +
> +#ifdef CONFIG_VOLATILE_PAGE
> +static inline bool vma_purged(struct vm_area_struct *vma)
> +{
> +	return vma->purged;
> +}
> +
> +static inline void vma_purge_copy(struct vm_area_struct *dst,
> +					struct vm_area_struct *src)
> +{
> +	dst->purged = src->purged;
> +}
> +#else
> +static inline bool vma_purged(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
> +
> +static inline void vma_purge_copy(struct vm_area_struct *dst,
> +					struct vm_area_struct *src)
> +{
> +
> +}
> +#endif
> +#endif
> +
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 727f0cd..a8ded1c 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -470,6 +470,8 @@ asmlinkage long sys_munlock(unsigned long start, size_t len);
>   asmlinkage long sys_mlockall(int flags);
>   asmlinkage long sys_munlockall(void);
>   asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
> +asmlinkage long sys_mvolatile(unsigned long start, size_t len);
> +asmlinkage long sys_mnovolatile(unsigned long start, size_t len);
>   asmlinkage long sys_mincore(unsigned long start, size_t len,
>   				unsigned char __user * vec);
>   
> diff --git a/mm/Kconfig b/mm/Kconfig
> index a3f8ddd..30b24ba 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -355,6 +355,17 @@ choice
>   	  benefit.
>   endchoice
>   
> +config VOLATILE_PAGE
> +	bool "Volatile Page Support"
> +	depends on MMU
> +	help
> +	  Enabling this option adds the system calls mvolatile and mnovolatile
> +	  which are for giving user's address space range to kernel so VM
> +	  can discard pages of the range anytime instead swapout. This feature
> +	  can enhance performance to certain application(ex, memory allocator,
> +	  web browser's tmpfs pages) by reduce the number of minor fault and
> +          swap out.
> +
>   config CROSS_MEMORY_ATTACH
>   	bool "Cross Memory Support"
>   	depends on MMU
> diff --git a/mm/Makefile b/mm/Makefile
> index 6b025f8..1efb735 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -5,7 +5,7 @@
>   mmu-y			:= nommu.o
>   mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
>   			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> -			   vmalloc.o pagewalk.o pgtable-generic.o
> +			   mvolatile.o vmalloc.o pagewalk.o pgtable-generic.o
>   
>   ifdef CONFIG_CROSS_MEMORY_ATTACH
>   mmu-$(CONFIG_MMU)	+= process_vm_access.o
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 03dfa5c..6ffad21 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -99,7 +99,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
>   
>   	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>   	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
> -				vma->vm_file, pgoff, vma_policy(vma));
> +				vma->vm_file, pgoff, vma_policy(vma), NULL);
>   	if (*prev) {
>   		vma = *prev;
>   		goto success;
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4ea600d..9b1aa2d 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -675,7 +675,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>   			((vmstart - vma->vm_start) >> PAGE_SHIFT);
>   		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
>   				  vma->anon_vma, vma->vm_file, pgoff,
> -				  new_pol);
> +				  new_pol, NULL);
>   		if (prev) {
>   			vma = prev;
>   			next = vma->vm_next;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index f0b9ce5..e03523a 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -316,13 +316,14 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
>   	int ret = 0;
>   	int lock = !!(newflags & VM_LOCKED);
>   
> -	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
> -	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
> +	if (newflags == vma->vm_flags || (vma->vm_flags &
> +		(VM_SPECIAL|VM_VOLATILE)) || is_vm_hugetlb_page(vma) ||
> +		vma == get_gate_vma(current->mm))
>   		goto out;	/* don't set VM_LOCKED,  don't count */
>   
>   	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>   	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
> -			  vma->vm_file, pgoff, vma_policy(vma));
> +			  vma->vm_file, pgoff, vma_policy(vma), NULL);
>   	if (*prev) {
>   		vma = *prev;
>   		goto success;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9a796c4..ba636c3 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -31,6 +31,7 @@
>   #include <linux/audit.h>
>   #include <linux/khugepaged.h>
>   #include <linux/uprobes.h>
> +#include <linux/mvolatile.h>
>   
>   #include <asm/uaccess.h>
>   #include <asm/cacheflush.h>
> @@ -516,7 +517,8 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
>    * before we drop the necessary locks.
>    */
>   int vma_adjust(struct vm_area_struct *vma, unsigned long start,
> -	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
> +	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
> +	bool *purged)
>   {
>   	struct mm_struct *mm = vma->vm_mm;
>   	struct vm_area_struct *next = vma->vm_next;
> @@ -527,10 +529,9 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>   	struct file *file = vma->vm_file;
>   	long adjust_next = 0;
>   	int remove_next = 0;
> +	struct vm_area_struct *exporter = NULL;
>   
>   	if (next && !insert) {
> -		struct vm_area_struct *exporter = NULL;
> -
>   		if (end >= next->vm_end) {
>   			/*
>   			 * vma expands, overlapping all the next, and
> @@ -621,6 +622,15 @@ again:			remove_next = 1 + (end > next->vm_end);
>   	if (adjust_next) {
>   		next->vm_start += adjust_next << PAGE_SHIFT;
>   		next->vm_pgoff += adjust_next;
> +		/*
> +		 * Look at mm/mvolatile.c for knowing terminology.
> +		 * V4. NNPPVV -> NNNPVV
> +		 */
> +		if (purged) {
> +			*purged = vma_purged(next);
> +			if (exporter == vma) /* V5. VVPPNN -> VVPNNN */
> +				*purged = vma_purged(vma);
> +		}
>   	}
>   
>   	if (root) {
> @@ -651,6 +661,13 @@ again:			remove_next = 1 + (end > next->vm_end);
>   		anon_vma_interval_tree_post_update_vma(vma);
>   		if (adjust_next)
>   			anon_vma_interval_tree_post_update_vma(next);
> +		/*
> +		 * Look at mm/mvolatile.c for knowing terminology.
> +		 * V7. VVPPVV -> VVNPVV
> +		 * V8. VVPPVV -> VVPNVV
> +		 */
> +		if (insert)
> +			vma_purge_copy(insert, vma);
>   		anon_vma_unlock(anon_vma);
>   	}
>   	if (mapping)
> @@ -670,6 +687,20 @@ again:			remove_next = 1 + (end > next->vm_end);
>   		}
>   		if (next->anon_vma)
>   			anon_vma_merge(vma, next);
> +
> +		/*
> +		 * next is detatched from anon vma chain so purged isn't
> +		 * raced any more.
> +		 * Look at mm/mvolatile.c for knowing terminology.
> +		 *
> +		 * V1. NNPPVV -> NNNNVV
> +		 * V2. VVPPNN -> VVNNNN
> +		 * V3. NNPPNN -> NNNNNN
> +		 */
> +		if (purged) {
> +			*purged |= vma_purged(vma); /* case V2 */
> +			*purged |= vma_purged(next); /* case V1,V3 */
> +		}
>   		mm->map_count--;
>   		mpol_put(vma_policy(next));
>   		kmem_cache_free(vm_area_cachep, next);
> @@ -798,7 +829,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>   			struct vm_area_struct *prev, unsigned long addr,
>   			unsigned long end, unsigned long vm_flags,
>   		     	struct anon_vma *anon_vma, struct file *file,
> -			pgoff_t pgoff, struct mempolicy *policy)
> +			pgoff_t pgoff, struct mempolicy *policy, bool *purged)
>   {
>   	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
>   	struct vm_area_struct *area, *next;
> @@ -808,7 +839,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>   	 * We later require that vma->vm_flags == vm_flags,
>   	 * so this tests vma->vm_flags & VM_SPECIAL, too.
>   	 */
> -	if (vm_flags & VM_SPECIAL)
> +	if (vm_flags & (VM_SPECIAL|VM_VOLATILE))
>   		return NULL;
>   
>   	if (prev)
> @@ -837,10 +868,10 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>   						      next->anon_vma, NULL)) {
>   							/* cases 1, 6 */
>   			err = vma_adjust(prev, prev->vm_start,
> -				next->vm_end, prev->vm_pgoff, NULL);
> +				next->vm_end, prev->vm_pgoff, NULL, purged);
>   		} else					/* cases 2, 5, 7 */
>   			err = vma_adjust(prev, prev->vm_start,
> -				end, prev->vm_pgoff, NULL);
> +				end, prev->vm_pgoff, NULL, purged);
>   		if (err)
>   			return NULL;
>   		khugepaged_enter_vma_merge(prev);
> @@ -856,10 +887,10 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>   					anon_vma, file, pgoff+pglen)) {
>   		if (prev && addr < prev->vm_end)	/* case 4 */
>   			err = vma_adjust(prev, prev->vm_start,
> -				addr, prev->vm_pgoff, NULL);
> +				addr, prev->vm_pgoff, NULL, purged);
>   		else					/* cases 3, 8 */
>   			err = vma_adjust(area, addr, next->vm_end,
> -				next->vm_pgoff - pglen, NULL);
> +				next->vm_pgoff - pglen, NULL, purged);
>   		if (err)
>   			return NULL;
>   		khugepaged_enter_vma_merge(area);
> @@ -1292,7 +1323,8 @@ munmap_back:
>   	/*
>   	 * Can we just expand an old mapping?
>   	 */
> -	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
> +	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file,
> +				pgoff, NULL, NULL);
>   	if (vma)
>   		goto out;
>   
> @@ -2025,9 +2057,10 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>   
>   	if (new_below)
>   		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
> -			((addr - new->vm_start) >> PAGE_SHIFT), new);
> +			((addr - new->vm_start) >> PAGE_SHIFT), new, NULL);
>   	else
> -		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
> +		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff,
> +			new, NULL);
>   
>   	/* Success. */
>   	if (!err)
> @@ -2240,7 +2273,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
>   
>   	/* Can we just expand an old private anonymous mapping? */
>   	vma = vma_merge(mm, prev, addr, addr + len, flags,
> -					NULL, NULL, pgoff, NULL);
> +					NULL, NULL, pgoff, NULL, NULL);
>   	if (vma)
>   		goto out;
>   
> @@ -2396,7 +2429,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>   	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
>   		return NULL;	/* should never get here */
>   	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
> -			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
> +			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
> +			NULL);
>   	if (new_vma) {
>   		/*
>   		 * Source vma may have been merged into new_vma
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a409926..f461177 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -179,7 +179,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>   	 */
>   	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>   	*pprev = vma_merge(mm, *pprev, start, end, newflags,
> -			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
> +			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
> +			NULL);
>   	if (*pprev) {
>   		vma = *pprev;
>   		goto success;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 1b61c2d..8586c52 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -512,7 +512,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>   			int pages = (new_len - old_len) >> PAGE_SHIFT;
>   
>   			if (vma_adjust(vma, vma->vm_start, addr + new_len,
> -				       vma->vm_pgoff, NULL)) {
> +				       vma->vm_pgoff, NULL, NULL)) {
>   				ret = -ENOMEM;
>   				goto out;
>   			}
> diff --git a/mm/mvolatile.c b/mm/mvolatile.c
> new file mode 100644
> index 0000000..8b812d2
> --- /dev/null
> +++ b/mm/mvolatile.c
> @@ -0,0 +1,312 @@
> +/*
> + *	linux/mm/mvolatile.c
> + *
> + *  Copyright 2012 Minchan Kim
> + *
> + *  This work is licensed under the terms of the GNU GPL, version 2. See
> + *  the COPYING file in the top-level directory.
> + */
> +
> +#include <linux/mvolatile.h>
> +#include <linux/mm_types.h>
> +#include <linux/mm.h>
> +#include <linux/rmap.h>
> +#include <linux/mempolicy.h>
> +
> +#ifndef CONFIG_VOLATILE_PAGE
> +SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
> +{
> +	return -EINVAL;
> +}
> +
> +SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
> +{
> +	return -EINVAL;
> +}
> +#else
> +
> +#define NO_PURGED	0
> +#define PURGED		1
> +
> +/*
> + * N: Normal VMA
> + * V: Volatile VMA
> + * P: Purged volatile VMA
> + *
> + * Assume that each VMA has two block so case 1-8 consists of three VMA.
> + * For example, NNPPVV means VMA1 has normal VMA, VMA2 has purged volailte VMA,
> + * and VMA3 has volatile VMA. With another example, NNPVVV means VMA1 has
> + * normal VMA, VMA2-1 has purged volatile VMA, VMA2-2 has volatile VMA.
> + *
> + * Case 7,8 create a new VMA and we call it VMA4 which can be loated before VMA2
> + * or after.
> + *
> + * Notice: The merge between volatile VMAs shouldn't happen.
> + * If we call mnovolatile(VMA2),
> + *
> + * Case 1 NNPPVV -> NNNNVV
> + * Case 2 VVPPNN -> VVNNNN
> + * Case 3 NNPPNN -> NNNNNN
> + * Case 4 NNPPVV -> NNNPVV
> + * case 5 VVPPNN -> VVPNNN
> + * case 6 VVPPVV -> VVNNVV
> + * case 7 VVPPVV -> VVNPVV
> + * case 8 VVPPVV -> VVPNVV
> + */
> +static int do_mnovolatile(struct vm_area_struct *vma,
> +		struct vm_area_struct **prev, unsigned long start,
> +		unsigned long end, bool *is_purged)
> +{
> +	unsigned long new_flags;
> +	int error = 0;
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgoff_t pgoff;
> +	bool purged = false;
> +
> +	new_flags = vma->vm_flags & ~VM_VOLATILE;
> +	if (new_flags == vma->vm_flags) {
> +		*prev = vma;
> +		goto success;
> +	}
> +
> +
> +	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
> +	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
> +			vma->vm_file, pgoff, vma_policy(vma), &purged);
> +	if (*prev) {
> +		vma = *prev;
> +		goto success;
> +	}
> +
> +	*prev = vma;
> +
> +	if (start != vma->vm_start) {
> +		error = split_vma(mm, vma, start, 1);
> +		if (error)
> +			goto out;
> +	}
> +
> +	if (end != vma->vm_end) {
> +		error = split_vma(mm, vma, end, 0);
> +		if (error)
> +			goto out;
> +	}
> +
> +success:
> +	/* V6. VVPPVV -> VVNNVV */
> +	vma_lock_anon_vma(vma);
> +	*is_purged |= (vma->purged|purged);
> +	vma_unlock_anon_vma(vma);
> +
> +	vma->vm_flags = new_flags;
> +	vma->purged = false;
> +	return 0;
> +out:
> +	return error;
> +}
> +
> +/* I didn't look into KSM/Hugepage so disalbed them */
> +#define VM_NO_VOLATILE	(VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|\
> +		VM_MERGEABLE|VM_HUGEPAGE|VM_LOCKED)
> +
> +static int do_mvolatile(struct vm_area_struct *vma,
> +	struct vm_area_struct **prev, unsigned long start, unsigned long end)
> +{
> +	int error = -EINVAL;
> +	vm_flags_t new_flags = vma->vm_flags;
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	new_flags |= VM_VOLATILE;
> +
> +	/* Note : Current version doesn't support file vma volatile */
> +	if (vma->vm_file) {
> +		*prev = vma;
> +		goto out;
> +	}
> +
> +	if (vma->vm_flags & VM_NO_VOLATILE ||
> +			(vma == get_gate_vma(current->mm))) {
> +		*prev = vma;
> +		goto out;
> +	}
> +	/*
> +	 * In case of calling MADV_VOLATILE again,
> +	 * We just reset purged state.
> +	 */
> +	if (new_flags == vma->vm_flags) {
> +		*prev = vma;
> +		vma_lock_anon_vma(vma);
> +		vma->purged = false;
> +		vma_unlock_anon_vma(vma);
> +		error = 0;
> +		goto out;
> +	}
> +
> +	*prev = vma;
> +
> +	if (start != vma->vm_start) {
> +		error = split_vma(mm, vma, start, 1);
> +		if (error)
> +			goto out;
> +	}
> +
> +	if (end != vma->vm_end) {
> +		error = split_vma(mm, vma, end, 0);
> +		if (error)
> +			goto out;
> +	}
> +
> +	error = 0;
> +
> +	vma_lock_anon_vma(vma);
> +	vma->vm_flags = new_flags;
> +	vma_unlock_anon_vma(vma);
> +out:
> +	return error;
> +}
> +
> +/*
> + * Return -EINVAL if range doesn't include a right vma at all.
> + * Return -ENOMEM with interrupting range opeartion if memory is not enough to
> + * merge/split vmas.
> + * Return 0 if range consists of only proper vmas.
> + * Return 1 if part of range includes inavlid area(ex, hole/huge/ksm/mlock/
> + * special area)
> + */
> +SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
> +{
> +	unsigned long end, tmp;
> +	struct vm_area_struct *vma, *prev;
> +	bool invalid = false;
> +	int error = -EINVAL;
> +
> +	down_write(&current->mm->mmap_sem);
> +	if (start & ~PAGE_MASK)
> +		goto out;
> +
> +	len &= PAGE_MASK;
> +	if (!len)
> +		goto out;
> +
> +	end = start + len;
> +	if (end < start)
> +		goto out;
> +
> +	vma = find_vma_prev(current->mm, start, &prev);
> +	if (!vma)
> +		goto out;
> +
> +	if (start > vma->vm_start)
> +		prev = vma;
> +
> +	for (;;) {
> +		/* Here start < (end|vma->vm_end). */
> +		if (start < vma->vm_start) {
> +			start = vma->vm_start;
> +			if (start >= end)
> +				goto out;
> +			invalid = true;
> +		}
> +
> +		/* Here vma->vm_start <= start < (end|vma->vm_end) */
> +		tmp = vma->vm_end;
> +		if (end < tmp)
> +			tmp = end;
> +
> +		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> +		error = do_mvolatile(vma, &prev, start, tmp);
> +		if (error == -ENOMEM) {
> +			up_write(&current->mm->mmap_sem);
> +			return error;
> +		}
> +		if (error == -EINVAL)
> +			invalid = true;
> +		else
> +			error = 0;
> +		start = tmp;
> +		if (prev && start < prev->vm_end)
> +			start = prev->vm_end;
> +		if (start >= end)
> +			break;
> +
> +		vma = prev->vm_next;
> +		if (!vma)
> +			break;
> +	}
> +out:
> +	up_write(&current->mm->mmap_sem);
> +	return invalid ? 1 : 0;
> +}
> +/*
> + * Return -ENOMEM with interrupting range opeartion if memory is not enough
> + * to merge/split vmas.
> + * Return 1 if part of range includes purged's one, otherwise, return 0
> + */
> +SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
> +{
> +	unsigned long end, tmp;
> +	struct vm_area_struct *vma, *prev;
> +	int ret, error = -EINVAL;
> +	bool is_purged = false;
> +
> +	down_write(&current->mm->mmap_sem);
> +	if (start & ~PAGE_MASK)
> +		goto out;
> +
> +	len &= PAGE_MASK;
> +	if (!len)
> +		goto out;
> +
> +	end = start + len;
> +	if (end < start)
> +		goto out;
> +
> +	vma = find_vma_prev(current->mm, start, &prev);
> +	if (!vma)
> +		goto out;
> +
> +	if (start > vma->vm_start)
> +		prev = vma;
> +
> +	for (;;) {
> +		/* Here start < (end|vma->vm_end). */
> +		if (start < vma->vm_start) {
> +			start = vma->vm_start;
> +			if (start >= end)
> +				goto out;
> +		}
> +
> +		/* Here vma->vm_start <= start < (end|vma->vm_end) */
> +		tmp = vma->vm_end;
> +		if (end < tmp)
> +			tmp = end;
> +
> +		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> +		error = do_mnovolatile(vma, &prev, start, tmp, &is_purged);
> +		if (error) {
> +			WARN_ON(error != -ENOMEM);
> +			goto out;
> +		}
> +		start = tmp;
> +		if (prev && start < prev->vm_end)
> +			start = prev->vm_end;
> +		if (start >= end)
> +			break;
> +
> +		vma = prev->vm_next;
> +		if (!vma)
> +			break;
> +	}
> +out:
> +	up_write(&current->mm->mmap_sem);
> +
> +	if (error)
> +		ret = error;
> +	else if (is_purged)
> +		ret = PURGED;
> +	else
> +		ret = NO_PURGED;
> +
> +	return ret;
> +}
> +#endif
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 2ee1ef0..402d9da 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -57,6 +57,7 @@
>   #include <linux/migrate.h>
>   #include <linux/hugetlb.h>
>   #include <linux/backing-dev.h>
> +#include <linux/mvolatile.h>
>   
>   #include <asm/tlbflush.h>
>   
> @@ -308,6 +309,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>   	vma->anon_vma = anon_vma;
>   	anon_vma_lock(anon_vma);
>   	anon_vma_chain_link(vma, avc, anon_vma);
> +	vma_purge_copy(vma, pvma);
>   	anon_vma_unlock(anon_vma);
>   
>   	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
