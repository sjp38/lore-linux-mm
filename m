Subject: Re: pre2 swap_out() changes
References: <Pine.LNX.4.21.0101121705540.10842-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 13 Jan 2001 12:41:38 +0100
In-Reply-To: Marcelo Tosatti's message of "Fri, 12 Jan 2001 17:22:17 -0200 (BRST)"
Message-ID: <873denhe6l.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On Fri, 12 Jan 2001, Linus Torvalds wrote:
> 
> > That's an effect of replacing "wakeup_kswapd(1)" with shrinking the inode
> > and dentry caches and page_launder(), and it is probably the nicest kernel
> > for stuff that wants to avoid caching stuff excessively. But it does mean
> > that we don't try to swap stuff out very much, and it also means that we
> > end up shrinking the directory cache in particular more aggressively than
> > before. Which is bad.
> > 
> > I really think that that page_launder() should be a "try_to_free_page()"
> > instead.
> 
> Linus,
> 
> do_try_to_free_pages() will shrink the caches too, so I'm not sure if that
> is the reason for the slowdown Zlatko is seeing. 
> 
> I dont understand the following changes you've done to try_to_swapout() in
> pre2 (as someone previously commented on this thread): 
> 
> -   onlist = PageActive(page);
>     /* Don't look at this pte if it's been accessed recently. */
>     if (ptep_test_and_clear_young(page_table)) {
> -       age_page_up(page);
> -       goto out_failed;
> +       page->age += PAGE_AGE_ADV;
> +       if (page->age > PAGE_AGE_MAX)
> +           page->age = PAGE_AGE_MAX;
> +       return;
>     }
> -   if (!onlist)
> -       /* The page is still mapped, so it can't be freeable... */
> -       age_page_down_ageonly(page);
> -
> -   /*
> -    * If the page is in active use by us, or if the page
> -    * is in active use by others, don't unmap it or
> -    * (worse) start unneeded IO.
> -    */
> -   if (page->age > 0)
> -       goto out_failed;
> 
> 
> First, age_page_up() will move the page to the active list if it was not
> active before and your change simply increases the page age.
> 
> Secondly, you removed the "(page->age > 0)" check which is obviously
> correct to me (we don't want to unmap the page if it does not have age 0)
> 
> The third thing is that we dont age down pages anymore. (ok, the
> "onlist" thing was wrong, but anyway...)
> 
> The patch I posted previously to add background pte scanning changed this
> stuff. 
> 
> Zlatko, could you try
> http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.1pre2/bg_cond_pte_aging.patch
> and report results?
> 

2.2.17     -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
2.4.0      -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
2.4.0-pre2 -> make -j32  393.32s user 138.20s system 129% cpu 6:51.82 total
pre3-bgage -> make -j32  394.11s user 424.52s system 131% cpu 10:21.41 total

Hm, sorry to rain on your parade, but it actually made things even
worse. Notice how the system time is getting bigger with every try.

I also took an opportunity to check your swap-write-clustering patch
(you've been sending for some time to linux-kernel :)) but over the
last good performing 2.4.0 VM, but it also reduces performance and
after some testing it deadlocked.

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
