Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 99E276B026F
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:27:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b130so44741737wmc.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 07:27:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hm5si34291036wjb.85.2016.09.21.07.27.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 07:27:33 -0700 (PDT)
Subject: Re: [PATCH] mm: avoid endless recursion in dump_page()
References: <20160908082137.131076-1-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <df20f638-0c22-36fd-24b1-3e748419a23c@suse.cz>
Date: Wed, 21 Sep 2016 16:27:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160908082137.131076-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 09/08/2016 10:21 AM, Kirill A. Shutemov wrote:
> dump_page() uses page_mapcount() to get mapcount of the page.
> page_mapcount() has VM_BUG_ON_PAGE(PageSlab(page)) as mapcount doesn't
> make sense for slab pages and the field in struct page used for other
> information.
>
> It leads to recursion if dump_page() called for slub page and DEBUG_VM
> is enabled:
>
> dump_page() -> page_mapcount() -> VM_BUG_ON_PAGE() -> dump_page -> ...
>
> Let's avoid calling page_mapcount() for slab pages in dump_page().

How about instead splitting page_mapcount() so that there is a version 
without VM_BUG_ON_PAGE()?

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/debug.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/debug.c b/mm/debug.c
> index 8865bfb41b0b..74c7cae4f683 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -42,9 +42,11 @@ const struct trace_print_flags vmaflag_names[] = {
>
>  void __dump_page(struct page *page, const char *reason)
>  {

At least there should be a comment explaining why.

> +	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
> +
>  	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> -		  page, page_ref_count(page), page_mapcount(page),
> -		  page->mapping, page->index);
> +		  page, page_ref_count(page), mapcount,
> +		  page->mapping, page_to_pgoff(page));
>  	if (PageCompound(page))
>  		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
>  	pr_cont("\n");
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
