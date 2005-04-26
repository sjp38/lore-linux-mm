Date: Tue, 26 Apr 2005 03:33:59 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 6/8 page_referenced(): move dirty
Message-Id: <20050426033359.228bcd09.akpm@osdl.org>
In-Reply-To: <17006.5587.396660.728303@gargle.gargle.HOWL>
References: <16994.40677.105697.817303@gargle.gargle.HOWL>
	<20050425210016.6f8a47d1.akpm@osdl.org>
	<17006.127.376459.93584@gargle.gargle.HOWL>
	<20050426015518.2df35139.akpm@osdl.org>
	<17006.2975.791376.558683@gargle.gargle.HOWL>
	<20050426030517.0a72ee14.akpm@osdl.org>
	<17006.5587.396660.728303@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Andrew Morton writes:
>  > Nikita Danilov <nikita@clusterfs.com> wrote:
>  > >
>  > > Andrew Morton writes:
>  > >   > Nikita Danilov <nikita@clusterfs.com> wrote:
>  > >   > >
>  > >   > >   > 
>  > >   > >   > I can envision workloads (such as mmap 80% of memory and continuously dirty
>  > >   > >   > it) which would end up performing continuous I/O with this patch.
>  > >   > > 
>  > >   > >  Below is a version that tries to move dirtiness to the struct page only
>  > >   > >  if we are really going to deactivate the page. In your scenario above,
>  > >   > >  continuously dirty pages will be on the active list, so it should be
>  > >   > >  okay.
>  > >   > 
>  > >   > OK, well it'll now increase the amount of I/O by a smaller amount.  Trade
>  > >   > that off against possibly improved I/O patterns.  But how do we know that
>  > >   > all this is a net gain?
>  > > 
>  > >  By looking at the (micro-) benchmarking results:
>  > > 
>  > >  2.6.12-rc2:
>  > > 
>  > >  before-patch page_referenced-move-dirty
>  > > 
>  > >          45.8  32.3
>  > >         204.3  93.2
>  > >         194.8  89.5
>  > >         194.9  89.9
>  > >         197.7  92.1
>  > >         195.0  90.2
>  > >         199.4  89.5
>  > >         196.3  89.2
>  > 
>  > hm.  What's the reason for such a large difference?  That workload should
> 
> Early write-out from pdflush and balance_dirty_pages()?

ah, much less dirty memory around.  Yes, it might be something to do with
that.

The difference is so large that we really should understand the precise
reason rather than guessing though.  It might point at some problem in the
lru-based page-at-a-time writeback which we can fix.

>  > just be doing pretty-much-linear write even if we're writing a
>  > page-at-a-time off the tail of the LRU.
>  > 
>  > Was that box SMP?
> 
> Single P4 with HT; file system is ext3.

OK.  Sometimes writeback-off-the-lru goes poorly on SMP (half the speed)
due to the two CPUs performing writeout to different parts of the disk.  Or
something like that.  Just a simple memset(malloc(lots)) swapstorm
demonstrates it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
