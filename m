Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8206B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 06:48:31 -0400 (EDT)
Received: by wggj6 with SMTP id j6so4411456wgg.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 03:48:30 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ft4si2503136wib.28.2015.05.12.03.48.29
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 03:48:30 -0700 (PDT)
Date: Tue, 12 May 2015 13:48:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] rmap: fix theoretical race between do_wp_page and
 shrink_active_list
Message-ID: <20150512104824.GC18365@node.dhcp.inet.fi>
References: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
