Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 933906B0078
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 02:00:32 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0Q70RHV024202
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 Jan 2010 16:00:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9DE45DE51
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:00:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A51C545DE50
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:00:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CE0D1DB803E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:00:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F44D1DB8038
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:00:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] page_alloc: change bit ops 'or' to logical ops in free/new  page check
In-Reply-To: <cf18f8341001252256q65b90d76vfe3094a1bb5424e7@mail.gmail.com>
References: <cf18f8341001252256q65b90d76vfe3094a1bb5424e7@mail.gmail.com>
Message-Id: <20100126155852.1D53.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 26 Jan 2010 16:00:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> Using logical 'or' in  function free_page_mlock() and
> check_new_page() makes code clear and
> sometimes more effective (Because it can ignore other condition
> compare if the first condition
> is already true).
> 
> It's Nick's patch "mm: microopt conditions" changed it from logical
> ops to bit ops.
> Maybe I didn't consider something. If so, please let me know and just
> ignore this patch.
> Thanks!

I think current code is intentional. On modern cpu, bit-or is faster than
logical or.

Do you have opposite benchmark number result?


> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> 
> diff --git mm/page_alloc.c mm/page_alloc.c
> index 05ae4e0..91ece14 100644
> --- mm/page_alloc.c
> +++ mm/page_alloc.c
> @@ -500,9 +500,9 @@ static inline void free_page_mlock(struct page *page)
> 
>  static inline int free_pages_check(struct page *page)
>  {
> -       if (unlikely(page_mapcount(page) |
> -               (page->mapping != NULL)  |
> -               (atomic_read(&page->_count) != 0) |
> +       if (unlikely(page_mapcount(page) ||
> +               (page->mapping != NULL)  ||
> +               (atomic_read(&page->_count) != 0) ||
>                 (page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
>                 bad_page(page);
>                 return 1;
> @@ -671,9 +671,9 @@ static inline void expand(struct zone *zone, struct page *pa
>   */
>  static inline int check_new_page(struct page *page)
>  {
> -       if (unlikely(page_mapcount(page) |
> -               (page->mapping != NULL)  |
> -               (atomic_read(&page->_count) != 0)  |
> +       if (unlikely(page_mapcount(page) ||
> +               (page->mapping != NULL)  ||
> +               (atomic_read(&page->_count) != 0)  ||
>                 (page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
>                 bad_page(page);
>                 return 1;
> 
> -- 
> Regards,
> -Bob Liu
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
