Date: Fri, 12 Jan 2001 17:22:17 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.10.10101121138060.2249-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101121705540.10842-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2001, Linus Torvalds wrote:

> That's an effect of replacing "wakeup_kswapd(1)" with shrinking the inode
> and dentry caches and page_launder(), and it is probably the nicest kernel
> for stuff that wants to avoid caching stuff excessively. But it does mean
> that we don't try to swap stuff out very much, and it also means that we
> end up shrinking the directory cache in particular more aggressively than
> before. Which is bad.
> 
> I really think that that page_launder() should be a "try_to_free_page()"
> instead.

Linus,

do_try_to_free_pages() will shrink the caches too, so I'm not sure if that
is the reason for the slowdown Zlatko is seeing. 

I dont understand the following changes you've done to try_to_swapout() in
pre2 (as someone previously commented on this thread): 

-   onlist = PageActive(page);
    /* Don't look at this pte if it's been accessed recently. */
    if (ptep_test_and_clear_young(page_table)) {
-       age_page_up(page);
-       goto out_failed;
+       page->age += PAGE_AGE_ADV;
+       if (page->age > PAGE_AGE_MAX)
+           page->age = PAGE_AGE_MAX;
+       return;
    }
-   if (!onlist)
-       /* The page is still mapped, so it can't be freeable... */
-       age_page_down_ageonly(page);
-
-   /*
-    * If the page is in active use by us, or if the page
-    * is in active use by others, don't unmap it or
-    * (worse) start unneeded IO.
-    */
-   if (page->age > 0)
-       goto out_failed;


First, age_page_up() will move the page to the active list if it was not
active before and your change simply increases the page age.

Secondly, you removed the "(page->age > 0)" check which is obviously
correct to me (we don't want to unmap the page if it does not have age 0)

The third thing is that we dont age down pages anymore. (ok, the
"onlist" thing was wrong, but anyway...)

The patch I posted previously to add background pte scanning changed this
stuff. 

Zlatko, could you try
http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.1pre2/bg_cond_pte_aging.patch
and report results?

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
