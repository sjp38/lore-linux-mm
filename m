Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 1B9D06B003B
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 10:36:39 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Sep 2013 20:06:36 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A99901258051
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:06:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GEaT2p43581668
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:06:30 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8GEaUQt007884
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:06:31 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4] hugetlbfs: support split page table lock
In-Reply-To: <1379117362-gwv3vrog-mutt-n-horiguchi@ah.jp.nec.com>
References: <1379117362-gwv3vrog-mutt-n-horiguchi@ah.jp.nec.com>
Date: Mon, 16 Sep 2013 20:06:30 +0530
Message-ID: <878uywbzpt.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Hi,
>
> Kirill posted split_ptl patchset for thp today, so in this version
> I post only hugetlbfs part. I added Kconfig variables in following
> Kirill's patches (although without CONFIG_SPLIT_*_PTLOCK_CPUS.)
>
> This patch changes many lines, but all are in hugetlbfs specific code,
> so I think we can apply this independent of thp patches.
> -----
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 13 Sep 2013 18:12:30 -0400
> Subject: [PATCH v4] hugetlbfs: support split page table lock
>
> Currently all of page table handling by hugetlbfs code are done under
> mm->page_table_lock. So when a process have many threads and they heavily
> access to the memory, lock contention happens and impacts the performance.
>
> This patch makes hugepage support split page table lock so that we use
> page->ptl of the leaf node of page table tree which is pte for normal pages
> but can be pmd and/or pud for hugepages of some architectures.
>
> ChangeLog v4:
>  - introduce arch dependent macro ARCH_ENABLE_SPLIT_HUGETLB_PTLOCK
>    (only defined for x86 for now)
>  - rename USE_SPLIT_PTLOCKS_HUGETLB to USE_SPLIT_HUGETLB_PTLOCKS

Can we have separate locking for THP and hugetlb ? Doesn't both require us to
use same locking when updating pmd ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
