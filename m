Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA8A6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:47:10 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b202so652740880oii.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:47:10 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50062.outbound.protection.outlook.com. [40.107.5.62])
        by mx.google.com with ESMTPS id p18si11473011oic.16.2016.12.07.00.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:47:09 -0800 (PST)
Date: Wed, 7 Dec 2016 16:46:56 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161207084653.GA4846@sha-win-210.asiapac.arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161205093100.GF30758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will
 Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Mon, Dec 05, 2016 at 05:31:01PM +0800, Michal Hocko wrote:
> On Mon 05-12-16 17:17:07, Huang Shijie wrote:
> [...]
> >    The failure is caused by:
> >     1) kernel fails to allocate a gigantic page for the surplus case.
> >        And the gather_surplus_pages() will return NULL in the end.
> > 
> >     2) The condition checks for some functions are wrong:
> >         return_unused_surplus_pages()
> >         nr_overcommit_hugepages_store()
> >         hugetlb_overcommit_handler()
> 
> OK, so how is this any different from gigantic (1G) hugetlb pages on
> x86_64? Do we need the same functionality or is it just 32MB not being
> handled in the same way as 1G?
I tested this patch set on the Softiron board(ARM64) which has 16G memory.
I appended "hugepagesz=1G hugepages=6" in the kernel cmdline, the arm64
will use the PUD_SIZE for the hugetlb page.

The 1G page size can run well, I post the log here:

--------------------------------------------------------
	counters.sh (1024M: 64):        PASS
	********** TEST SUMMARY
	*                      1024M         
	*                      32-bit 64-bit 
	*     Total testcases:     0      1   
	*             Skipped:     0      0   
	*                PASS:     0      1   
	*                FAIL:     0      0   
	*    Killed by signal:     0      0   
	*   Bad configuration:     0      0   
	*       Expected FAIL:     0      0   
	*     Unexpected PASS:     0      0   
	* Strange test result:     0      0   
	**********
--------------------------------------------------------

My desktop is x86_64, but its memory is just 8G.
I will expand its memory capacity, and continue to
the test for x86_64. 

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
