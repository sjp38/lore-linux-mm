Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF036B000A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:40:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e26-v6so1909359wmh.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:40:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w35-v6si538359edw.206.2018.05.23.01.40.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 01:40:31 -0700 (PDT)
Date: Wed, 23 May 2018 10:40:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/11] filesystem-dax: set page->index
Message-ID: <20180523084030.dvv4jbvsnzrsaz6q@quack2.suse.cz>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152699999778.24093.18007971664703285330.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152699999778.24093.18007971664703285330.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tony.luck@intel.com, linux-xfs@vger.kernel.org

On Tue 22-05-18 07:39:57, Dan Williams wrote:
> In support of enabling memory_failure() handling for filesystem-dax
> mappings, set ->index to the pgoff of the page. The rmap implementation
> requires ->index to bound the search through the vma interval tree. The
> index is set and cleared at dax_associate_entry() and
> dax_disassociate_entry() time respectively.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/dax.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index aaec72ded1b6..2e4682cd7c69 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -319,18 +319,22 @@ static unsigned long dax_radix_end_pfn(void *entry)
>  	for (pfn = dax_radix_pfn(entry); \
>  			pfn < dax_radix_end_pfn(entry); pfn++)
>  
> -static void dax_associate_entry(void *entry, struct address_space *mapping)
> +static void dax_associate_entry(void *entry, struct address_space *mapping,
> +		struct vm_area_struct *vma, unsigned long address)
>  {
> -	unsigned long pfn;
> +	unsigned long size = dax_entry_size(entry), pfn, index;
> +	int i = 0;
>  
>  	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
>  		return;
>  
> +	index = linear_page_index(vma, address & ~(size - 1));
>  	for_each_mapped_pfn(entry, pfn) {
>  		struct page *page = pfn_to_page(pfn);
>  
>  		WARN_ON_ONCE(page->mapping);
>  		page->mapping = mapping;
> +		page->index = index + i++;
>  	}
>  }

Hum, this just made me think: How is this going to work with XFS reflink?
In fact is not the page->mapping association already broken by XFS reflink?
Because with reflink we can have two or more mappings pointing to the same
physical blocks (i.e., pages in DAX case)...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
