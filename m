Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3677831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:42:06 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so62484641pgi.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:42:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a1si3587913pgn.347.2017.03.08.07.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:42:05 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v28FdHnf016461
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 10:42:05 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292hauu71d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 10:42:04 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 01:42:01 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v28FfpGh44368118
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 02:41:59 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v28FfPCl014058
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 02:41:26 +1100
Subject: Re: [PATCH 3/6] mm/migrate: Add copy_pages_mthread function
References: <201702172013.pEgvczPM%fengguang.wu@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 8 Mar 2017 21:10:38 +0530
MIME-Version: 1.0
In-Reply-To: <201702172013.pEgvczPM%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e35bc927-9c22-8e49-fce0-66aa2be9aaef@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 02/17/2017 05:57 PM, kbuild test robot wrote:
> Hi Zi,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.10-rc8 next-20170216]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-parallel-page-migration/20170217-200523
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/copy_pages_mthread.c: In function 'copy_pages_mthread':
>>> mm/copy_pages_mthread.c:49:10: warning: assignment discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
>      cpumask = cpumask_of_node(node);

My bad. This fixes the above warning. Will fix it up next time
around.

diff --git a/mm/copy_pages_mthread.c b/mm/copy_pages_mthread.c
index 9ad2ef6..46b22b1 100644
--- a/mm/copy_pages_mthread.c
+++ b/mm/copy_pages_mthread.c
@@ -46,7 +46,7 @@ int copy_pages_mthread(struct page *to, struct page
*from, int nr_pages)
        int cpu_id_list[32] = {0};

        node = page_to_nid(to);
-       cpumask = cpumask_of_node(node);
+       cpumask = (struct cpumask *) cpumask_of_node(node);
        cthreads = nr_copythreads;
        cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
        cthreads = (cthreads / 2) * 2;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
