Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A705F6B4685
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:35:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id h10so9474844pgv.20
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:35:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor3732851pgq.28.2018.11.26.23.35.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:35:12 -0800 (PST)
Date: Tue, 27 Nov 2018 10:35:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/10] mm/khugepaged: fix crashes due to misaccounted
 holes
Message-ID: <20181127073507.grg37bythi4sllkz@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261523450.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261523450.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:25:01PM -0800, Hugh Dickins wrote:
> Huge tmpfs testing on a shortish file mapped into a pmd-rounded extent hit
> shmem_evict_inode()'s WARN_ON(inode->i_blocks) followed by clear_inode()'s
> BUG_ON(inode->i_data.nrpages) when the file was later closed and unlinked.
> 
> khugepaged's collapse_shmem() was forgetting to update mapping->nrpages on
> the rollback path, after it had added but then needs to undo some holes.
> 
> There is indeed an irritating asymmetry between shmem_charge(), whose
> callers want it to increment nrpages after successfully accounting blocks,
> and shmem_uncharge(), when __delete_from_page_cache() already decremented
> nrpages itself: oh well, just add a comment on that to them both.
> 
> And shmem_recalc_inode() is supposed to be called when the accounting is
> expected to be in balance (so it can deduce from imbalance that reclaim
> discarded some pages): so change shmem_charge() to update nrpages earlier
> (though it's rare for the difference to matter at all).
> 
> Fixes: 800d8c63b2e98 ("shmem: add huge pages support")
> Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I think we would need to revisit the accounting helpers to make them less
error prone. But it's out of scope for the patchset.

-- 
 Kirill A. Shutemov
