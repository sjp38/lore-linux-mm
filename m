Message-ID: <3D6BD0A8.74509205@zip.com.au>
Date: Tue, 27 Aug 2002 12:19:04 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: MM patches against 2.5.31
References: <3D644C70.6D100EA5@zip.com.au> <E17jKlX-0001i0-00@starship> <20020826152950.9929.qmail@thales.mathematik.uni-ulm.de> <E17jO6g-0002XU-00@starship> <3D6A8082.3775C5AB@zip.com.au> <20020827092219.27495.qmail@thales.mathematik.uni-ulm.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>
Cc: Daniel Phillips <phillips@arcor.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christian Ehrhardt wrote:
> 
> ...
> So what we want CPUB do instead is
> 
>         spin_lock(lru_lock);
>         page = list_entry(lru)
> 
>         START ATOMIC
>                 page_cache_get(page);
>                 res = (page_count (page) == 1)
>         END ATOMIC
> 
>         if (res) {
>                 atomic_dec (&page->count);
>                 continue;  /* with next page */
>         }
>         ...
>         page_cache_release (page);
> 
> I.e. we want to detect _atomically_ that we just raised the page count
> from zero to one. My patch actually has a solution that implements the
> needed atomic operation above by means of the atomic functions that we
> currently have on all archs (it's called get_page_testzero and
> should probably called get_page_testone).
> The more I think about this the more I think this is the way to go.
> 

Yes, I think that would provide a minimal fix to the problem.
(I'd prefer a solution in which presence on the LRU contributes
to page->count, because that means I can dump a load of expensive
page_cache_get-inside-lru-lock instances, but whatever)

You had:

-#define put_page_testzero(p)   atomic_dec_and_test(&(p)->count)
-#define page_count(p)          atomic_read(&(p)->count)
-#define set_page_count(p,v)    atomic_set(&(p)->count, v)
+#define put_page_testzero(p)   atomic_add_negative(-1, &(p)->count)
+#define page_count(p)          (1+atomic_read(&(p)->count))
+#define set_page_count(p,v)    atomic_set(&(p)->count, v-1)
+#define get_page_testzero(p)   atomic_inc_and_test(&(p)->count)

So the page count is actually offset by -1, and that is hidden by
the macros.  Fair enough.

atomic_add_negative() is not implemented on quite a number of
architectures (sparc64, mips, ppc, sh, cris, 68k, alpha..), so
some legwork is needed there.  Looks to be pretty simple though;
alpha, ppc and others already have atomic_add_return().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
