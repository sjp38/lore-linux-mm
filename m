Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2F766B46AF
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:01:33 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id n17so5079594pfk.23
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:01:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor3794949plm.18.2018.11.27.00.01.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 00:01:32 -0800 (PST)
Date: Tue, 27 Nov 2018 11:01:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 08/10] mm/khugepaged: collapse_shmem() without freezing
 new_page
Message-ID: <20181127080127.54t7tewbxywavbmj@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261527570.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261527570.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:29:17PM -0800, Hugh Dickins wrote:
> khugepaged's collapse_shmem() does almost all of its work, to assemble
> the huge new_page from 512 scattered old pages, with the new_page's
> refcount frozen to 0 (and refcounts of all old pages so far also frozen
> to 0).  Including shmem_getpage() to read in any which were out on swap,
> memory reclaim if necessary to allocate their intermediate pages, and
> copying over all the data from old to new.
> 
> Imagine the frozen refcount as a spinlock held, but without any lock
> debugging to highlight the abuse: it's not good, and under serious load
> heads into lockups - speculative getters of the page are not expecting
> to spin while khugepaged is rescheduled.
> 
> One can get a little further under load by hacking around elsewhere;
> but fortunately, freezing the new_page turns out to have been entirely
> unnecessary, with no hacks needed elsewhere.
> 
> The huge new_page lock is already held throughout, and guards all its
> subpages as they are brought one by one into the page cache tree; and
> anything reading the data in that page, without the lock, before it has
> been marked PageUptodate, would already be in the wrong.  So simply
> eliminate the freezing of the new_page.
> 
> Each of the old pages remains frozen with refcount 0 after it has been
> replaced by a new_page subpage in the page cache tree, until they are all
> unfrozen on success or failure: just as before.  They could be unfrozen
> sooner, but cause no problem once no longer visible to find_get_entry(),
> filemap_map_pages() and other speculative lookups.
> 
> Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
