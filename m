Date: Sun, 7 Jan 2001 14:25:42 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH *] 2.4.0 VM improvements
In-Reply-To: <Pine.LNX.4.21.0101071529070.21675-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101071422180.4416-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 7 Jan 2001, Rik van Riel wrote:

> The patch is available at this URL:
> 
> 	http://www.surriel.com/patches/2.4/2.4.0-tunevm+rss

I have one improvement on top of your patch.

Now its not more "rare" (as the comment on the code stated) to have
pages with page->age == 0 being called on lru_cache_add. 

This patch should make the overhead of calling lru_cache_add on pages with
page->age == 0 smaller. 

--- mm/swap.c.orig      Sun Jan  7 15:59:37 2001
+++ mm/swap.c   Sun Jan  7 16:11:21 2001
@@ -233,10 +233,12 @@
        if (!PageLocked(page))
                BUG();
        DEBUG_ADD_PAGE
-       add_page_to_active_list(page);
-       /* This should be relatively rare */
-       if (!page->age)
-               deactivate_page_nolock(page);
+
+       if (page->age)
+               add_page_to_active_list(page);
+       else
+               add_page_to_inactive_dirty_list(page);
+
        spin_unlock(&pagemap_lru_lock);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
