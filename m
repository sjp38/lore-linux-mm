Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 751826B009B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 09:19:36 -0400 (EDT)
Date: Mon, 3 Jun 2013 15:19:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
Message-ID: <20130603131932.GA18588@dhcp22.suse.cz>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369770771-8447-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Tue 28-05-13 15:52:50, Naoya Horiguchi wrote:
> Currently all of page table handling by hugetlbfs code are done under
> mm->page_table_lock. This is not optimal because there can be lock
> contentions between unrelated components using this lock.

While I agree with such a change in general I am a bit afraid of all
subtle tweaks in the mm code that make hugetlb special. Maybe there are
none for page_table_lock but I am not 100% sure. So this might be
really tricky and it is not necessary for your further patches, is it?

How have you tested this?

> This patch makes hugepage support split page table lock so that
> we use page->ptl of the leaf node of page table tree which is pte for
> normal pages but can be pmd and/or pud for hugepages of some architectures.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/x86/mm/hugetlbpage.c |  6 ++--
>  include/linux/hugetlb.h   | 18 ++++++++++
>  mm/hugetlb.c              | 84 ++++++++++++++++++++++++++++-------------------

This doesn't seem to be the complete story. At least not from the
trivial:
$ find arch/ -name "*hugetlb*" | xargs git grep "page_table_lock" -- 
arch/powerpc/mm/hugetlbpage.c:  spin_lock(&mm->page_table_lock);
arch/powerpc/mm/hugetlbpage.c:  spin_unlock(&mm->page_table_lock);
arch/tile/mm/hugetlbpage.c:             spin_lock(&mm->page_table_lock);
arch/tile/mm/hugetlbpage.c:
spin_unlock(&mm->page_table_lock);
arch/x86/mm/hugetlbpage.c: * called with vma->vm_mm->page_table_lock held.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
