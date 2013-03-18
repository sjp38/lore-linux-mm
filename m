Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id CC6246B0027
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 00:03:11 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id ht11so2678098vcb.27
        for <linux-mm@kvack.org>; Sun, 17 Mar 2013 21:03:10 -0700 (PDT)
Message-ID: <514691F5.2040204@gmail.com>
Date: Mon, 18 Mar 2013 12:03:01 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 00/30] Transparent huge page cache
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Kirill,
On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Here's the second version of the patchset.
>
> The intend of the work is get code ready to enable transparent huge page
> cache for the most simple fs -- ramfs.
>
> We have read()/write()/mmap() functionality now. Still plenty work ahead.

One offline question.

Why set PG_mlocked to page_tail which be splited in function 
__split_huge_page_refcount?

>
> Any feedback is welcome.
>
> Changes since v1:
>   - mmap();
>   - fix add_to_page_cache_locked() and delete_from_page_cache();
>   - introduce mapping_can_have_hugepages();
>   - call split_huge_page() only for head page in filemap_fault();
>   - wait_split_huge_page(): serialize over i_mmap_mutex too;
>   - lru_add_page_tail: avoid PageUnevictable on active/inactive lru lists;
>   - fix off-by-one in zero_huge_user_segment();
>   - THP_WRITE_ALLOC/THP_WRITE_FAILED counters;
>
> TODO:
>   - memcg accounting has not yet evaluated;
>   - collapse;
>   - migration (?);
>   - stats, knobs, etc.;
>   - tmpfs/shmem enabling;
>
>
> Kirill A. Shutemov (30):
>    block: implement add_bdi_stat()
>    mm: implement zero_huge_user_segment and friends
>    mm: drop actor argument of do_generic_file_read()
>    radix-tree: implement preload for multiple contiguous elements
>    thp, mm: avoid PageUnevictable on active/inactive lru lists
>    thp, mm: basic defines for transparent huge page cache
>    thp, mm: introduce mapping_can_have_hugepages() predicate
>    thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>    thp, mm: rewrite delete_from_page_cache() to support huge pages
>    thp, mm: locking tail page is a bug
>    thp, mm: handle tail pages in page_cache_get_speculative()
>    thp, mm: add event counters for huge page alloc on write to a file
>    thp, mm: implement grab_cache_huge_page_write_begin()
>    thp, mm: naive support of thp in generic read/write routines
>    thp, libfs: initial support of thp in
>      simple_read/write_begin/write_end
>    thp: handle file pages in split_huge_page()
>    thp: wait_split_huge_page(): serialize over i_mmap_mutex too
>    thp, mm: truncate support for transparent huge page cache
>    thp, mm: split huge page on mmap file page
>    ramfs: enable transparent huge page cache
>    x86-64, mm: proper alignment mappings with hugepages
>    mm: add huge_fault() callback to vm_operations_struct
>    thp: prepare zap_huge_pmd() to uncharge file pages
>    thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
>    thp, mm: basic huge_fault implementation for generic_file_vm_ops
>    thp: extract fallback path from do_huge_pmd_anonymous_page() to a
>      function
>    thp: initial implementation of do_huge_linear_fault()
>    thp: handle write-protect exception to file-backed huge pages
>    thp: call __vma_adjust_trans_huge() for file-backed VMA
>    thp: map file-backed huge pages on fault
>
>   arch/x86/kernel/sys_x86_64.c  |   13 +-
>   fs/libfs.c                    |   50 ++++-
>   fs/ramfs/inode.c              |    6 +-
>   include/linux/backing-dev.h   |   10 +
>   include/linux/huge_mm.h       |   36 +++-
>   include/linux/mm.h            |   16 ++
>   include/linux/pagemap.h       |   24 ++-
>   include/linux/radix-tree.h    |    3 +
>   include/linux/vm_event_item.h |    2 +
>   lib/radix-tree.c              |   32 ++-
>   mm/filemap.c                  |  283 +++++++++++++++++++++----
>   mm/huge_memory.c              |  462 ++++++++++++++++++++++++++++++++++-------
>   mm/memory.c                   |   31 ++-
>   mm/swap.c                     |    3 +-
>   mm/truncate.c                 |   12 ++
>   mm/vmstat.c                   |    2 +
>   16 files changed, 842 insertions(+), 143 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
