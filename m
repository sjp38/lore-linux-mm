Message-ID: <3D757F11.B72BB708@zip.com.au>
Date: Tue, 03 Sep 2002 20:33:37 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm1
References: <200209032251.54795.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> On September 3, 2002 09:13 pm, Andrew Morton wrote:
> 
> > ext3_inode_cache     959   2430    448  264  270    1
> >
> > That's 264 pages in use, 270 total.  If there's a persistent gap between
> > these then there is a problem - could well be that slablru is not locating
> > the pages which were liberated by the pruning sufficiently quickly.
> 
> Sufficiently quickly is a relative thing.

Those pages are useless!  It's silly having slab hanging onto them
while we go and reclaim useful pagecache instead.

I *really* think we need to throw away those pages instantly.

The only possible reason for hanging onto them is because they're
cache-warm.  And we need a global-scope cpu-local hot pages queue
anyway.

And once we have that, slab _must_ release its warm pages into it.
It's counterproductive for slab to hang onto warm pages when, say,
a pagefault needs one.

>  It could also be that by the time the
> pages are reclaimed another <n> have been cleaned.  IMO its no worst than
> have freeable pages on lru from any other source.  If we get close to oom
> we will call kmem_cache_reap, otherwise we let the lru find the pages.

As I say, by not releasing those (useless to slab) pages, we're causing
other (useful) stuff to be reclaimed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
