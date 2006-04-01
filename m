Date: Sun, 2 Apr 2006 04:30:38 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-ID: <20060401183038.GY27189130@melbourne.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com> <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com> <20060331153235.754deb0c.akpm@osdl.org> <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com> <20060331160032.6e437226.akpm@osdl.org> <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com> <20060331172518.40a5b03d.akpm@osdl.org> <20060401155942.E961681@wobbly.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060401155942.E961681@wobbly.melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@melbourne.sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 01, 2006 at 03:59:42PM +1000, Nathan Scott wrote:
> On Fri, Mar 31, 2006 at 05:25:18PM -0800, Andrew Morton wrote:
> > Christoph Lameter <clameter@sgi.com> wrote:
> > ...
> > It appears that we're being busy in xfs_iextract(), but it would be sad if
> > the problem was really lock contention in xfs_iextract(), and we just
> > happened to catch it when it was running.
> > 
> > Or maybe xfs_iextract is just slow.  So this is one thing we need to get to
> > the bottom of (profiles might tell us).
> 
> I assume (profiles would be good to prove it) we are spending
> time walking the hash bucket list there Christoph (while we're
> holding the ch_lock spinlock on the hash bucket)?  [CC'ing Dave
> Chinner for any further comment, he's been looking at the chash
> list for unrelated reasons recently..]

You'll only get contention if something else is trying to walk the
same hash chain, which tends to implicate not enough hash buckets.

> If its useful for experimenting, Christoph, you can easily tweak the
> cluster hash size manually by dinking with xfs_iget.c::xfs_chash_init.

Just use the ihashsize mount option - the cluster hash size is proportional
to the inode hash size which is changed by the ihashsize mount option.

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
