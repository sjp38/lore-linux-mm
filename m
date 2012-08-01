Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 75EAD6B005A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 22:45:52 -0400 (EDT)
Message-ID: <50189857.4000501@redhat.com>
Date: Tue, 31 Jul 2012 22:45:43 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com> <50120FA8.20409@redhat.com> <20120727102356.GD612@suse.de> <5016DC5F.7030604@redhat.com> <20120731124650.GO612@suse.de> <50181AA1.0@redhat.com> <20120731200650.GB19524@tiehlicka.suse.cz>
In-Reply-To: <20120731200650.GB19524@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2012 04:06 PM, Michal Hocko wrote:
> On Tue 31-07-12 13:49:21, Larry Woodman wrote:
>> On 07/31/2012 08:46 AM, Mel Gorman wrote:
>>> Fundamentally I think the problem is that we are not correctly detecting
>>> that page table sharing took place during huge_pte_alloc(). This patch is
>>> longer and makes an API change but if I'm right, it addresses the underlying
>>> problem. The first VM_MAYSHARE patch is still necessary but would you mind
>>> testing this on top please?
>> Hi Mel, yes this does work just fine.  It ran for hours without a panic so
>> I'll Ack this one if you send it to the list.
> Hi Larry, thanks for testing! I have a different patch which tries to
> address this very same issue. I am not saying it is better or that it
> should be merged instead of Mel's one but I would be really happy if you
> could give it a try. We can discuss (dis)advantages of both approaches
> later.
>
> Thanks!

Hi Michal, the system hung when I tested this patch on top of the
latest 3.5 kernel.  I wont have AltSysrq access to the system until
tomorrow AM.  I'll retry this kernel and get AltSysrq output and let
you know whats happening in the morning.

Larry

> ---
>  From 8cbf3bd27125fc0a2a46cd5b1085d9e63f9c01fd Mon Sep 17 00:00:00 2001
> From: Michal Hocko<mhocko@suse.cz>
> Date: Tue, 31 Jul 2012 15:00:26 +0200
> Subject: [PATCH] mm: hugetlbfs: Correctly populate shared pmd
>
> Each page mapped in a processes address space must be correctly
> accounted for in _mapcount. Normally the rules for this are
> straight-forward but hugetlbfs page table sharing is different.
> The page table pages at the PMD level are reference counted while
> the mapcount remains the same. If this accounting is wrong, it causes
> bugs like this one reported by Larry Woodman
>
> [ 1106.156569] ------------[ cut here ]------------
> [ 1106.161731] kernel BUG at mm/filemap.c:135!
> [ 1106.166395] invalid opcode: 0000 [#1] SMP
> [ 1106.170975] CPU 22
> [ 1106.173115] Modules linked in: bridge stp llc sunrpc binfmt_misc dcdbas microcode pcspkr acpi_pad acpi]
> [ 1106.201770]
> [ 1106.203426] Pid: 18001, comm: mpitest Tainted: G        W    3.3.0+ #4 Dell Inc. PowerEdge R620/07NDJ2
> [ 1106.213822] RIP: 0010:[<ffffffff8112cfed>]  [<ffffffff8112cfed>] __delete_from_page_cache+0x15d/0x170
> [ 1106.224117] RSP: 0018:ffff880428973b88  EFLAGS: 00010002
> [ 1106.230032] RAX: 0000000000000001 RBX: ffffea0006b80000 RCX: 00000000ffffffb0
> [ 1106.237979] RDX: 0000000000016df1 RSI: 0000000000000009 RDI: ffff88043ffd9e00
> [ 1106.245927] RBP: ffff880428973b98 R08: 0000000000000050 R09: 0000000000000003
> [ 1106.253876] R10: 000000000000000d R11: 0000000000000000 R12: ffff880428708150
> [ 1106.261826] R13: ffff880428708150 R14: 0000000000000000 R15: ffffea0006b80000
> [ 1106.269780] FS:  0000000000000000(0000) GS:ffff88042fd60000(0000) knlGS:0000000000000000
> [ 1106.278794] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1106.285193] CR2: 0000003a1d38c4a8 CR3: 000000000187d000 CR4: 00000000000406e0
> [ 1106.293149] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1106.301097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1106.309046] Process mpitest (pid: 18001, threadinfo ffff880428972000, task ffff880428b5cc20)
> [ 1106.318447] Stack:
> [ 1106.320690]  ffffea0006b80000 0000000000000000 ffff880428973bc8 ffffffff8112d040
> [ 1106.328958]  ffff880428973bc8 00000000000002ab 00000000000002a0 ffff880428973c18
> [ 1106.337234]  ffff880428973cc8 ffffffff8125b405 ffff880400000001 0000000000000000
> [ 1106.345513] Call Trace:
> [ 1106.348235]  [<ffffffff8112d040>] delete_from_page_cache+0x40/0x80
> [ 1106.355128]  [<ffffffff8125b405>] truncate_hugepages+0x115/0x1f0
> [ 1106.361826]  [<ffffffff8125b4f8>] hugetlbfs_evict_inode+0x18/0x30
> [ 1106.368615]  [<ffffffff811ab1af>] evict+0x9f/0x1b0
> [ 1106.373951]  [<ffffffff811ab3a3>] iput_final+0xe3/0x1e0
> [ 1106.379773]  [<ffffffff811ab4de>] iput+0x3e/0x50
> [ 1106.384922]  [<ffffffff811a8e18>] d_kill+0xf8/0x110
> [ 1106.390356]  [<ffffffff811a8f12>] dput+0xe2/0x1b0
> [ 1106.395595]  [<ffffffff81193612>] __fput+0x162/0x240
>
> During fork(), copy_hugetlb_page_range() detects if huge_pte_alloc()
> shared page tables with the check dst_pte == src_pte. The logic is if
> the PMD page is the same, they must be shared. This assumes that the
> sharing is between the parent and child. However, if the sharing is with
> a different process entirely then this check fails as in this diagram.
>
> parent
>    |
>    ------------>pmd
>                 src_pte---------->  data page
>                                        ^
> other--------->pmd--------------------|
>                  ^
> child-----------|
>                 dst_pte
>
> For this situation to occur, it must be possible for Parent and Other
> to have faulted and failed to share page tables with each other. This is
> possible due to the following style of race.
>
> PROC A                                          PROC B
> copy_hugetlb_page_range                         copy_hugetlb_page_range
>    src_pte == huge_pte_offset                      src_pte == huge_pte_offset
>    !src_pte so no sharing                          !src_pte so no sharing
>
> (time passes)
>
> hugetlb_fault                                   hugetlb_fault
>    huge_pte_alloc                                  huge_pte_alloc
>      huge_pmd_share                                 huge_pmd_share
>        LOCK(i_mmap_mutex)
>        find nothing, no sharing
>        UNLOCK(i_mmap_mutex)
>                                                      LOCK(i_mmap_mutex)
>                                                      find nothing, no sharing
>                                                      UNLOCK(i_mmap_mutex)
>      pmd_alloc                                       pmd_alloc
>      LOCK(instantiation_mutex)
>      fault
>      UNLOCK(instantiation_mutex)
>                                                  LOCK(instantiation_mutex)
>                                                  fault
>                                                  UNLOCK(instantiation_mutex)
>
> These two processes are not poing to the same data page but are not sharing
> page tables because the opportunity was missed. When either process later
> forks, the src_pte == dst pte is potentially insufficient.  As the check
> falls through, the wrong PTE information is copied in (harmless but wrong)
> and the mapcount is bumped for a page mapped by a shared page table leading
> to the BUG_ON.
>
> This patch addresses the issue by moving pmd_alloc into huge_pmd_share
> which guarantees that the shared pud is populated in the same
> critical section as pmd. This also means that huge_pte_offset test in
> huge_pmd_share is serialized correctly now.
>
> Changelog and race identified by Mel Gorman
> Signed-off-by: Michal Hocko<mhocko@suse.cz>
> Reported-by: Larry Woodman<lwoodman@redhat.com>
> ---
>   arch/x86/mm/hugetlbpage.c |   10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index f6679a7..bb05f79 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -58,7 +58,7 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>   /*
>    * search for a shareable pmd page for hugetlb.
>    */
> -static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> +static pte_t* huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>   {
>   	struct vm_area_struct *vma = find_vma(mm, addr);
>   	struct address_space *mapping = vma->vm_file->f_mapping;
> @@ -68,6 +68,7 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>   	struct vm_area_struct *svma;
>   	unsigned long saddr;
>   	pte_t *spte = NULL;
> +	pte_t *pte;
>
>   	if (!vma_shareable(vma, addr))
>   		return;
> @@ -96,8 +97,10 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>   	else
>   		put_page(virt_to_page(spte));
>   	spin_unlock(&mm->page_table_lock);
> +	pte = pmd_alloc(mm, pud, addr);
>   out:
>   	mutex_unlock(&mapping->i_mmap_mutex);
> +	return pte;
>   }
>
>   /*
> @@ -142,8 +145,9 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>   		} else {
>   			BUG_ON(sz != PMD_SIZE);
>   			if (pud_none(*pud))
> -				huge_pmd_share(mm, addr, pud);
> -			pte = (pte_t *) pmd_alloc(mm, pud, addr);
> +				pte = huge_pmd_share(mm, addr, pud);
> +			else
> +				pte = (pte_t *) pmd_alloc(mm, pud, addr);
>   		}
>   	}
>   	BUG_ON(pte&&  !pte_none(*pte)&&  !pte_huge(*pte));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
