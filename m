Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 05B786B0089
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:34:15 -0500 (EST)
Date: Fri, 7 Dec 2012 14:34:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing
 hwpoisoned hugepage
Message-Id: <20121207143414.b2d33095.akpm@linux-foundation.org>
In-Reply-To: <1354895397-21736-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <878v9acn5m.fsf@linux.vnet.ibm.com>
	<1354895397-21736-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri,  7 Dec 2012 10:49:57 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This patch fixes the warning from __list_del_entry() which is triggered
> when a process tries to do free_huge_page() for a hwpoisoned hugepage.

This changelog is very short.  In fact it is too short, resulting in
others having to ask questions about the patch.  When this happens,
please treat it as a sign that the changelog needs additional
information - so that other readers will not feel a need to ask the
same questions!

I added this paragraph:

: free_huge_page() can be called for hwpoisoned hugepage from
: unpoison_memory().  This function gets refcount once and clears
: PageHWPoison, and then puts refcount twice to return the hugepage back to
: free pool.  The second put_page() finally reaches free_huge_page().



Also, is the description accurate?  Is the __list_del_entry() warning
the only problem?

Or is it the case that this bug will cause memory corruption?  If so
then the patch is pretty important and is probably needed in -stable as
well?  I haven't checked how far back in time the bug exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
