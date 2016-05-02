Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1BCB6B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 14:56:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x67so371561873oix.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 11:56:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v7si178825ioe.64.2016.05.02.11.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 11:56:52 -0700 (PDT)
Date: Mon, 2 May 2016 20:56:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502185649.GC12310@redhat.com>
References: <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502121402.GB23305@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 03:14:02PM +0300, Kirill A. Shutemov wrote:
> Quick look around:
> 
>  - I don't see any check page_count() around __replace_page() in uprobes,
>    so it can easily replace pinned page.
> 
>  - KSM has the page_count() check, there's still race wrt GUP_fast: it can
>    take the pin between the check and establishing new pte entry.

		 * Ok this is tricky, when get_user_pages_fast() run it doesn't
		 * take any lock, therefore the check that we are going to make
		 * with the pagecount against the mapcount is racey and
		 * O_DIRECT can happen right after the check.
		 * So we clear the pte and flush the tlb before the check
		 * this assure us that no O_DIRECT can happen after the check
		 * or in the middle of the check.
		 */
		entry = ptep_clear_flush_notify(vma, addr, ptep);

KSM takes care of that or it wouldn't be safe if KSM was with memory
under O_DIRECT.
 
>  - khugepaged: the same story as with KSM.

In __collapse_huge_page_isolate we do:

		/*
		 * cannot use mapcount: can't collapse if there's a gup pin.
		 * The page must only be referenced by the scanned process
		 * and page swap cache.
		 */
		if (page_count(page) != 1 + !!PageSwapCache(page)) {
			unlock_page(page);
			result = SCAN_PAGE_COUNT;
			goto out;
		}

At that point the pmd has been zapped (pmdp_collapse_flush already
run) and like for KSM case that is enough to ensure
get_user_pages_fast can't succeed and it'll have to call into the slow
get_user_pages.

These two issues are not specific to vfio and IOMMUs, this is must be
correct or O_DIRECT will generate data corruption in presence of
KSM/khugepaged. Both looks fine to me.

> I don't see how we can deliver on the guarantee, especially with lockless
> GUP_fast.

By zapping the pmd_trans_huge/pte and sending IPIs if needed
(get_user_pages_fast runs with irq disabled), before checking
page_count.

With the RCU version of it it's the same, but instead of sending IPIs,
we'll wait for a quiescient point to be sure of having flushed any
concurrent get_user_pages_fast out of the other CPUs, before we
proceed to check page_count (then no other get_user_pages_fast can
increase the page count for this page on this "mm" anymore).

That's how the guaranteed is provided against get_user_pages_fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
