Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE15F6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 01:04:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p74so72304518pfd.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 22:04:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e12si22157796pfb.265.2017.06.01.22.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 22:04:49 -0700 (PDT)
Date: Thu, 1 Jun 2017 23:04:47 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2] Patch for remapping pages around the fault page
Message-ID: <20170602050447.GA5909@linux.intel.com>
References: <201705230125.i1Cthtdz%fengguang.wu@intel.com>
 <1496354509-29061-1-git-send-email-sarunya@vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496354509-29061-1-git-send-email-sarunya@vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarunya Pumma <sarunya@vt.edu>
Cc: kbuild-all@01.org, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com

On Thu, Jun 01, 2017 at 06:01:49PM -0400, Sarunya Pumma wrote:
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

Please consider Kirill's feedback:

http://www.spinics.net/lists/linux-mm/msg127597.html

Really the only reason to consider this extra complexity would be if it
provided a performance benefit.  So, the onus is on the patch author to show
that the performance benefit is worth the code.

Also, it's helpful to reviewers to explicit enumerate the differences between 
different patch versions.  If you have a cover letter that's a great place to
do this, or if you have a short series without a cover letter you can do it
below a --- section break like this:

https://patchwork.kernel.org/patch/9741461/

The extra text below the section break will be stripped off by git am when the
patch is applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
