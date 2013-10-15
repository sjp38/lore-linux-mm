Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A7A486B003B
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:41:37 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so9016253pde.10
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:41:37 -0700 (PDT)
Date: Tue, 15 Oct 2013 16:41:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Message-ID: <20131015144128.GF3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
 <20131015113254.14E88E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131015113254.14E88E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 15, 2013 at 02:32:54PM +0300, Kirill A. Shutemov wrote:
> Hugh Dickins wrote:
> > Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
> > __split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).
> > 
> > It's invalid: we don't always have down_write of mmap_sem there:
> > a racing do_huge_pmd_wp_page() might have copied-on-write to another
> > huge page before our split_huge_page() got the anon_vma lock.
> > 
> > Forget the BUG_ON, just go back and try again if this happens.
> >     
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Cc: stable@vger.kernel.org
> 
> Looks reasonable to me.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> madvise(MADV_DONTNEED) was aproblematic with THP before. Is a big win having
> mmap_sem taken on read rather than on write for it?

Yeah it caused all those pmd_trans_unstable and
pmd_none_or_trans_huge_or_clear_bad and pmd_read_atomic in common
code. But I didn't want to regress the scalability of
MADV_DONTNEED... I think various apps use MADV_DONTNEED to free memory
(including very KVM in the balloon driver and probably JVM and other JIT).

none or huge pmds are unstable without mmap_sem for writing and
without page_table_lock (or in general pmd_trans_huge_lock).

It's identical to the pte being unstable if mmap_sem is held for
reading and we don't hold the PT lock, except the pte can only have
two states and they're both unstable.

hugepmds have three states, and the only stable state of the tree is
when it points to a regular pte (the third state that 4k ptes cannot have).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
