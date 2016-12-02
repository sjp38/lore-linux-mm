Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 179A16B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 10:43:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so3798183wme.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:43:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l6si5766687wje.169.2016.12.02.07.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 07:43:31 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB2FZH0X088192
	for <linux-mm@kvack.org>; Fri, 2 Dec 2016 10:43:29 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2737w961vm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Dec 2016 10:43:29 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 2 Dec 2016 08:43:27 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v3)
In-Reply-To: <20161129201703.CE9D5054@viggo.jf.intel.com>
References: <20161129201703.CE9D5054@viggo.jf.intel.com>
Date: Fri, 02 Dec 2016 21:13:19 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877f7ie3qg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, vbabka@suse.cz, linux-mm@kvack.org, linux-arch@vger.kernel.org

Dave Hansen <dave@sr71.net> writes:

> Andrew, you can drop proc-mm-export-pte-sizes-directly-in-smaps-v2.patch,
> and replace it with this.
>
.....

> diff -puN mm/hugetlb.c~smaps-pte-sizes mm/hugetlb.c
> --- a/mm/hugetlb.c~smaps-pte-sizes	2016-11-28 14:21:37.555519365 -0800
> +++ b/mm/hugetlb.c	2016-11-28 14:28:49.186234688 -0800
> @@ -2763,6 +2763,17 @@ void __init hugetlb_add_hstate(unsigned
>  					huge_page_size(h)/1024);
>  
>  	parsed_hstate = h;
> +
> +	/*
> +	 * PGD_SIZE isn't widely made available by architecures,
> +	 * so use PUD_SIZE*PTRS_PER_PUD as a substitute.
> +	 *
> +	 * Check for sizes that might be mapped by a PGD.  There
> +	 * are none of these known today, but be on the lookout.
> +	 * If this trips, we will need to update the mss->rss_*
> +	 * code in fs/proc/task_mmu.c.
> +	 */
> +	WARN_ON_ONCE((PAGE_SIZE << order) >= PUD_SIZE * PTRS_PER_PUD);
>  }

This will trip for ppc64 16GB hugepage.

For ppc64 we have the 16G at pgd level.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
