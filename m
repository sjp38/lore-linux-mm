Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA5E6B008A
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:55:49 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so10582038lab.12
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:55:48 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id q15si11878814lal.79.2014.12.15.15.55.47
        for <linux-mm@kvack.org>;
        Mon, 15 Dec 2014 15:55:47 -0800 (PST)
Date: Tue, 16 Dec 2014 01:55:32 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 5/6]
 mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
Message-ID: <20141215235532.GA16180@node.dhcp.inet.fi>
References: <548f68cf.6xGKPRYKtNb84wM5%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <548f68cf.6xGKPRYKtNb84wM5%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@linux.intel.com, dave.hansen@linux.intel.com, lliubbo@gmail.com, matthew.r.wilcox@intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, sasha.levin@oracle.com, hughd@google.com

On Mon, Dec 15, 2014 at 03:03:43PM -0800, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> 
> add comment which may not be true :(
> 
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Bob Liu <lliubbo@gmail.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff -puN mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix mm/memory.c
> --- a/mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> +++ a/mm/memory.c
> @@ -3009,6 +3009,12 @@ static int do_shared_fault(struct mm_str
>  
>  	if (set_page_dirty(fault_page))
>  		dirtied = 1;
> +	/*
> +	 * Take a local copy of the address_space - page.mapping may be zeroed
> +	 * by truncate after unlock_page().   The address_space itself remains
> +	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
> +	 * release semantics to prevent the compiler from undoing this copying.
> +	 */

Looks correct to me.

We need the same comment or reference to this one in do_wp_page().

>  	mapping = fault_page->mapping;

BTW, I noticed that fault_page here can be a tail page: sound subsytem
allocates its pages with GFP_COMP and maps them with ptes. The problem is
that we never set ->mapping for tail pages and the check below is always
false. It seems doesn't cause any problems right now (looks like ->mapping
is NULL also for head page sound case), but logic is somewhat broken.

I only triggered the problem when tried to reuse ->mapping in first tail
page for compound_mapcount in my thp refcounting rework.

If it sounds right, I will prepare patch to replace the line above and the
same case in do_wp_page() with

	mapping = compound_head(fault_page)->mapping;

Ok?

>  	unlock_page(fault_page);
>  	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
> _
> 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
