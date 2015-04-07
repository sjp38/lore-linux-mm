Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA9B6B0073
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 10:13:22 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so46645213wgy.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:13:22 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id hn4si12947850wjc.167.2015.04.07.07.13.20
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 07:13:20 -0700 (PDT)
Date: Tue, 7 Apr 2015 17:12:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3 v7] mm(v4.1): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
Message-ID: <20150407141245.GC14252@node.dhcp.inet.fi>
References: <55239645.9000507@plexistor.com>
 <552397E6.5030506@plexistor.com>
 <5523E453.8080101@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5523E453.8080101@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On Tue, Apr 07, 2015 at 05:06:11PM +0300, Boaz Harrosh wrote:
> 
> [v5]
> Changed comments about pte_same check after the call to
> pfn_mkwrite and the return value.
> 
> [v4]
> Kirill's comments about splitting out a new wp_pfn_shared().
> Add Documentation/filesystems/Locking text about pfn_mkwrite.
> 
> [v3]
> Kirill's comments about use of linear_page_index()
> 
> [v2]
> Based on linux-next/akpm [3dc4623]. For v4.1 merge window
> Incorporated comments from Andrew And Kirill
> 
> [v1]
> This will allow FS that uses VM_PFNMAP | VM_MIXEDMAP (no page structs)
> to get notified when access is a write to a read-only PFN.
> 
> This can happen if we mmap() a file then first mmap-read from it
> to page-in a read-only PFN, than we mmap-write to the same page.
> 
> We need this functionality to fix a DAX bug, where in the scenario
> above we fail to set ctime/mtime though we modified the file.
> An xfstest is attached to this patchset that shows the failure
> and the fix. (A DAX patch will follow)
> 
> This functionality is extra important for us, because upon
> dirtying of a pmem page we also want to RDMA the page to a
> remote cluster node.
> 
> We define a new pfn_mkwrite and do not reuse page_mkwrite because
>   1 - The name ;-)
>   2 - But mainly because it would take a very long and tedious
>       audit of all page_mkwrite functions of VM_MIXEDMAP/VM_PFNMAP
>       users. To make sure they do not now CRASH. For example current
>       DAX code (which this is for) would crash.
>       If we would want to reuse page_mkwrite, We will need to first
>       patch all users, so to not-crash-on-no-page. Then enable this
>       patch. But even if I did that I would not sleep so well at night.
>       Adding a new vector is the safest thing to do, and is not that
>       expensive. an extra pointer at a static function vector per driver.
>       Also the new vector is better for performance, because else we
>       Will call all current Kernel vectors, so to:
> 	check-ha-no-page-do-nothing and return.
> 
> No need to call it from do_shared_fault because do_wp_page is called to
> change pte permissions anyway.
> 
> CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> CC: Jan Kara <jack@suse.cz>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Hugh Dickins <hughd@google.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: linux-mm@kvack.org
> 
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
