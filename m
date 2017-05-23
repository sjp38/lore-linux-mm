Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 242AB6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 09:07:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id t75so19204274lfe.14
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:07:48 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id y26si7461225lja.138.2017.05.23.06.07.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 06:07:46 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id h4so8041819lfj.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:07:45 -0700 (PDT)
Date: Tue, 23 May 2017 16:07:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] Patch for remapping pages around the fault page
Message-ID: <20170523130743.3oh3rlxwqg2odimg@node.shutemov.name>
References: <rppt@linux.vnet.ibm.com>
 <1495379520-23752-1-git-send-email-sarunya@vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495379520-23752-1-git-send-email-sarunya@vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarunya Pumma <sarunya@vt.edu>
Cc: rppt@linux.vnet.ibm.com, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com

On Sun, May 21, 2017 at 11:12:00AM -0400, Sarunya Pumma wrote:
> After the fault handler performs the __do_fault function to read a fault
> page when a page fault occurs, it does not map other pages that have been
> read together with the fault page. This can cause a number of minor page
> faults to be large. Therefore, this patch is developed to remap pages
> around the fault page by aiming to map the pages that have been read
> synchronously or asynchronously with the fault page.
> 
> The major function of this patch is the redo_fault_around function. This
> function computes the start and end offsets of the pages to be mapped,
> determines whether to do the page remapping, remaps pages using the
> map_pages function, and returns. In the redo_fault_around function, the
> start and end offsets are computed the same way as the do_fault_around
> function. To determine whether to do the remapping, we determine if the
> pages around the fault page are already mapped. If they are, the remapping
> will not be performed.
> 
> As checking every page can be inefficient if a number of pages to be mapped
> is large, we have added a threshold called "vm_nr_rempping" to consider
> whether to check the status of every page around the fault page or just
> some pages. Note that the vm_nr_rempping parameter can be adjusted via the
> Sysctl interface. In the case that a number of pages to be mapped is
> smaller than the vm_nr_rempping threshold, we check all pages around the
> fault page (within the start and end offsets). Otherwise, we check only the
> adjacent pages (left and right).
> 
> The page remapping is beneficial when performing the "almost sequential"
> page accesses, where pages are accessed in order but some pages are
> skipped.
> 
> The following is one example scenario that we can reduce one page fault
> every 16 page:
> 
> Assume that we want to access pages sequentially and skip every page that
> marked as PG_readahead. Assume that the read-ahead size is 32 pages and the
> number of pages to be mapped each time (fault_around_pages) is 16.
> 
> When accessing a page at offset 0, a major page fault occurs, so pages from
> page 0 to page 31 is read from the disk to the page cache. With this, page
> 24 is marked as a read-ahead page (PG_readahead). Then only page 0 is
> mapped to the virtual memory space.
> 
> When accessing a page at offset 1, a minor page fault occurs, pages from
> page 0 to page 15 will be mapped.
> 
> We keep accessing pages until page 31. Note that we skip page 24.
> 
> When accessing a page at offset 32, a major page fault occurs.  The same
> process will be repeated. The other 32 pages will be read from the disk.
> Only page 32 is mapped. Then a minor page fault at the next page (page
> 33) will occur.
> 
> From this example, two page faults occur every 16 page. With this patch, we
> can eliminate the minor page fault in every 16 page.
> 
> Thank you very much for your time for reviewing the patch.
> 
> Signed-off-by: Sarunya Pumma <sarunya@vt.edu>

Still no performance numbers?

I doubt it's useful. You woundn't get "a number of minor page faults".
The first minor page fault would take faultaround path and map these
pages.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
