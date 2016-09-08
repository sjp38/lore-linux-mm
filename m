Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 560826B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:00:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l65so30993969wmf.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:00:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l11si7740872wmg.37.2016.09.08.02.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 02:00:36 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u888wZgF042107
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 05:00:35 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25ataxxe53-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 05:00:35 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 19:00:32 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id ADB392CE8057
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 19:00:29 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8890TNj42270790
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 19:00:29 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8890ThF009711
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 19:00:29 +1000
Date: Thu, 08 Sep 2016 14:30:25 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 07/10] mm, THP, swap: Support to add/delete THP to/from
 swap cache
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-8-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-8-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D128A9.3030306@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 09/07/2016 10:16 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> With this patch, a THP (Transparent Huge Page) can be added/deleted
> to/from the swap cache as a set of sub-pages (512 on x86_64).
> 
> This will be used for the THP (Transparent Huge Page) swap support.
> Where one THP may be added/delted to/from the swap cache.  This will
> batch the swap cache operations to reduce the lock acquire/release times
> for the THP swap too.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  include/linux/page-flags.h |  2 +-
>  mm/swap_state.c            | 57 +++++++++++++++++++++++++++++++---------------
>  2 files changed, 40 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74e4dda..f5bcbea 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -314,7 +314,7 @@ PAGEFLAG_FALSE(HighMem)
>  #endif
>  
>  #ifdef CONFIG_SWAP
> -PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
> +PAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)

What is the reason for this change ? The commit message does not seem
to explain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
