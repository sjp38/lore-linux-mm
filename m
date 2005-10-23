Date: Sun, 23 Oct 2005 16:41:03 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051023184103.GA7796@logos.cnet>
References: <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet> <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org> <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com> <435A81ED.4040505@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <435A81ED.4040505@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, Oct 22, 2005 at 08:16:13PM +0200, Manfred Spraul wrote:
> Christoph Lameter wrote:
> 
> >The current worst case is 16k pagesize (IA64) and one cacheline sized 
> >objects (128 bytes) (hmm.. could even be smaller if the arch does 
> >overrride SLAB_HWCACHE_ALIGN) yielding a maximum of 128 entries per page. 
> >
> > 
> >
> What about biovec-1? On i386 and 2.6.13 from Fedora, it contains 226 
> entries. And revoke_table contains 290 entries.

Neither are reclaimable however, right:

[marcelo@logos linux-2.6.13]$ find . -type f -exec grep -l set_shrinker {} \;
./fs/dcache.c
./fs/dquot.c
./fs/inode.c
./fs/mbcache.c
./fs/xfs/linux-2.6/kmem.h

If the size of the bitmap for caching the slabbufctl data (which
contains dead/alive information) ends up being a problem, its possible
to:

- increase the bitmap size somehow
- drop the bitmap, acquiring the cache's spinlock and checking directly

Or as a last resort drop the slabbufctl optimization completly, using
cache internal information to obtain dead/alive status.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
