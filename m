Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C01D36B0033
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 11:43:49 -0400 (EDT)
Date: Mon, 9 Sep 2013 10:43:57 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 2/2] thp: support split page table lock
Message-ID: <20130909154357.GC12435@sgi.com>
References: <522D33C5.9050707@numascale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <522D33C5.9050707@numascale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Mon, Sep 09, 2013 at 10:34:45AM +0800, Daniel J Blueman wrote:
> On Saturday, 7 September 2013 02:10:02 UTC+8, Naoya Horiguchi  wrote:
> >Hi Alex,
> >
> >On Fri, Sep 06, 2013 at 11:04:23AM -0500, Alex Thorlton wrote:
> >> On Thu, Sep 05, 2013 at 05:27:46PM -0400, Naoya Horiguchi wrote:
> >> > Thp related code also uses per process mm->page_table_lock now.
> >> > So making it fine-grained can provide better performance.
> >> >
> >> > This patch makes thp support split page table lock by using page->ptl
> >> > of the pages storing "pmd_trans_huge" pmds.
> >> >
> >> > Some functions like pmd_trans_huge_lock() and
> page_check_address_pmd()
> >> > are expected by their caller to pass back the pointer of ptl, so this
> >> > patch adds to those functions new arguments for that. Rather than
> that,
> >> > this patch gives only straightforward replacement.
> >> >
> >> > ChangeLog v3:
> >> >  - fixed argument of huge_pmd_lockptr() in copy_huge_pmd()
> >> >  - added missing declaration of ptl in do_huge_pmd_anonymous_page()
> >>
> >> I've applied these and tested them using the same tests program that I
> >> used when I was working on the same issue, and I'm running into some
> >> bugs.  Here's a stack trace:
> >
> >Thank you for helping testing. This bug is new to me.
> 
> With 3.11, this patch series and CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS,
> I consistently hit the same failure when exiting one of my
> stress-testers [1] when using eg 24 cores.
> 
> Doesn't happen with 8 cores, so likely needs enough virtual memory
> to use multiple split locks. Otherwise, this is very promising work!

Daniel,

Hillf Danton (dhillf@gmail.com) suggested putting the big
page_table_lock back into the two functions seen below.  I re-tested
with this change and it seems to resolve the issue.  

- Alex

--- a/mm/pgtable-generic.c      Sat Sep  7 15:17:52 2013
+++ b/mm/pgtable-generic.c      Sat Sep  7 15:20:28 2013
@@ -127,12 +127,14 @@ void pmdp_splitting_flush(struct vm_area
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
                                pgtable_t pgtable)
 {
+       spin_lock(&mm->page_table_lock);
        /* FIFO */
        if (!mm->pmd_huge_pte)
                INIT_LIST_HEAD(&pgtable->lru);
        else
                list_add(&pgtable->lru, &mm->pmd_huge_pte->lru);
        mm->pmd_huge_pte = pgtable;
+       spin_unlock(&mm->page_table_lock);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
@@ -144,6 +146,7 @@ pgtable_t pgtable_trans_huge_withdraw(st
 {
        pgtable_t pgtable;

+       spin_lock(&mm->page_table_lock);
        /* FIFO */
        pgtable = mm->pmd_huge_pte;
        if (list_empty(&pgtable->lru))
@@ -153,6 +156,7 @@ pgtable_t pgtable_trans_huge_withdraw(st
                                              struct page, lru);
                list_del(&pgtable->lru);
        }
+       spin_unlock(&mm->page_table_lock);
        return pgtable;
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
