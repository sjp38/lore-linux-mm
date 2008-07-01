Received: by an-out-0708.google.com with SMTP id d17so387360and.105
        for <linux-mm@kvack.org>; Tue, 01 Jul 2008 00:34:35 -0700 (PDT)
Message-ID: <28c262360807010034m7438f1e3yc28daae9978150b6@mail.gmail.com>
Date: Tue, 1 Jul 2008 16:34:35 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH -mm] split_lru: fix pagevec_move_tail() doesn't treat unevictable page
In-Reply-To: <20080701155749.37F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080701155749.37F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 1, 2008 at 4:01 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> even under writebacking, page can move to unevictable list.
> so shouldn't pagevec_move_tail() check unevictable?
>
Hi, Kosaki-san.

I can't understand this race situation.
How the page can move to unevictable list while it is under writeback?

Could you explain for me ? :)

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> ---
>  mm/swap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: b/mm/swap.c
> ===================================================================
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -116,7 +116,7 @@ static void pagevec_move_tail(struct pag
>                        zone = pagezone;
>                        spin_lock(&zone->lru_lock);
>                }
> -               if (PageLRU(page) && !PageActive(page)) {
> +               if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>                        int lru = page_is_file_cache(page);
>                        list_move_tail(&page->lru, &zone->lru[lru].list);
>                        pgmoved++;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
