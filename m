Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEFF6B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:10:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z99so236734wrc.15
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 00:10:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k71si8253809wmi.254.2017.10.18.00.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 00:10:53 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9I79cg7076104
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:10:51 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dnsxujh80-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:10:51 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 18 Oct 2017 08:10:50 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9I7Aket28639340
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:10:48 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9I7AkgF022734
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:10:46 +1100
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
References: <20171018063123.21983-1-bsingharora@gmail.com>
 <20171018063123.21983-2-bsingharora@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 18 Oct 2017 12:40:43 +0530
MIME-Version: 1.0
In-Reply-To: <20171018063123.21983-2-bsingharora@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d33c5a32-2b1a-85c7-be68-d006517b1ecd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, jglisse@redhat.com
Cc: linux-mm@kvack.org, mhocko@suse.com

On 10/18/2017 12:01 PM, Balbir Singh wrote:
> With HMM, we can have either public or private zone
> device pages. With private zone device pages, they should
> show up as swapped entities. For public zone device pages

Might be missing something here but why they should show up
as swapped entities ? Could you please elaborate.

> the smaps output can be confusing and incomplete.
> 
> This patch adds a new attribute to just smaps to show
> device memory usage.

If we are any way adding a new entry here then why not one
more for private device memory pages as well. Just being
curious.

> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> ---
>  fs/proc/task_mmu.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 9f1e2b2b5f5a..b7f32f42ee93 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -451,6 +451,7 @@ struct mem_size_stats {
>  	unsigned long shared_hugetlb;
>  	unsigned long private_hugetlb;
>  	unsigned long first_vma_start;
> +	unsigned long device_memory;
>  	u64 pss;
>  	u64 pss_locked;
>  	u64 swap_pss;
> @@ -463,12 +464,22 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  	int i, nr = compound ? 1 << compound_order(page) : 1;
>  	unsigned long size = nr * PAGE_SIZE;
>  
> +	/*
> +	 * We don't want to process public zone device pages further
> +	 * than just showing how much device memory we have
> +	 */
> +	if (is_zone_device_page(page)) {

Should not this contain both public and private device pages.

> +		mss->device_memory += size;
> +		return;
> +	}
> +
>  	if (PageAnon(page)) {
>  		mss->anonymous += size;
>  		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
>  			mss->lazyfree += size;
>  	}
>  
> +

Stray new line.

>  	mss->resident += size;
>  	/* Accumulate the size in pages that have been accessed. */
>  	if (young || page_is_young(page) || PageReferenced(page))
> @@ -833,7 +844,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  			   "Private_Hugetlb: %7lu kB\n"
>  			   "Swap:           %8lu kB\n"
>  			   "SwapPss:        %8lu kB\n"
> -			   "Locked:         %8lu kB\n",
> +			   "Locked:         %8lu kB\n"

Stray changed line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
