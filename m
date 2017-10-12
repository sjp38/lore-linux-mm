Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF196B0069
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:04:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 32so3606239qtp.3
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 04:04:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k59si6369612qtd.227.2017.10.12.04.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 04:04:34 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9CB3q7K055196
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:04:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dj5jxv4u6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:04:33 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 12 Oct 2017 12:04:30 +0100
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9CB4Qel19857466
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:04:27 GMT
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9CB4QUo014562
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 22:04:26 +1100
Subject: Re: [RFC PATCH 2/3] mm/map_contig: Use pre-allocated pages for
 VM_CONTIG mappings
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-3-mike.kravetz@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 12 Oct 2017 16:34:22 +0530
MIME-Version: 1.0
In-Reply-To: <20171012014611.18725-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <937dd9cd-d1c7-5623-f33f-725e2db8cd83@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/12/2017 07:16 AM, Mike Kravetz wrote:
> When populating mappings backed by contiguous memory allocations
> (VM_CONTIG), use the preallocated pages instead of allocating new.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/memory.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index a728bed16c20..fbef78d07cf3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3100,7 +3100,18 @@ static int do_anonymous_page(struct vm_fault *vmf)
>  	/* Allocate our own private page. */
>  	if (unlikely(anon_vma_prepare(vma)))
>  		goto oom;
> -	page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
> +
> +	/*
> +	 * In the special VM_CONTIG case, pages have been pre-allocated. So,
> +	 * simply grab the appropriate pre-allocated page.
> +	 */
> +	if (unlikely(vma->vm_flags & VM_CONTIG)) {
> +		VM_BUG_ON(!vma->vm_private_data);
> +		page = ((struct page *)vma->vm_private_data) +
> +			((vmf->address - vma->vm_start) / PAGE_SIZE);
> +	} else {
> +		page = alloc_zeroed_user_highpage_movable(vma, vmf->address);

vm_private_data should be fine. Seems like its getting used for HugeTLB,
special mappings and for shared memory as well. As long as we dont cross
these things (lets say while enabling this for file mapping etc with
MAP_CONTIG), we can keep using vm_private_data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
