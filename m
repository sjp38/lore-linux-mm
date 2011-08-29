Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2AE2900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:48:48 -0400 (EDT)
Received: by yib2 with SMTP id 2so3937341yib.14
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:48:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110729075837.12274.58405.stgit@localhost6>
References: <20110729075837.12274.58405.stgit@localhost6>
Date: Mon, 29 Aug 2011 16:48:46 +0900
Message-ID: <CAEwNFnBFNzrPoen-oM7DdB1QA5-cmUqAFABO7WxzZpiQacA7Fg@mail.gmail.com>
Subject: Re: [PATCH] mm: add free_hot_cold_page_list helper
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Jul 29, 2011 at 4:58 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This patch adds helper free_hot_cold_page_list() to free list of 0-order =
pages.
> It frees pages directly from list without temporary page-vector.
> It also calls trace_mm_pagevec_free() to simulate pagevec_free() behaviou=
r.
>
> bloat-o-meter:
>
> add/remove: 1/1 grow/shrink: 1/3 up/down: 267/-295 (-28)
> function =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 old =C2=A0 =
=C2=A0 new =C2=A0 delta
> free_hot_cold_page_list =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- =C2=A0 =C2=A0 264 =C2=A0 =C2=A0+264
> get_page_from_freelist =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A02129 =C2=A0 =C2=A02132 =C2=A0 =C2=A0 =C2=A0+3
> __pagevec_free =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 243 =C2=A0 =C2=A0 239 =C2=
=A0 =C2=A0 =C2=A0-4
> split_free_page =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0380 =C2=A0 =C2=A0 373 =C2=
=A0 =C2=A0 =C2=A0-7
> release_pages =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0606 =C2=A0 =C2=A0 510 =
=C2=A0 =C2=A0 -96
> free_page_list =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 188 =C2=A0 =C2=A0 =C2=A0 -=
 =C2=A0 =C2=A0-188
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
> =C2=A0include/linux/gfp.h | =C2=A0 =C2=A01 +
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 | =C2=A0 12 ++++++++++++
> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 14 +++-------=
----
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 20 +--------------=
-----
> =C2=A04 files changed, 17 insertions(+), 30 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index cb40892..dd7b9cc 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -358,6 +358,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp=
_t gfp_mask);
> =C2=A0extern void __free_pages(struct page *page, unsigned int order);
> =C2=A0extern void free_pages(unsigned long addr, unsigned int order);
> =C2=A0extern void free_hot_cold_page(struct page *page, int cold);
> +extern void free_hot_cold_page_list(struct list_head *list, int cold);
>
> =C2=A0#define __free_page(page) __free_pages((page), 0)
> =C2=A0#define free_page(addr) free_pages((addr), 0)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1dbcf88..af486e4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1209,6 +1209,18 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_restore(flags);
> =C2=A0}
>
> +void free_hot_cold_page_list(struct list_head *list, int cold)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct page *page, *next;
> +
> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(page, next, list, lru) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 trace_mm_pagevec_free(=
page, cold);


I understand you want to minimize changes without breaking current ABI
with trace tools.
But apparently, It's not a pagvec_free. It just hurts readability.
As I take a look at the code, mm_pagevec_free isn't related to pagevec
but I guess it can represent 0-order pages free because 0-order pages
are freed only by pagevec until now.
So, how about renaming it with mm_page_free or mm_page_free_zero_order?
If you do, you need to do s/MM_PAGEVEC_FREE/MM_FREE_FREE/g in
trace-pagealloc-postprocess.pl.


> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free_hot_cold_page(pag=
e, cold);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(list);

Why do we need it?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
