Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0D76B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 21:14:28 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so33253784pdb.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 18:14:27 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id qj7si24669189pbc.234.2015.05.12.18.14.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 18:14:27 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so32617335pac.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 18:14:26 -0700 (PDT)
Date: Wed, 13 May 2015 10:14:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] rmap: fix theoretical race between do_wp_page and
 shrink_active_list
Message-ID: <20150513011413.GA8267@blaptop>
References: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, May 12, 2015 at 01:18:39PM +0300, Vladimir Davydov wrote:
> As noted by Paul the compiler is free to store a temporary result in a
> variable on stack, heap or global unless it is explicitly marked as
> volatile, see:
> 
>   http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/n4455.html#sample-optimizations
> 
> This can result in a race between do_wp_page() and shrink_active_list()
> as follows.
> 
> In do_wp_page() we can call page_move_anon_rmap(), which sets
> page->mapping as follows:
> 
>   anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
>   page->mapping = (struct address_space *) anon_vma;
> 
> The page in question may be on an LRU list, because nowhere in
> do_wp_page() we remove it from the list, neither do we take any LRU
> related locks. Although the page is locked, shrink_active_list() can
> still call page_referenced() on it concurrently, because the latter does
> not require an anonymous page to be locked:
> 
>   CPU0                          CPU1
>   ----                          ----
>   do_wp_page                    shrink_active_list
>    lock_page                     page_referenced
>                                   PageAnon->yes, so skip trylock_page
>    page_move_anon_rmap
>     page->mapping = anon_vma
>                                   rmap_walk
>                                    PageAnon->no
>                                    rmap_walk_file
>                                     BUG
>     page->mapping += PAGE_MAPPING_ANON
> 
> This patch fixes this race by explicitly forbidding the compiler to
> split page->mapping store in page_move_anon_rmap() with the aid of
> WRITE_ONCE.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> ---

The paper says "This requires escape analysis: blah blah for this optimization
to be valid" So, I'm not sure it's the case but admit we couldn't guarantee
all of compiler optimization technique so I am in favor of the patch to make
sure future-proof with upcoming suprising compiler technique.

Another review point I had is whether lockless page in shrink_active_list
could be turn into PageKsm in the middle of page_referenced. IOW,

        page_referenced
                PageAnon && !PageKsm -> true so avoid try_lockpage
                <... amount of stall start >
                Other cpu makes the page into PageKsm
                <... amount of stall end >
                rmap_walk
                  PageKsm-> true
                  rmap_walk_ksm
                    -> bang because ksm expect the passed page was locked

However, we increased page->count in isolate_lru_page before passing
the page in page_referenced so KSM cannot make the page KsmPage so
it's safe.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
