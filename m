Date: Thu, 24 Jul 2008 14:45:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [mmotm][PATCH 5/9] mlock-mlocked-pages-are-unevictable.patch
In-Reply-To: <20080723203704.BFBD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080723020704.3310e65f.akpm@linux-foundation.org> <20080723203704.BFBD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080724143947.8691.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> > > unevictable-lru-infrastructure-putback_lru_page-rework.patch and unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
> > > makes following patch failure.
> > 
> > This patch (or one nearby) breaks nommu:
> > 
> > mm/built-in.o(.text+0x1bb70): In function `truncate_complete_page':
> > : undefined reference to `__clear_page_mlock'
> > mm/built-in.o(.text+0x1ca90): In function `__invalidate_mapping_pages':
> > : undefined reference to `__clear_page_mlock'
> > mm/built-in.o(.text+0x1d29c): In function `invalidate_inode_pages2_range':
> > : undefined reference to `__clear_page_mlock'
> 
> sorry, I have very limited code viewing environment on this week because OLS.
> Lee-san, Could you review code today?
> 
> I guess __clear_page_mlock() written in wrong ifdef..


Andrew, maybe following patch fixes build error.
Please apply.

------------------------------------
Against:       mmotm Jul 23
Applies after: revert-to-unevictable-lru-infrastructure-kconfig-fixpatch.patch

Current unevictable infrastructure code depend on MMU.
Then, nommu build cause following error.

mm/built-in.o(.text+0x1bb70): In function `truncate_complete_page':
: undefined reference to `__clear_page_mlock'
mm/built-in.o(.text+0x1ca90): In function `__invalidate_mapping_pages':
: undefined reference to `__clear_page_mlock'
mm/built-in.o(.text+0x1d29c): In function `invalidate_inode_pages2_range':
: undefined reference to `__clear_page_mlock'


So, adding dependency to Kconfig is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Index: linux-2.6.26-mmotm-0723/mm/Kconfig
===================================================================
--- linux-2.6.26-mmotm-0723.orig/mm/Kconfig	2008-07-25 11:47:13.000000000 +0900
+++ linux-2.6.26-mmotm-0723/mm/Kconfig	2008-07-25 11:51:36.000000000 +0900
@@ -212,6 +212,7 @@
 config UNEVICTABLE_LRU
 	bool "Add LRU list to track non-evictable pages"
 	default y
+	depends on MMU
 	help
 	  Keeps unevictable pages off of the active and inactive pageout
 	  lists, so kswapd will not waste CPU time or have its balancing



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
