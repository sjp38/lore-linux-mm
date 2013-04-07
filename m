Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C9C1F6B0005
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 20:40:54 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id c10so5710509ieb.31
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 17:40:54 -0700 (PDT)
Message-ID: <5160C08D.9020101@gmail.com>
Date: Sun, 07 Apr 2013 08:40:45 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3, RFC 00/34] Transparent huge page cache
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Kirill,
On 04/05/2013 07:59 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Here's third RFC. Thanks everybody for feedback.

Could you answer my questions in your version two?

>
> The patchset is pretty big already and I want to stop generate new
> features to keep it reviewable. Next I'll concentrate on benchmarking and
> tuning.
>
> Therefore some features will be outside initial transparent huge page
> cache implementation:
>   - page collapsing;
>   - migration;
>   - tmpfs/shmem;
>
> There are few features which are not implemented and potentially can block
> upstreaming:
>
> 1. Currently we allocate 2M page even if we create only 1 byte file on
> ramfs. I don't think it's a problem by itself. With anon thp pages we also
> try to allocate huge pages whenever possible.
> The problem is that ramfs pages are unevictable and we can't just split
> and pushed them in swap as with anon thp. We (at some point) have to have
> mechanism to split last page of the file under memory pressure to reclaim
> some memory.
>
> 2. We don't have knobs for disabling transparent huge page cache per-mount
> or per-file. Should we have mount option and fadivse flags as part of
> initial implementation?
>
> Any thoughts?
>
> The patchset is also on git:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/pagecache
>
> v3:
>   - set RADIX_TREE_PRELOAD_NR to 512 only if we build with THP;
>   - rewrite lru_add_page_tail() to address few bags;
>   - memcg accounting;
>   - represent file thp pages in meminfo and friends;
>   - dump page order in filemap trace;
>   - add missed flush_dcache_page() in zero_huge_user_segment;
>   - random cleanups based on feedback.
> v2:
>   - mmap();
>   - fix add_to_page_cache_locked() and delete_from_page_cache();
>   - introduce mapping_can_have_hugepages();
>   - call split_huge_page() only for head page in filemap_fault();
>   - wait_split_huge_page(): serialize over i_mmap_mutex too;
>   - lru_add_page_tail: avoid PageUnevictable on active/inactive lru lists;
>   - fix off-by-one in zero_huge_user_segment();
>   - THP_WRITE_ALLOC/THP_WRITE_FAILED counters;
>
> Kirill A. Shutemov (34):
>    mm: drop actor argument of do_generic_file_read()
>    block: implement add_bdi_stat()
>    mm: implement zero_huge_user_segment and friends
>    radix-tree: implement preload for multiple contiguous elements
>    memcg, thp: charge huge cache pages
>    thp, mm: avoid PageUnevictable on active/inactive lru lists
>    thp, mm: basic defines for transparent huge page cache
>    thp, mm: introduce mapping_can_have_hugepages() predicate
>    thp: represent file thp pages in meminfo and friends
>    thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>    mm: trace filemap: dump page order
>    thp, mm: rewrite delete_from_page_cache() to support huge pages
>    thp, mm: trigger bug in replace_page_cache_page() on THP
>    thp, mm: locking tail page is a bug
>    thp, mm: handle tail pages in page_cache_get_speculative()
>    thp, mm: add event counters for huge page alloc on write to a file
>    thp, mm: implement grab_thp_write_begin()
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
>   arch/x86/kernel/sys_x86_64.c   |   12 +-
>   drivers/base/node.c            |   10 +
>   fs/libfs.c                     |   48 +++-
>   fs/proc/meminfo.c              |    6 +
>   fs/ramfs/inode.c               |    6 +-
>   include/linux/backing-dev.h    |   10 +
>   include/linux/huge_mm.h        |   36 ++-
>   include/linux/mm.h             |    8 +
>   include/linux/mmzone.h         |    1 +
>   include/linux/pagemap.h        |   33 ++-
>   include/linux/radix-tree.h     |   11 +
>   include/linux/vm_event_item.h  |    2 +
>   include/trace/events/filemap.h |    7 +-
>   lib/radix-tree.c               |   33 ++-
>   mm/filemap.c                   |  298 ++++++++++++++++++++-----
>   mm/huge_memory.c               |  474 +++++++++++++++++++++++++++++++++-------
>   mm/memcontrol.c                |    2 -
>   mm/memory.c                    |   41 +++-
>   mm/mmap.c                      |    3 +
>   mm/page_alloc.c                |    7 +-
>   mm/swap.c                      |   20 +-
>   mm/truncate.c                  |   13 ++
>   mm/vmstat.c                    |    2 +
>   23 files changed, 902 insertions(+), 181 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
