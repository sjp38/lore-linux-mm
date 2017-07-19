Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 394F86B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:33:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 79so261614wmr.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 08:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 128si116611wmz.192.2017.07.19.08.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 08:33:17 -0700 (PDT)
Date: Wed, 19 Jul 2017 17:33:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 3/5] dax: use common 4k zero page for dax mmap reads
Message-ID: <20170719153314.GC15908@quack2.suse.cz>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
 <20170628220152.28161-4-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628220152.28161-4-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 28-06-17 16:01:50, Ross Zwisler wrote:
> Another major change is that we remove dax_pfn_mkwrite() from our fault
> flow, and instead rely on the page fault itself to make the PTE dirty and
> writeable.  The following description from the patch adding the
> vm_insert_mixed_mkwrite() call explains this a little more:
> 
> ***
>   To be able to use the common 4k zero page in DAX we need to have our PTE
>   fault path look more like our PMD fault path where a PTE entry can be
>   marked as dirty and writeable as it is first inserted, rather than
>   waiting for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> 
>   Right now we can rely on having a dax_pfn_mkwrite() call because we can
>   distinguish between these two cases in do_wp_page():
> 
>   	case 1: 4k zero page => writable DAX storage
>   	case 2: read-only DAX storage => writeable DAX storage
> 
>   This distinction is made by via vm_normal_page().  vm_normal_page()
>   returns false for the common 4k zero page, though, just as it does for
>   DAX ptes.  Instead of special casing the DAX + 4k zero page case, we will
>   simplify our DAX PTE page fault sequence so that it matches our DAX PMD
>   sequence, and get rid of dax_pfn_mkwrite() completely.
> 
>   This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
>   and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set
>   insert_pfn() will do the work that was previously done by wp_page_reuse()
>   as part of the dax_pfn_mkwrite() call path.
> ***

Hum, thinking about this in context of this patch... So what if we have
allocated storage, a process faults it read-only, we map it to page tables
writeprotected. Then the process writes through mmap to the area - the code
in handle_pte_fault() ends up in do_wp_page() if I'm reading it right.
Then, since we are missing ->pfn_mkwrite() handlers, the PTE will be marked
writeable but radix tree entry stays clean - bug. Am I missing something?

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
