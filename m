Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 766996B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:32 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 9so10555638ykp.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 48si9806963yhw.195.2015.01.12.15.09.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:31 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 03/20] mm: Fix XIP fault vs truncate race
Message-Id: <20150112150929.55c31ccb22f466a9dbbde5d6@linux-foundation.org>
In-Reply-To: <1414185652-28663-4-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-4-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:35 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Pagecache faults recheck i_size after taking the page lock to ensure that
> the fault didn't race against a truncate.  We don't have a page to lock
> in the XIP case, so use the i_mmap_mutex instead.  It is locked in the
> truncate path in unmap_mapping_range() after updating i_size.  So while
> we hold it in the fault path, we are guaranteed that either i_size has
> already been updated in the truncate path, or that the truncate will
> subsequently call zap_page_range_single() and so remove the mapping we
> have just inserted.
> 
> There is a window of time in which i_size has been reduced and the
> thread has a mapping to a page which will be removed from the file,
> but this is harmless as the page will not be allocated to a different
> purpose before the thread's access to it is revoked.
> 

i_mmap_mutex is no more.  I made what are hopefulyl the appropriate
changes.

Also, that new locking rule is pretty subtle and we need to find a way
of alerting readers (and modifiers) of mm/memory.c to DAX's use of
i_mmap_lock().  Please review my suggested addition for accuracy and
cmopleteness.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-fix-xip-fault-vs-truncate-race-fix

switch to i_mmap_lock_read(), add comment in unmap_single_vma()

Cc: Jan Kara <jack@suse.cz>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/filemap_xip.c |   20 +++++++++++++-------
 mm/memory.c      |    5 +++++
 2 files changed, 18 insertions(+), 7 deletions(-)

diff -puN mm/filemap_xip.c~mm-fix-xip-fault-vs-truncate-race-fix mm/filemap_xip.c
--- a/mm/filemap_xip.c~mm-fix-xip-fault-vs-truncate-race-fix
+++ a/mm/filemap_xip.c
@@ -255,17 +255,20 @@ again:
 		__xip_unmap(mapping, vmf->pgoff);
 
 found:
-		/* We must recheck i_size under i_mmap_mutex */
-		mutex_lock(&mapping->i_mmap_mutex);
+		/*
+		 * We must recheck i_size under i_mmap_rwsem to prevent races
+		 * with truncation
+		 */
+		i_mmap_lock_read(mapping);
 		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
 							PAGE_CACHE_SHIFT;
 		if (unlikely(vmf->pgoff >= size)) {
-			mutex_unlock(&mapping->i_mmap_mutex);
+			i_mmap_unlock_read(mapping);
 			return VM_FAULT_SIGBUS;
 		}
 		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
 							xip_pfn);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_read(mapping);
 		if (err == -ENOMEM)
 			return VM_FAULT_OOM;
 		/*
@@ -290,8 +293,11 @@ found:
 		if (error != -ENODATA)
 			goto out;
 
-		/* We must recheck i_size under i_mmap_mutex */
-		mutex_lock(&mapping->i_mmap_mutex);
+		/*
+		 * We must recheck i_size under i_mmap_rwsem to prevent races
+		 * with truncation
+		 */
+		i_mmap_lock_read(mapping);
 		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
 							PAGE_CACHE_SHIFT;
 		if (unlikely(vmf->pgoff >= size)) {
@@ -309,7 +315,7 @@ found:
 
 		ret = VM_FAULT_NOPAGE;
 unlock:
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_read(mapping);
 out:
 		write_seqcount_end(&xip_sparse_seq);
 		mutex_unlock(&xip_sparse_mutex);
diff -puN mm/memory.c~mm-fix-xip-fault-vs-truncate-race-fix mm/memory.c
--- a/mm/memory.c~mm-fix-xip-fault-vs-truncate-race-fix
+++ a/mm/memory.c
@@ -1327,6 +1327,11 @@ static void unmap_single_vma(struct mmu_
 			 * safe to do nothing in this case.
 			 */
 			if (vma->vm_file) {
+				/*
+				 * Note that DAX uses i_mmap_lock to serialise
+				 * against file truncate - truncate calls into
+				 * unmap_single_vma().
+				 */
 				i_mmap_lock_write(vma->vm_file->f_mapping);
 				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
 				i_mmap_unlock_write(vma->vm_file->f_mapping);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
