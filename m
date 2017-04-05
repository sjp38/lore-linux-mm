Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8DDA6B03A7
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 06:35:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u18so1003906wrc.17
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 03:35:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y206si23849638wmb.31.2017.04.05.03.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 03:35:31 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35ATWQD000573
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 06:35:30 -0400
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29mvr468ge-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:35:29 -0400
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 16:05:26 +0530
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v35AY53I13434926
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 16:04:05 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v35AZOpb019502
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 16:05:24 +0530
Subject: Re: [PATCH] mm, memory_hotplug: fix devm_memremap_pages() after
 memory_hotplug rework
References: <20170404165144.29791-1-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 5 Apr 2017 16:05:23 +0530
MIME-Version: 1.0
In-Reply-To: <20170404165144.29791-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <a9d6e8d2-7bd9-abf1-9323-d175f10f7559@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>

On 04/04/2017 10:21 PM, JA(C)rA'me Glisse wrote:
> Just a trivial fix.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  kernel/memremap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index faa9276..bbbe646 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -366,7 +366,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	error = arch_add_memory(nid, align_start, align_size);
>  	if (!error)
>  		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> -				align_start, align_size);
> +					align_start >> PAGE_SHIFT,
> +					align_size >> PAGE_SHIFT);

All this while it was taking up addresses instead of PFNs ? Then
how it was working correctly before ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
