Received: by zproxy.gmail.com with SMTP id k1so29042nzf
        for <linux-mm@kvack.org>; Wed, 19 Oct 2005 03:04:08 -0700 (PDT)
Message-ID: <aec7e5c30510190304y3a1935e5k57ddd8912b4e411a@mail.gmail.com>
Date: Wed, 19 Oct 2005 19:04:08 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <Pine.LNX.4.62.0510180938430.7911@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
	 <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
	 <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
	 <Pine.LNX.4.62.0510180938430.7911@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 10/19/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> On Tue, 18 Oct 2005, Magnus Damm wrote:
>
> > This function is very similar to isolate_lru_pages(), except that it
> > operates on one page at a time and drains the lru if needed. Maybe
> > isolate_lru_pages() could use this function (inline) if the spinlock
> > and drain code was moved out?
>
> isolate_lru_pages operates on batches of pages from the same zone and is
> very efficient by only taking a single lock. It also does not drain other
> processors LRUs.

Ah, I see. You have a mix of pages from different zones on your list.
Maybe it is possible to use the same kind of zone locking style as
release_pages() to avoid duplicating code...

> > I'm also curios why you choose to always use list_del() and move back
> > the page if freed elsewhere, instead of using
> > del_page_from_[in]active_list(). I guess because of performance. But
> > if that is the case, wouldn't it make sense to do as little as
> > possible with the spinlock held, ie move list_add() (when rc == 1) out
> > of the function?
>
> I tried to follow isolate_lru_pages as closely as possible. list_add() is
> a simple operation and so I left it inside following some earlier code
> from the hotplug project.

Yep, it probably won't matter.

I'm trying to figure out if this code works in all cases:

+               spin_lock_irq(&zone->lru_lock);
+               list_del(&page->lru);
+               if (!TestSetPageLRU(page)) {
+                       if (PageActive(page))
+                               add_page_to_active_list(zone, page);
+                       else
+                               add_page_to_inactive_list(zone, page);
+                       count++;
+               }
+               spin_unlock_irq(&zone->lru_lock);

Why not use if (TestSetPageLRU(page)) BUG()?

Or is it possible that someone sets the LRU bit while we are keeping
the pages on our non-lru list? If so, who is stealing and will your
put_page() patch work correctly if the page is stolen from us?

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
