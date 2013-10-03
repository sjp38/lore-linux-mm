Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id C92256B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 19:11:14 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so3113553pbc.36
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 16:11:14 -0700 (PDT)
Date: Thu, 3 Oct 2013 16:11:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 09/10] mm: implement split page table lock for PMD
 level
Message-Id: <20131003161109.aa568784d6fc48e61dc1d33e@linux-foundation.org>
In-Reply-To: <1380287787-30252-10-git-send-email-kirill.shutemov@linux.intel.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1380287787-30252-10-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 27 Sep 2013 16:16:26 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> The basic idea is the same as with PTE level: the lock is embedded into
> struct page of table's page.
> 
> We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
> take mm->page_table_lock anymore. Let's reuse page->lru of table's page
> for that.
> 
> pgtable_pmd_page_ctor() returns true, if initialization is successful
> and false otherwise. Current implementation never fails, but assumption
> that constructor can fail will help to port it to -rt where spinlock_t
> is rather huge and cannot be embedded into struct page -- dynamic
> allocation is required.

spinlock_t is rather large when lockdep is enabled.  What happens?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
