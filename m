Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF16E6B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:09:56 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so13375363wma.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:09:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r3si36023261wjs.183.2016.11.24.02.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 02:09:55 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAOA9NqM073494
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:09:54 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26wvn2cjwh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:09:53 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 20:09:48 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id F2BBB2CE805D
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 21:09:45 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAOA9jgs34930774
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 21:09:45 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAOA9jp9018823
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 21:09:45 +1100
Subject: Re: [PATCH 5/5] mm: migrate: Add vm.accel_page_copy in sysfs to
 control whether to use multi-threaded to accelerate page copy.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-6-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 15:39:12 +0530
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-6-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5836BC48.1080705@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/22/2016 09:55 PM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>
> 
> Since base page migration did not gain any speedup from
> multi-threaded methods, we only accelerate the huge page case.
> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  kernel/sysctl.c | 11 +++++++++++
>  mm/migrate.c    |  6 ++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index d54ce12..6c79444 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -98,6 +98,8 @@
>  #if defined(CONFIG_SYSCTL)
> 
> 
> +extern int accel_page_copy;

Hmm, accel_mthread_copy because this is achieved by a multi threaded
copy mechanism.

> +
>  /* External variables not in a header file. */
>  extern int suid_dumpable;
>  #ifdef CONFIG_COREDUMP
> @@ -1361,6 +1363,15 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
>  	},
>  #endif
> +	{
> +		.procname	= "accel_page_copy",
> +		.data		= &accel_page_copy,
> +		.maxlen		= sizeof(accel_page_copy),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
>  	 {
>  		.procname	= "hugetlb_shm_group",
>  		.data		= &sysctl_hugetlb_shm_group,
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 244ece6..e64b490 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -48,6 +48,8 @@
> 
>  #include "internal.h"
> 
> +int accel_page_copy = 1;
> +

So its enabled by default.

>  /*
>   * migrate_prep() needs to be called before we start compiling a list of pages
>   * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
> @@ -651,6 +653,10 @@ static void copy_huge_page(struct page *dst, struct page *src,
>  		nr_pages = hpage_nr_pages(src);
>  	}
> 
> +	/* Try to accelerate page migration if it is not specified in mode  */
> +	if (accel_page_copy)
> +		mode |= MIGRATE_MT;

So even if none of the system calls requested for a multi threaded copy,
this setting will override every thing and make it multi threaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
