Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D70D6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 17:39:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j3so7063566wrb.18
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 14:39:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i4si5218859wri.345.2018.03.02.14.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 14:39:50 -0800 (PST)
Date: Fri, 2 Mar 2018 14:39:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/3] mm, hugetlbfs: introduce ->pagesize() to
 vm_operations_struct
Message-Id: <20180302143947.ed00df85530df46ec98dbd3e@linux-foundation.org>
In-Reply-To: <151996254734.27922.15813097401404359642.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
	<151996254734.27922.15813097401404359642.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, 01 Mar 2018 19:49:07 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> When device-dax is operating in huge-page mode we want it to behave like
> hugetlbfs and report the MMU page mapping size that is being enforced by
> the vma. Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce
> ->split() to vm_operations_struct" it would be messy to teach
> vma_mmu_pagesize() about device-dax page mapping sizes in the same
> (hstate) way that hugetlbfs communicates this attribute.  Instead, these
> patches introduce a new ->pagesize() vm operation.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -383,6 +383,7 @@ struct vm_operations_struct {
>  	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
>  	void (*map_pages)(struct vm_fault *vmf,
>  			pgoff_t start_pgoff, pgoff_t end_pgoff);
> +	unsigned long (*pagesize)(struct vm_area_struct * area);

fwiw, vm_operations_struct is documented in
Documentation/filesystems/Locking.  Some bitrotting has occurred :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
