Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06E2D6B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:36:04 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id p18-v6so3202714ybe.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:36:04 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g190-v6si397598ywb.196.2018.10.03.09.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Oct 2018 09:36:03 -0700 (PDT)
Date: Wed, 3 Oct 2018 12:35:58 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] mm: Fix warning in insert_pfn()
Message-ID: <20181003163557.GA18434@thunk.org>
References: <20180824154542.26872-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824154542.26872-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Dave Jiang <dave.jiang@intel.com>

On Fri, Aug 24, 2018 at 05:45:42PM +0200, Jan Kara wrote:
> In DAX mode a write pagefault can race with write(2) in the following
> way:
> 
> CPU0                            CPU1
>                                 write fault for mapped zero page (hole)
> dax_iomap_rw()
>   iomap_apply()
>     xfs_file_iomap_begin()
>       - allocates blocks
>     dax_iomap_actor()
>       invalidate_inode_pages2_range()
>         - invalidates radix tree entries in given range
>                                 dax_iomap_pte_fault()
>                                   grab_mapping_entry()
>                                     - no entry found, creates empty
>                                   ...
>                                   xfs_file_iomap_begin()
>                                     - finds already allocated block
>                                   ...
>                                   vmf_insert_mixed_mkwrite()
>                                     - WARNs and does nothing because there
>                                       is still zero page mapped in PTE
>         unmap_mapping_pages()
> 
> This race results in WARN_ON from insert_pfn() and is occasionally
> triggered by fstest generic/344. Note that the race is otherwise
> harmless as before write(2) on CPU0 is finished, we will invalidate page
> tables properly and thus user of mmap will see modified data from
> write(2) from that point on. So just restrict the warning only to the
> case when the PFN in PTE is not zero page.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

I don't see this in linux-next.  What's the status of this patch?

Thanks,

					- Ted
