Date: Tue, 18 Oct 2005 09:46:09 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 2/2] Page migration via Swap V2: MPOL_MF_MOVE interface
In-Reply-To: <aec7e5c30510180305q43488fcdq601045baa6ecb409@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0510180943460.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
  <20051018004942.3191.44835.sendpatchset@schroedinger.engr.sgi.com>
 <aec7e5c30510180305q43488fcdq601045baa6ecb409@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, Magnus Damm wrote:

> isolate_lru_page() calls get_page_testone(), and swapout_pages() seems
> to call __put_page(). But who decrements page->_count in the case of
> putback_lru_pages()?

Right. Here is a patch that does a put_page in putback_lru_pages():

Index: linux-2.6.14-rc4-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/vmscan.c	2005-10-17 16:19:21.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/vmscan.c	2005-10-18 09:36:36.000000000 -0700
@@ -894,6 +894,8 @@ int putback_lru_pages(struct list_head *
 			count++;
 		}
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
