Date: Wed, 19 Oct 2005 13:32:36 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <aec7e5c30510190304y3a1935e5k57ddd8912b4e411a@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0510191330540.13930@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
  <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
 <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
 <Pine.LNX.4.62.0510180938430.7911@schroedinger.engr.sgi.com>
 <aec7e5c30510190304y3a1935e5k57ddd8912b4e411a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 19 Oct 2005, Magnus Damm wrote:

> I'm trying to figure out if this code works in all cases:
> 
> +               spin_lock_irq(&zone->lru_lock);
> +               list_del(&page->lru);
> +               if (!TestSetPageLRU(page)) {
> +                       if (PageActive(page))
> +                               add_page_to_active_list(zone, page);
> +                       else
> +                               add_page_to_inactive_list(zone, page);
> +                       count++;
> +               }
> +               spin_unlock_irq(&zone->lru_lock);
> 
> Why not use if (TestSetPageLRU(page)) BUG()?

The memory hotplug project has a BUG() there and I cannot find a way that
something else could legitimately set the LRU bit. You are right. Thus 
this fix which also includes the addition of put_page() already included 
in an earlier patch.

Index: linux-2.6.14-rc4-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/vmscan.c	2005-10-17 16:19:21.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/vmscan.c	2005-10-19 13:30:00.000000000 -0700
@@ -886,14 +886,16 @@ int putback_lru_pages(struct list_head *
 
 		spin_lock_irq(&zone->lru_lock);
 		list_del(&page->lru);
-		if (!TestSetPageLRU(page)) {
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
-			count++;
-		}
+		if (TestSetPageLRU(page))
+			BUG();
+		if (PageActive(page))
+			add_page_to_active_list(zone, page);
+		else
+			add_page_to_inactive_list(zone, page);
+		count++;
 		spin_unlock_irq(&zone->lru_lock);
+		/* Undo the get from isolate_lru_page */
+		put_page(page);
 	}
 	return count;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
