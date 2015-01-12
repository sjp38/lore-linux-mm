Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6A08D6B0070
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:38 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id t59so11047640yho.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d204si9941300yka.22.2015.01.12.15.09.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:37 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 04/20] mm: Allow page fault handlers to perform the
 COW
Message-Id: <20150112150935.e617603089bc07e68f0e657c@linux-foundation.org>
In-Reply-To: <1414185652-28663-5-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-5-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:36 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Currently COW of an XIP file is done by first bringing in a read-only
> mapping, then retrying the fault and copying the page.  It is much more
> efficient to tell the fault handler that a COW is being attempted (by
> passing in the pre-allocated page in the vm_fault structure), and allow
> the handler to perform the COW operation itself.
> 
> The handler cannot insert the page itself if there is already a read-only
> mapping at that address, so allow the handler to return VM_FAULT_LOCKED
> and set the fault_page to be NULL.  This indicates to the MM code that
> the i_mmap_mutex is held instead of the page lock.

Again, the locking gets a bit subtle.  How can we make this clearer to
readers of the core code.  I had a shot but it's a bit lame - DAX uses
i_mmap_lock for what???

If I know that, I'd know whether to have used i_mmap_lock_read() or
i_mmap_lock_write() :(


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-allow-page-fault-handlers-to-perform-the-cow-fix

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff -puN include/linux/mm.h~mm-allow-page-fault-handlers-to-perform-the-cow-fix include/linux/mm.h
diff -puN mm/memory.c~mm-allow-page-fault-handlers-to-perform-the-cow-fix mm/memory.c
--- a/mm/memory.c~mm-allow-page-fault-handlers-to-perform-the-cow-fix
+++ a/mm/memory.c
@@ -2961,7 +2961,11 @@ static int do_cow_fault(struct mm_struct
 			unlock_page(fault_page);
 			page_cache_release(fault_page);
 		} else {
-			mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+			/*
+			 * DAX doesn't have a page to lock, so it uses
+			 * i_mmap_lock()
+			 */
+			i_mmap_unlock_read(&vma->vm_file->f_mapping);
 		}
 		goto uncharge_out;
 	}
@@ -2973,7 +2977,11 @@ static int do_cow_fault(struct mm_struct
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
 	} else {
-		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+			/*
+			 * DAX doesn't have a page to lock, so it uses
+			 * i_mmap_lock()
+			 */
+			i_mmap_unlock_read(&vma->vm_file->f_mapping);
 	}
 	return ret;
 uncharge_out:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
