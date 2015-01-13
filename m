Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id AFCEB6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:58:32 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so2357097yha.7
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 10:58:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t26si11181369yhg.207.2015.01.13.10.58.31
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 10:58:31 -0800 (PST)
Date: Tue, 13 Jan 2015 13:58:23 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 04/20] mm: Allow page fault handlers to perform the
 COW
Message-ID: <20150113185823.GH5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-5-git-send-email-matthew.r.wilcox@intel.com>
 <20150112150935.e617603089bc07e68f0e657c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112150935.e617603089bc07e68f0e657c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Mon, Jan 12, 2015 at 03:09:35PM -0800, Andrew Morton wrote:
> On Fri, 24 Oct 2014 17:20:36 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> > Currently COW of an XIP file is done by first bringing in a read-only
> > mapping, then retrying the fault and copying the page.  It is much more
> > efficient to tell the fault handler that a COW is being attempted (by
> > passing in the pre-allocated page in the vm_fault structure), and allow
> > the handler to perform the COW operation itself.
> > 
> > The handler cannot insert the page itself if there is already a read-only
> > mapping at that address, so allow the handler to return VM_FAULT_LOCKED
> > and set the fault_page to be NULL.  This indicates to the MM code that
> > the i_mmap_mutex is held instead of the page lock.
> 
> Again, the locking gets a bit subtle.  How can we make this clearer to
> readers of the core code.  I had a shot but it's a bit lame - DAX uses
> i_mmap_lock for what???

It's not just DAX ... any fault handler that wants to optimise its COW
can use the same technique.  I could turn this around and ask the mm
people why it is the struct page has to be returned locked; what is it
protecting against?

I'm pretty sure the answer is only truncate, and so (as with the previous
patch), the read lock is perfectly appropriate.

> If I know that, I'd know whether to have used i_mmap_lock_read() or
> i_mmap_lock_write() :(
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-allow-page-fault-handlers-to-perform-the-cow-fix
> 
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff -puN include/linux/mm.h~mm-allow-page-fault-handlers-to-perform-the-cow-fix include/linux/mm.h
> diff -puN mm/memory.c~mm-allow-page-fault-handlers-to-perform-the-cow-fix mm/memory.c
> --- a/mm/memory.c~mm-allow-page-fault-handlers-to-perform-the-cow-fix
> +++ a/mm/memory.c
> @@ -2961,7 +2961,11 @@ static int do_cow_fault(struct mm_struct
>  			unlock_page(fault_page);
>  			page_cache_release(fault_page);
>  		} else {
> -			mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +			/*
> +			 * DAX doesn't have a page to lock, so it uses
> +			 * i_mmap_lock()
> +			 */
> +			i_mmap_unlock_read(&vma->vm_file->f_mapping);

How about:
			/*
			 * The fault handler has no page to lock, so it
			 * holds i_mmap_lock for read to protect against
			 * truncate.
			 */

>  		}
>  		goto uncharge_out;
>  	}
> @@ -2973,7 +2977,11 @@ static int do_cow_fault(struct mm_struct
>  		unlock_page(fault_page);
>  		page_cache_release(fault_page);
>  	} else {
> -		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +			/*
> +			 * DAX doesn't have a page to lock, so it uses
> +			 * i_mmap_lock()
> +			 */
> +			i_mmap_unlock_read(&vma->vm_file->f_mapping);

(as Jan already pointed out, the indentation needs to be fixed here anyway)

>  	}
>  	return ret;
>  uncharge_out:
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
