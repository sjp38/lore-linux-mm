Date: Wed, 6 Jun 2001 16:17:04 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
In-Reply-To: <Pine.LNX.4.21.0106061303570.2828-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0106061616310.3769-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, =?iso-8859-1?Q?Andr=E9_Dahlqvist?= <anedah-9@sm.luth.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 6 Jun 2001, Hugh Dickins wrote:

> On Tue, 5 Jun 2001, Marcelo Tosatti wrote:
> > On Tue, 5 Jun 2001, Stephen C. Tweedie wrote:
> > > On Tue, Jun 05, 2001 at 04:48:46PM -0300, Marcelo Tosatti wrote:
> > > > I'm resending the reapswap patch for inclusion into -ac series. 
> > > 
> > > Isn't it broken in this state?  Checking page_count, page->buffers and
> > > PageSwapCache without the appropriate locks is dangerous.
> > 
> > We hold the pagemap_lru_lock, so there will be no one doing lookups on
> > this swap page (get_swapcache_page() locks pagemap_lru_lock).
> > 
> > Am I overlooking something here? 
> 
> mm/shmem.c:shmem_getpage_locked() and mm/swapfile.c:try_to_unuse()
> call delete_from_swap_cache_nolock(), both holding page lock,
> neither holding pagemap_lru_lock.
> 
> Unless you hold the page lock, PageSwapCache(page) and page->index
> are volatile, but to find swap_count(page) you have to rely on both
> of them.  TryLockPage()?

Thanks for the comments. 

I'll post a new patch which uses TryLockPage soon.

Thanks! 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
