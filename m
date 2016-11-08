Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFC8B6B0069
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 14:27:50 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so54056606pfg.0
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:27:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ug9si31912396pab.228.2016.11.08.11.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 11:27:49 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA8JNftY055312
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 14:27:49 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26kfmnnbc4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Nov 2016 14:27:48 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 8 Nov 2016 19:27:47 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1FD821B08061
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 19:29:57 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA8JRiTr14156080
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 19:27:44 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA8JRiKH003261
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 12:27:44 -0700
Date: Tue, 8 Nov 2016 20:27:42 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 2/2] mm: hugetlb: support gigantic surplus pages
In-Reply-To: <20161108091725.GA18678@sha-win-210.asiapac.arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
	<1478141499-13825-3-git-send-email-shijie.huang@arm.com>
	<20161107162504.17591806@thinkpad>
	<20161108021929.GA982@sha-win-210.asiapac.arm.com>
	<20161108070851.GA15044@sha-win-210.asiapac.arm.com>
	<20161108091725.GA18678@sha-win-210.asiapac.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20161108202742.57ed120d@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, 8 Nov 2016 17:17:28 +0800
Huang Shijie <shijie.huang@arm.com> wrote:

> > I will look at the lockdep issue.
> I tested the new patch (will be sent out later) on the arm64 platform,
> and I did not meet the lockdep issue when I enabled the lockdep.
> The following is my config:
> 
> 	CONFIG_LOCKD=y
> 	CONFIG_LOCKD_V4=y
> 	CONFIG_LOCKUP_DETECTOR=y
>         # CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
> 	CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
> 	CONFIG_DEBUG_SPINLOCK=y
> 	CONFIG_DEBUG_LOCK_ALLOC=y
> 	CONFIG_PROVE_LOCKING=y
> 	CONFIG_LOCKDEP=y
> 	CONFIG_LOCK_STAT=y
> 	CONFIG_DEBUG_LOCKDEP=y
> 	CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
> 	
> So do I miss something? 

Those options should be OK. Meanwhile I looked into this a little more,
and the problematic line/lock is spin_lock_irqsave(&z->lock, flags) at
the top of alloc_gigantic_page(). From the lockdep trace we see that
it is triggered by an mmap(), and then hugetlb_acct_memory() ->
__alloc_huge_page() -> alloc_gigantic_page().

However, in between those functions (inside gather_surplus_pages())
a NUMA_NO_NODE node id comes into play. And this finally results in
alloc_gigantic_page() being called with NUMA_NO_NODE as nid (which is
-1), and NODE_DATA(nid)->node_zones will then reach into Nirvana.

So, I guess the problem is a missing NUMA_NO_NODE check in
alloc_gigantic_page(), similar to the one in
__hugetlb_alloc_buddy_huge_page(). And somehow this was not a problem
before the gigantic surplus change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
