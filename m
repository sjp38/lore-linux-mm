Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1B94B6B0033
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:33:42 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379330740-5602-3-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCHv2 2/9] mm: convert mm->nr_ptes to atomic_t
Content-Transfer-Encoding: 7bit
Message-Id: <20130917143333.4CB67E0090@blue.fi.intel.com>
Date: Tue, 17 Sep 2013 17:33:33 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> With split page table lock for PMD level we can't hold
> mm->page_table_lock while updating nr_ptes.
> 
> Let's convert it to atomic_t to avoid races.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/proc/task_mmu.c       |  4 ++--
>  include/linux/mm_types.h |  2 +-
>  kernel/fork.c            |  2 +-
>  mm/huge_memory.c         | 10 +++++-----
>  mm/memory.c              |  4 ++--
>  mm/mmap.c                |  3 ++-
>  mm/oom_kill.c            |  6 +++---
>  7 files changed, 16 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 7366e9d..8e124ac 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -52,7 +52,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		"VmStk:\t%8lu kB\n"
>  		"VmExe:\t%8lu kB\n"
>  		"VmLib:\t%8lu kB\n"
> -		"VmPTE:\t%8lu kB\n"
> +		"VmPTE:\t%8zd kB\n"
>  		"VmSwap:\t%8lu kB\n",
>  		hiwater_vm << (PAGE_SHIFT-10),
>  		total_vm << (PAGE_SHIFT-10),
> @@ -62,7 +62,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		total_rss << (PAGE_SHIFT-10),
>  		data << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> -		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10,
> +		(PTRS_PER_PTE*sizeof(pte_t)*atomic_read(&mm->nr_ptes)) >> 10,
>  		swap << (PAGE_SHIFT-10));
>  }
>  

Erghh. There's still warning on mips. PTRS_PER_PTE is unsigned long there.
Let's just cast it to unsigned long and don't change format line:

		(unsigned long) (PTRS_PER_PTE * sizeof(pte_t) *
				atomic_read(&mm->nr_ptes)) >> 10,
Updated patch is below.

---
