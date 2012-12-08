Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C17296B0070
	for <linux-mm@kvack.org>; Sat,  8 Dec 2012 16:04:46 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned hugepage
Date: Sat,  8 Dec 2012 16:04:35 -0500
Message-Id: <1355000675-2008-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121207143414.b2d33095.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, aneesh.kumar@linux.vnet.ibm.com, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 07, 2012 at 02:34:14PM -0800, Andrew Morton wrote:
> On Fri,  7 Dec 2012 10:49:57 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
> > This patch fixes the warning from __list_del_entry() which is triggered
> > when a process tries to do free_huge_page() for a hwpoisoned hugepage.
>
> This changelog is very short.  In fact it is too short, resulting in
> others having to ask questions about the patch.  When this happens,
> please treat it as a sign that the changelog needs additional
> information - so that other readers will not feel a need to ask the
> same questions!

OK, I'll be careful after this.

> I added this paragraph:
>
> : free_huge_page() can be called for hwpoisoned hugepage from
> : unpoison_memory().  This function gets refcount once and clears
> : PageHWPoison, and then puts refcount twice to return the hugepage back to
> : free pool.  The second put_page() finally reaches free_huge_page().
>
>
>
> Also, is the description accurate?  Is the __list_del_entry() warning
> the only problem?

Right, this description is correct and this warning is the only problem.

> Or is it the case that this bug will cause memory corruption?  If so
> then the patch is pretty important and is probably needed in -stable as
> well?  I haven't checked how far back in time the bug exists.

There's no memory corruption even if we leave this bug unfixed, because
in unpoisoning (only way to change the status of hwpoisoned hugepage),
there are two possible operations on page->lru as shown below:

  static void free_huge_page(struct page *page)
  {
          ...
          if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
                  /* remove the page from active list */
                  list_del(&page->lru);
                  update_and_free_page(h, page);
                  h->surplus_huge_pages--;
                  h->surplus_huge_pages_node[nid]--;
          } else {
                  arch_clear_hugepage_flags(page);
                  enqueue_huge_page(h, page); /* list_move inside this function*/
          }
          ...
  }

, but both path do simply list_del() or list_move(), so there's no
difference (except for warning) after this block whether page->lru is
dangling or pointing to itself.

This bug was introduced recently on commit 0edaecfab218d747d30de
("hugetlb: add a list for tracking in-use HugeTLB pages").

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
