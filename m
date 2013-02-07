Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E11E66B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 19:39:31 -0500 (EST)
Message-ID: <5112F7AF.6010307@oracle.com>
Date: Wed, 06 Feb 2013 19:39:11 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: use long type for page counts in mm_populate()
 and get_user_pages()
References: <1359591980-29542-1-git-send-email-walken@google.com> <1359591980-29542-2-git-send-email-walken@google.com>
In-Reply-To: <1359591980-29542-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michel,

We're now hitting the VM_BUG_ON() which was added in the last hunk of the
patch:

[  143.217822] ------------[ cut here ]------------
[  143.219938] kernel BUG at mm/mlock.c:424!
[  143.220031] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[  143.220031] Modules linked in:
[  143.226691] CPU 3
[  143.226691] Pid: 15435, comm: trinity Tainted: G      D W    3.8.0-rc6-next-20130206-sasha-00029-g95a59cb2 #275
[  143.233222] RIP: 0010:[<ffffffff81242e42>]  [<ffffffff81242e42>] __mm_populate+0x112/0x180
[  143.233222] RSP: 0018:ffff880010061ef8  EFLAGS: 00010246
[  143.233222] RAX: 0000000000000000 RBX: ffff880016329228 RCX: 0000000000000000
[  143.233222] RDX: ffffea0002fe2f80 RSI: 0000000000000000 RDI: ffffea0002fe2f80
[  143.233222] RBP: ffff880010061f48 R08: 0000000000000001 R09: 0000000000000000
[  143.233222] R10: 0000000000000000 R11: ffffea0002fe2f80 R12: 00007ffffffff000
[  143.233222] R13: 00007ff388eb3000 R14: 00007ff388e92000 R15: ffff880009a00000
[  143.233222] FS:  00007ff389085700(0000) GS:ffff88000fc00000(0000) knlGS:0000000000000000
[  143.233222] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  143.233222] CR2: 00007fa6b6aff180 CR3: 000000001002f000 CR4: 00000000000406e0
[  143.303103] can: request_module (can-proto-6) failed.
[  143.233222] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  143.233222] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  143.321178] Process trinity (pid: 15435, threadinfo ffff880010060000, task ffff8800100a8000)
[  143.321178] Stack:
[  143.321178]  0000000100000001 ffff880009a00098 0000000000000001 00000000100a8000
[  143.321178]  00007ff3890856a8 0000000000000000 0000000000000001 ffff8800100a8000
[  143.321178]  00007ff3890856a8 0000000000000097 ffff880010061f78 ffffffff812431d0
[  143.321178] Call Trace:
[  143.321178]  [<ffffffff812431d0>] sys_mlockall+0x160/0x1a0
[  143.321178]  [<ffffffff83d73d58>] tracesys+0xe1/0xe6
[  143.321178] Code: e8 54 fa ff ff 48 83 f8 00 7d 1e 8b 55 b4 85 d2 75 2f 48 83 f8 f2 bb f4 ff ff ff 74 3e b3 f5 48 83 f8 f4 0f
45 d8 eb 33 90 75 06 <0f> 0b 0f 1f 40 00 48 c1 e0 0c 49 01 c6 eb 0a 0f 1f 80 00 00 00
[  143.392984] RIP  [<ffffffff81242e42>] __mm_populate+0x112/0x180
[  143.392984]  RSP <ffff880010061ef8>
[  143.411359] ---[ end trace a7919e7f17c0a72d ]---


Thanks,
Sasha

On 01/30/2013 07:26 PM, Michel Lespinasse wrote:
> Use long type for page counts in mm_populate() so as to avoid integer
> overflow when running the following test code:
> 
> int main(void) {
>   void *p = mmap(NULL, 0x100000000000, PROT_READ,
>                  MAP_PRIVATE | MAP_ANON, -1, 0);
>   printf("p: %p\n", p);
>   mlockall(MCL_CURRENT);
>   printf("done\n");
>   return 0;
> }
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> 
> ---
>  include/linux/hugetlb.h |  6 +++---
>  include/linux/mm.h      | 14 +++++++-------
>  mm/hugetlb.c            | 10 +++++-----
>  mm/memory.c             | 14 +++++++-------
>  mm/mlock.c              |  5 +++--
>  5 files changed, 25 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 0c80d3f57a5b..fc6ed17cfd17 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -43,9 +43,9 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
>  #endif
>  
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
> -int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
> -			struct page **, struct vm_area_struct **,
> -			unsigned long *, int *, int, unsigned int flags);
> +long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
> +			 struct page **, struct vm_area_struct **,
> +			 unsigned long *, long *, long, unsigned int flags);
>  void unmap_hugepage_range(struct vm_area_struct *,
>  			  unsigned long, unsigned long, struct page *);
>  void __unmap_hugepage_range_final(struct mmu_gather *tlb,
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a224430578f0..d5716094f191 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1040,13 +1040,13 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *
>  extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
>  		void *buf, int len, int write);
>  
> -int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> -		     unsigned long start, int len, unsigned int foll_flags,
> -		     struct page **pages, struct vm_area_struct **vmas,
> -		     int *nonblocking);
> -int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> -			unsigned long start, int nr_pages, int write, int force,
> -			struct page **pages, struct vm_area_struct **vmas);
> +long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +		      unsigned long start, long len, unsigned int foll_flags,
> +		      struct page **pages, struct vm_area_struct **vmas,
> +		      int *nonblocking);
> +long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +		    unsigned long start, long nr_pages, int write, int force,
> +		    struct page **pages, struct vm_area_struct **vmas);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
>  struct kvec;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4f3ea0b1e57c..4ad07221ce60 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2924,14 +2924,14 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  	return NULL;
>  }
>  
> -int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> -			struct page **pages, struct vm_area_struct **vmas,
> -			unsigned long *position, int *length, int i,
> -			unsigned int flags)
> +long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			 struct page **pages, struct vm_area_struct **vmas,
> +			 unsigned long *position, long *length, long i,
> +			 unsigned int flags)
>  {
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
> -	int remainder = *length;
> +	long remainder = *length;
>  	struct hstate *h = hstate_vma(vma);
>  
>  	spin_lock(&mm->page_table_lock);
> diff --git a/mm/memory.c b/mm/memory.c
> index f56683208e7f..381b78c20d84 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1673,12 +1673,12 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
>   * instead of __get_user_pages. __get_user_pages should be used only if
>   * you need some special @gup_flags.
>   */
> -int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> -		     unsigned long start, int nr_pages, unsigned int gup_flags,
> -		     struct page **pages, struct vm_area_struct **vmas,
> -		     int *nonblocking)
> +long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +		unsigned long start, long nr_pages, unsigned int gup_flags,
> +		struct page **pages, struct vm_area_struct **vmas,
> +		int *nonblocking)
>  {
> -	int i;
> +	long i;
>  	unsigned long vm_flags;
>  
>  	if (nr_pages <= 0)
> @@ -1977,8 +1977,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>   *
>   * See also get_user_pages_fast, for performance critical applications.
>   */
> -int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> -		unsigned long start, int nr_pages, int write, int force,
> +long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +		unsigned long start, long nr_pages, int write, int force,
>  		struct page **pages, struct vm_area_struct **vmas)
>  {
>  	int flags = FOLL_TOUCH;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index b1647fbd6bce..e1fa9e4b0a66 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -160,7 +160,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long addr = start;
> -	int nr_pages = (end - start) / PAGE_SIZE;
> +	long nr_pages = (end - start) / PAGE_SIZE;
>  	int gup_flags;
>  
>  	VM_BUG_ON(start & ~PAGE_MASK);
> @@ -378,7 +378,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>  	unsigned long end, nstart, nend;
>  	struct vm_area_struct *vma = NULL;
>  	int locked = 0;
> -	int ret = 0;
> +	long ret = 0;
>  
>  	VM_BUG_ON(start & ~PAGE_MASK);
>  	VM_BUG_ON(len != PAGE_ALIGN(len));
> @@ -421,6 +421,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>  			ret = __mlock_posix_error_return(ret);
>  			break;
>  		}
> +		VM_BUG_ON(!ret);
>  		nend = nstart + ret * PAGE_SIZE;
>  		ret = 0;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
