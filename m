Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 042AC6B0039
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:48:33 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so8937376pde.38
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:48:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015143407.GE3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
 <20131015143407.GE3479@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Content-Transfer-Encoding: 7bit
Message-Id: <20131015144827.C45DDE0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 17:48:27 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Andrea Arcangeli wrote:
> Hi Hugh,
> 
> On Tue, Oct 15, 2013 at 04:08:28AM -0700, Hugh Dickins wrote:
> > Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
> > __split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).
> > 
> > It's invalid: we don't always have down_write of mmap_sem there:
> > a racing do_huge_pmd_wp_page() might have copied-on-write to another
> > huge page before our split_huge_page() got the anon_vma lock.
> > 
> 
> I don't get exactly the scenario with do_huge_pmd_wp_page(), could you
> elaborate?

I think the scenario is follow:

	CPU0:					CPU1

__split_huge_page_pmd()
	page = pmd_page(*pmd);
					do_huge_pmd_wp_page() copy the
					page and changes pmd (the same as on CPU0)
					to point to newly copied page.
	split_huge_page(page)
	where page is original page,
	not allocated on COW.
	pmd still points on huge page.


Hugh, have I got it correctly?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
