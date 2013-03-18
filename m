Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 004DF6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 01:23:34 -0400 (EDT)
Received: by mail-qe0-f46.google.com with SMTP id a11so3069951qen.5
        for <linux-mm@kvack.org>; Sun, 17 Mar 2013 22:23:34 -0700 (PDT)
Message-ID: <5146A4CC.3060306@gmail.com>
Date: Mon, 18 Mar 2013 13:23:24 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 00/30] Transparent huge page cache
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <514691F5.2040204@gmail.com>
In-Reply-To: <514691F5.2040204@gmail.com>
Content-Type: multipart/alternative;
 boundary="------------020901080709000908050707"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------020901080709000908050707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/18/2013 12:03 PM, Simon Jeons wrote:
> Hi Kirill,
> On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>
>> Here's the second version of the patchset.
>>
>> The intend of the work is get code ready to enable transparent huge page
>> cache for the most simple fs -- ramfs.
>>
>> We have read()/write()/mmap() functionality now. Still plenty work 
>> ahead.
>
> One offline question.
>
> Why set PG_mlocked to page_tail which be splited in function 
> __split_huge_page_refcount?
>

Also why can't find where _PAGE_SPLITTING and _PAGE_PSE flags are 
cleared in split_huge_page path?

>>
>> Any feedback is welcome.
>>
>> Changes since v1:
>>   - mmap();
>>   - fix add_to_page_cache_locked() and delete_from_page_cache();
>>   - introduce mapping_can_have_hugepages();
>>   - call split_huge_page() only for head page in filemap_fault();
>>   - wait_split_huge_page(): serialize over i_mmap_mutex too;
>>   - lru_add_page_tail: avoid PageUnevictable on active/inactive lru 
>> lists;
>>   - fix off-by-one in zero_huge_user_segment();
>>   - THP_WRITE_ALLOC/THP_WRITE_FAILED counters;
>>
>> TODO:
>>   - memcg accounting has not yet evaluated;
>>   - collapse;
>>   - migration (?);
>>   - stats, knobs, etc.;
>>   - tmpfs/shmem enabling;
>>
>>
>> Kirill A. Shutemov (30):
>>    block: implement add_bdi_stat()
>>    mm: implement zero_huge_user_segment and friends
>>    mm: drop actor argument of do_generic_file_read()
>>    radix-tree: implement preload for multiple contiguous elements
>>    thp, mm: avoid PageUnevictable on active/inactive lru lists
>>    thp, mm: basic defines for transparent huge page cache
>>    thp, mm: introduce mapping_can_have_hugepages() predicate
>>    thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>>    thp, mm: rewrite delete_from_page_cache() to support huge pages
>>    thp, mm: locking tail page is a bug
>>    thp, mm: handle tail pages in page_cache_get_speculative()
>>    thp, mm: add event counters for huge page alloc on write to a file
>>    thp, mm: implement grab_cache_huge_page_write_begin()
>>    thp, mm: naive support of thp in generic read/write routines
>>    thp, libfs: initial support of thp in
>>      simple_read/write_begin/write_end
>>    thp: handle file pages in split_huge_page()
>>    thp: wait_split_huge_page(): serialize over i_mmap_mutex too
>>    thp, mm: truncate support for transparent huge page cache
>>    thp, mm: split huge page on mmap file page
>>    ramfs: enable transparent huge page cache
>>    x86-64, mm: proper alignment mappings with hugepages
>>    mm: add huge_fault() callback to vm_operations_struct
>>    thp: prepare zap_huge_pmd() to uncharge file pages
>>    thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
>>    thp, mm: basic huge_fault implementation for generic_file_vm_ops
>>    thp: extract fallback path from do_huge_pmd_anonymous_page() to a
>>      function
>>    thp: initial implementation of do_huge_linear_fault()
>>    thp: handle write-protect exception to file-backed huge pages
>>    thp: call __vma_adjust_trans_huge() for file-backed VMA
>>    thp: map file-backed huge pages on fault
>>
>>   arch/x86/kernel/sys_x86_64.c  |   13 +-
>>   fs/libfs.c                    |   50 ++++-
>>   fs/ramfs/inode.c              |    6 +-
>>   include/linux/backing-dev.h   |   10 +
>>   include/linux/huge_mm.h       |   36 +++-
>>   include/linux/mm.h            |   16 ++
>>   include/linux/pagemap.h       |   24 ++-
>>   include/linux/radix-tree.h    |    3 +
>>   include/linux/vm_event_item.h |    2 +
>>   lib/radix-tree.c              |   32 ++-
>>   mm/filemap.c                  |  283 +++++++++++++++++++++----
>>   mm/huge_memory.c              |  462 
>> ++++++++++++++++++++++++++++++++++-------
>>   mm/memory.c                   |   31 ++-
>>   mm/swap.c                     |    3 +-
>>   mm/truncate.c                 |   12 ++
>>   mm/vmstat.c                   |    2 +
>>   16 files changed, 842 insertions(+), 143 deletions(-)
>>
>


--------------020901080709000908050707
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 03/18/2013 12:03 PM, Simon Jeons
      wrote:<br>
    </div>
    <blockquote cite="mid:514691F5.2040204@gmail.com" type="cite">Hi
      Kirill,
      <br>
      On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
      <br>
      <blockquote type="cite">From: "Kirill A. Shutemov"
        <a class="moz-txt-link-rfc2396E" href="mailto:kirill.shutemov@linux.intel.com">&lt;kirill.shutemov@linux.intel.com&gt;</a>
        <br>
        <br>
        Here's the second version of the patchset.
        <br>
        <br>
        The intend of the work is get code ready to enable transparent
        huge page
        <br>
        cache for the most simple fs -- ramfs.
        <br>
        <br>
        We have read()/write()/mmap() functionality now. Still plenty
        work ahead.
        <br>
      </blockquote>
      <br>
      One offline question.
      <br>
      <br>
      Why set PG_mlocked to page_tail which be splited in function
      __split_huge_page_refcount?
      <br>
      <br>
    </blockquote>
    <br>
    Also why can't find where _PAGE_SPLITTING and <big>_PAGE_PSE flags
      are cleared in split_huge_page path?</big><br>
    <br>
    <blockquote cite="mid:514691F5.2040204@gmail.com" type="cite">
      <blockquote type="cite">
        <br>
        Any feedback is welcome.
        <br>
        <br>
        Changes since v1:
        <br>
        &nbsp; - mmap();
        <br>
        &nbsp; - fix add_to_page_cache_locked() and delete_from_page_cache();
        <br>
        &nbsp; - introduce mapping_can_have_hugepages();
        <br>
        &nbsp; - call split_huge_page() only for head page in
        filemap_fault();
        <br>
        &nbsp; - wait_split_huge_page(): serialize over i_mmap_mutex too;
        <br>
        &nbsp; - lru_add_page_tail: avoid PageUnevictable on active/inactive
        lru lists;
        <br>
        &nbsp; - fix off-by-one in zero_huge_user_segment();
        <br>
        &nbsp; - THP_WRITE_ALLOC/THP_WRITE_FAILED counters;
        <br>
        <br>
        TODO:
        <br>
        &nbsp; - memcg accounting has not yet evaluated;
        <br>
        &nbsp; - collapse;
        <br>
        &nbsp; - migration (?);
        <br>
        &nbsp; - stats, knobs, etc.;
        <br>
        &nbsp; - tmpfs/shmem enabling;
        <br>
        <br>
        <br>
        Kirill A. Shutemov (30):
        <br>
        &nbsp;&nbsp; block: implement add_bdi_stat()
        <br>
        &nbsp;&nbsp; mm: implement zero_huge_user_segment and friends
        <br>
        &nbsp;&nbsp; mm: drop actor argument of do_generic_file_read()
        <br>
        &nbsp;&nbsp; radix-tree: implement preload for multiple contiguous
        elements
        <br>
        &nbsp;&nbsp; thp, mm: avoid PageUnevictable on active/inactive lru lists
        <br>
        &nbsp;&nbsp; thp, mm: basic defines for transparent huge page cache
        <br>
        &nbsp;&nbsp; thp, mm: introduce mapping_can_have_hugepages() predicate
        <br>
        &nbsp;&nbsp; thp, mm: rewrite add_to_page_cache_locked() to support huge
        pages
        <br>
        &nbsp;&nbsp; thp, mm: rewrite delete_from_page_cache() to support huge
        pages
        <br>
        &nbsp;&nbsp; thp, mm: locking tail page is a bug
        <br>
        &nbsp;&nbsp; thp, mm: handle tail pages in page_cache_get_speculative()
        <br>
        &nbsp;&nbsp; thp, mm: add event counters for huge page alloc on write to a
        file
        <br>
        &nbsp;&nbsp; thp, mm: implement grab_cache_huge_page_write_begin()
        <br>
        &nbsp;&nbsp; thp, mm: naive support of thp in generic read/write routines
        <br>
        &nbsp;&nbsp; thp, libfs: initial support of thp in
        <br>
        &nbsp;&nbsp;&nbsp;&nbsp; simple_read/write_begin/write_end
        <br>
        &nbsp;&nbsp; thp: handle file pages in split_huge_page()
        <br>
        &nbsp;&nbsp; thp: wait_split_huge_page(): serialize over i_mmap_mutex too
        <br>
        &nbsp;&nbsp; thp, mm: truncate support for transparent huge page cache
        <br>
        &nbsp;&nbsp; thp, mm: split huge page on mmap file page
        <br>
        &nbsp;&nbsp; ramfs: enable transparent huge page cache
        <br>
        &nbsp;&nbsp; x86-64, mm: proper alignment mappings with hugepages
        <br>
        &nbsp;&nbsp; mm: add huge_fault() callback to vm_operations_struct
        <br>
        &nbsp;&nbsp; thp: prepare zap_huge_pmd() to uncharge file pages
        <br>
        &nbsp;&nbsp; thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
        <br>
        &nbsp;&nbsp; thp, mm: basic huge_fault implementation for
        generic_file_vm_ops
        <br>
        &nbsp;&nbsp; thp: extract fallback path from do_huge_pmd_anonymous_page()
        to a
        <br>
        &nbsp;&nbsp;&nbsp;&nbsp; function
        <br>
        &nbsp;&nbsp; thp: initial implementation of do_huge_linear_fault()
        <br>
        &nbsp;&nbsp; thp: handle write-protect exception to file-backed huge pages
        <br>
        &nbsp;&nbsp; thp: call __vma_adjust_trans_huge() for file-backed VMA
        <br>
        &nbsp;&nbsp; thp: map file-backed huge pages on fault
        <br>
        <br>
        &nbsp; arch/x86/kernel/sys_x86_64.c&nbsp; |&nbsp;&nbsp; 13 +-
        <br>
        &nbsp; fs/libfs.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 50 ++++-
        <br>
        &nbsp; fs/ramfs/inode.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp; 6 +-
        <br>
        &nbsp; include/linux/backing-dev.h&nbsp;&nbsp; |&nbsp;&nbsp; 10 +
        <br>
        &nbsp; include/linux/huge_mm.h&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 36 +++-
        <br>
        &nbsp; include/linux/mm.h&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 16 ++
        <br>
        &nbsp; include/linux/pagemap.h&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 24 ++-
        <br>
        &nbsp; include/linux/radix-tree.h&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp; 3 +
        <br>
        &nbsp; include/linux/vm_event_item.h |&nbsp;&nbsp;&nbsp; 2 +
        <br>
        &nbsp; lib/radix-tree.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 32 ++-
        <br>
        &nbsp; mm/filemap.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp; 283 +++++++++++++++++++++----
        <br>
        &nbsp; mm/huge_memory.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp; 462
        ++++++++++++++++++++++++++++++++++-------
        <br>
        &nbsp; mm/memory.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 31 ++-
        <br>
        &nbsp; mm/swap.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp; 3 +-
        <br>
        &nbsp; mm/truncate.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; 12 ++
        <br>
        &nbsp; mm/vmstat.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp; 2 +
        <br>
        &nbsp; 16 files changed, 842 insertions(+), 143 deletions(-)
        <br>
        <br>
      </blockquote>
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------020901080709000908050707--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
