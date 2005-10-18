Received: by zproxy.gmail.com with SMTP id k1so224242nzf
        for <linux-mm@kvack.org>; Tue, 18 Oct 2005 01:34:44 -0700 (PDT)
Message-ID: <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
Date: Tue, 18 Oct 2005 17:34:44 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
	 <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 10/18/05, Christoph Lameter <clameter@sgi.com> wrote:
> +/*
> + * Isolate one page from the LRU lists and put it on the
> + * indicated list.
> + *
> + * Result:
> + *  0 = page not on LRU list
> + *  1 = page removed from LRU list and added to the specified list.
> + * -1 = page is being freed elsewhere.
> + */
> +int isolate_lru_page(struct page *page, struct list_head *l)
> +{
> +       int rc = 0;
> +       struct zone *zone = page_zone(page);
> +
> +redo:
> +       spin_lock_irq(&zone->lru_lock);
> +       if (TestClearPageLRU(page)) {
> +               list_del(&page->lru);
> +               if (get_page_testone(page)) {
> +                       /*
> +                        * It is being freed elsewhere
> +                        */
> +                       __put_page(page);
> +                       SetPageLRU(page);
> +                       if (PageActive(page))
> +                               list_add(&page->lru, &zone->active_list);
> +                       else
> +                               list_add(&page->lru, &zone->inactive_list);
> +                       rc = -1;
> +               } else {
> +                       list_add(&page->lru, l);
> +                       if (PageActive(page))
> +                               zone->nr_active--;
> +                       else
> +                               zone->nr_inactive--;
> +                       rc = 1;
> +               }
> +       }
> +       spin_unlock_irq(&zone->lru_lock);
> +       if (rc == 0) {
> +               /*
> +                * Maybe this page is still waiting for a cpu to drain it
> +                * from one of the lru lists?
> +                */
> +               smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
> +               lru_add_drain();
> +               if (PageLRU(page))
> +                       goto redo;
> +       }
> +       return rc;
> +}

This function is very similar to isolate_lru_pages(), except that it
operates on one page at a time and drains the lru if needed. Maybe
isolate_lru_pages() could use this function (inline) if the spinlock
and drain code was moved out?

I'm also curios why you choose to always use list_del() and move back
the page if freed elsewhere, instead of using
del_page_from_[in]active_list(). I guess because of performance. But
if that is the case, wouldn't it make sense to do as little as
possible with the spinlock held, ie move list_add() (when rc == 1) out
of the function?

I'd love to see those patches included somewhere, it would help me a
lot when I build code for separated mapped and unmapped LRU:s.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
