Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 961386B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 17:38:02 -0400 (EDT)
Date: Mon, 16 Sep 2013 17:37:40 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1379367460-zt1iacf9-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <878uywbzpt.fsf@linux.vnet.ibm.com>
References: <1379117362-gwv3vrog-mutt-n-horiguchi@ah.jp.nec.com>
 <878uywbzpt.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH v4] hugetlbfs: support split page table lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Mon, Sep 16, 2013 at 08:06:30PM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > Hi,
> >
> > Kirill posted split_ptl patchset for thp today, so in this version
> > I post only hugetlbfs part. I added Kconfig variables in following
> > Kirill's patches (although without CONFIG_SPLIT_*_PTLOCK_CPUS.)
> >
> > This patch changes many lines, but all are in hugetlbfs specific code,
> > so I think we can apply this independent of thp patches.
> > -----
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Fri, 13 Sep 2013 18:12:30 -0400
> > Subject: [PATCH v4] hugetlbfs: support split page table lock
> >
> > Currently all of page table handling by hugetlbfs code are done under
> > mm->page_table_lock. So when a process have many threads and they heavily
> > access to the memory, lock contention happens and impacts the performance.
> >
> > This patch makes hugepage support split page table lock so that we use
> > page->ptl of the leaf node of page table tree which is pte for normal pages
> > but can be pmd and/or pud for hugepages of some architectures.
> >
> > ChangeLog v4:
> >  - introduce arch dependent macro ARCH_ENABLE_SPLIT_HUGETLB_PTLOCK
> >    (only defined for x86 for now)
> >  - rename USE_SPLIT_PTLOCKS_HUGETLB to USE_SPLIT_HUGETLB_PTLOCKS
> 
> Can we have separate locking for THP and hugetlb ?

I think yes, because thp code and hugetlbfs code are clearly separated
and we can execute only one of them on the same vma.

> Doesn't both require us to
> use same locking when updating pmd ?

I think no for the same reason.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
