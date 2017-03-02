Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 391EE6B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:52:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 10so10340478pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:52:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a21si7621407pgi.248.2017.03.02.06.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:52:00 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22Eo8Gl098776
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 09:52:00 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xjama05c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:51:59 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Mar 2017 20:21:56 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 156D9125804F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 20:22:07 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v22EomZL17956888
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:20:48 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v22Eprl4000922
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:21:54 +0530
Subject: Re: [RFC 04/11] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-5-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 20:21:46 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <65fd1dd1-7ca4-6610-285c-09436879d8ed@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> If the page is mapped and rescue in ttuo, page_mapcount(page) == 0 cannot

Nit: "ttuo" is very cryptic. Please expand it.

> be true so page_mapcount check in ttu is enough to return SWAP_SUCCESS.
> IOW, SWAP_MLOCK check is redundant so remove it.

Right, page_mapcount(page) should be enough to tell whether swapping
out happened successfully or the page is still mapped in some page
table.

> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 3a14013..0a48958 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1523,7 +1523,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  	else
>  		ret = rmap_walk(page, &rwc);
>  
> -	if (ret != SWAP_MLOCK && !page_mapcount(page))
> +	if (!page_mapcount(page))
>  		ret = SWAP_SUCCESS;
>  	return ret;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
