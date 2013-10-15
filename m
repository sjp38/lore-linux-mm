Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 582A66B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:33:00 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8725404pdi.19
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:33:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
Subject: RE: mm: fix BUG in __split_huge_page_pmd
Content-Transfer-Encoding: 7bit
Message-Id: <20131015113254.14E88E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 14:32:54 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hugh Dickins wrote:
> Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
> __split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).
> 
> It's invalid: we don't always have down_write of mmap_sem there:
> a racing do_huge_pmd_wp_page() might have copied-on-write to another
> huge page before our split_huge_page() got the anon_vma lock.
> 
> Forget the BUG_ON, just go back and try again if this happens.
>     
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org

Looks reasonable to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

madvise(MADV_DONTNEED) was aproblematic with THP before. Is a big win having
mmap_sem taken on read rather than on write for it?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
