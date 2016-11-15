Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A58256B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 19:25:31 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id rf5so101886929pab.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 16:25:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m24si24210350pfg.258.2016.11.14.16.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 16:25:30 -0800 (PST)
Date: Mon, 14 Nov 2016 16:25:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: disable numa migration faults for dax vmas
Message-Id: <20161114162529.1a5b08ff90f6f199c1be8cc9@linux-foundation.org>
In-Reply-To: <147892450132.22062.16875659431109209179.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147892450132.22062.16875659431109209179.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@ml01.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, 11 Nov 2016 20:21:41 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Mark dax vmas as not migratable to exclude them from task_numa_work().
> This is especially relevant for device-dax which wants to ensure
> predictable access latency and not incur periodic faults.
>
> ...
>
> @@ -177,6 +178,9 @@ static inline bool vma_migratable(struct vm_area_struct *vma)
>  	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>  		return false;
>  
> +	if (vma_is_dax(vma))
> +		return false;
> +
>  #ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	if (vma->vm_flags & VM_HUGETLB)
>  		return false;

I don't think the reader could figure out why this code is here, so...  this?

--- a/include/linux/mempolicy.h~mm-disable-numa-migration-faults-for-dax-vmas-fix
+++ a/include/linux/mempolicy.h
@@ -180,6 +180,10 @@ static inline bool vma_migratable(struct
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		return false;
 
+	/*
+	 * DAX device mappings require predictable access latency, so avoid
+	 * incurring periodic faults.
+	 */
 	if (vma_is_dax(vma))
 		return false;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
