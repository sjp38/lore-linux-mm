Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40731280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:18:41 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id d187so628622075ywe.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:18:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g15si4420280ybf.127.2016.11.21.00.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 00:18:40 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAL8E9aR009714
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:18:40 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26tjxkwn1f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:18:39 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 18:18:37 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E26223578052
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:18:34 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAL8IYwn28639242
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:18:34 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAL8IYeY022113
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:18:34 +1100
Subject: Re: [HMM v13 03/18] mm/ZONE_DEVICE/free_hot_cold_page: catch
 ZONE_DEVICE pages
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-4-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 13:48:26 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-4-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832ADD2.5000507@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
> happen as ZONE_DEVICE page must always have an elevated refcount.
> 
> This is to catch refcounting issues in a sane way for ZONE_DEVICE pages.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  mm/page_alloc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0fbfead..09b2630 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2435,6 +2435,16 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> +	/*
> +	 * This should never happen ! Page from ZONE_DEVICE always must have an
> +	 * active refcount. Complain about it and try to restore the refcount.
> +	 */
> +	if (is_zone_device_page(page)) {
> +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
> +		page_ref_inc(page);
> +		return;
> +	}

This fixes an issue in the existing ZONE_DEVICE code, should not this
patch be sent separately not in this series ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
