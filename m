Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA9852802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 15:05:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so5090582pgj.4
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 12:05:59 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v5si6185871pgb.328.2017.06.30.12.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 12:05:58 -0700 (PDT)
Date: Fri, 30 Jun 2017 13:05:56 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/5] DAX common 4k zero page
Message-ID: <20170630190556.GB27371@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed, Jun 28, 2017 at 04:01:47PM -0600, Ross Zwisler wrote:
> When servicing mmap() reads from file holes the current DAX code allocates
> a page cache page of all zeroes and places the struct page pointer in the
> mapping->page_tree radix tree.  This has three major drawbacks:
> 
> 1) It consumes memory unnecessarily.  For every 4k page that is read via a
> DAX mmap() over a hole, we allocate a new page cache page.  This means that
> if you read 1GiB worth of pages, you end up using 1GiB of zeroed memory.
> 
> 2) It is slower than using a common zero page because each page fault has
> more work to do.  Instead of just inserting a common zero page we have to
> allocate a page cache page, zero it, and then insert it.
> 
> 3) The fact that we had to check for both DAX exceptional entries and for
> page cache pages in the radix tree made the DAX code more complex.
> 
> This series solves these issues by following the lead of the DAX PMD code
> and using a common 4k zero page instead.  This reduces memory usage and
> decreases latencies for some workloads, and it simplifies the DAX code,
> removing over 100 lines in total.
> 
> Andrew, I'm still hoping to get this merged for v4.13 if possible. I I have
> addressed all of Jan's feedback, but he is on vacation for the next few
> weeks so he may not be able to give me Reviewed-by tags.  I think this
> series is relatively low risk with clear benefits, and I think we should be
> able to address any issues that come up during the v4.13 RC series.
> 
> This series has passed my targeted testing and a full xfstests run on both
> XFS and ext4.

This series has also passed the automated 0-day kernel builds in 168 configs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
