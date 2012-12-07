Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id BCF4F6B0044
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 01:14:50 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned hugepage
Date: Fri,  7 Dec 2012 01:14:42 -0500
Message-Id: <1354860882-14567-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87ehj2ctjq.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aneesh.kumar@linux.vnet.ibm.com
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 07, 2012 at 11:06:41AM +0530, Aneesh Kumar K.V wrote:
...
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Thu, 6 Dec 2012 20:54:30 -0500
> > Subject: [PATCH v2] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned
> >  hugepage
> >
> > This patch fixes the warning from __list_del_entry() which is triggered
> > when a process tries to do free_huge_page() for a hwpoisoned hugepage.
> 
> 
> Can you get a dump stack for that. I am confused because the page was
> already in freelist, and we deleted it from the list and set the
> refcount to 1. So how are we reaching free_huge_page() again ?

free_huge_page() can be called for hwpoisoned hugepage from unpoison_memory().
This function gets refcount once and clears PageHWPoison, and then puts
refcount twice to return the hugepage back to free pool.
The second put_page() finally reaches free_huge_page().

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
