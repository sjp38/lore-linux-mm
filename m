Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id B7E516B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 16:43:54 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so4061934qgd.5
        for <linux-mm@kvack.org>; Wed, 21 May 2014 13:43:54 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id n55si36702733yhh.89.2014.05.21.13.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 May 2014 13:43:54 -0700 (PDT)
Message-ID: <1400704507.18128.23.camel@misato.fc.hp.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the
 DAX page fault handler
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 21 May 2014 14:35:07 -0600
In-Reply-To: <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
	 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun, 2014-03-23 at 15:08 -0400, Matthew Wilcox wrote:
 :
> +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
 :
> +	error = dax_get_pfn(inode, &bh, &pfn);
> +	if (error > 0)
> +		error = vm_insert_mixed(vma, vaddr, pfn);
> +	mutex_unlock(&mapping->i_mmap_mutex);
> +
> +	if (page) {
> +		delete_from_page_cache(page);
> +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> +							PAGE_CACHE_SIZE, 0);
> +		unlock_page(page);
> +		page_cache_release(page);

Hi Matthew,

I am seeing a problem in this code path, where it deletes a page cache
page mapped to a hole. Sometimes, page->_mapcount is 0, not -1, which
leads __delete_from_page_cache(), called from delete_from_page_cache(),
to hit the following BUG_ON.

  BUG_ON(page_mapped(page))

I suppose such page has a shared mapping. Does this code need to take
care of replacing shared mappings in such case?

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
