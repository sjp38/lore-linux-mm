Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C1DCB6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 04:10:29 -0400 (EDT)
Date: Tue, 21 May 2013 09:10:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
Message-ID: <20130521081020.GT11497@suse.de>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130517154837.GN11497@suse.de>
 <20130519205219.GA3252@cerebellum>
 <20130520135439.GR11497@suse.de>
 <20130520154225.GA25536@cerebellum>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130520154225.GA25536@cerebellum>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 20, 2013 at 10:42:25AM -0500, Seth Jennings wrote:
> On Mon, May 20, 2013 at 02:54:39PM +0100, Mel Gorman wrote:
> > On Sun, May 19, 2013 at 03:52:19PM -0500, Seth Jennings wrote:
> > > My first guess is that the external fragmentation situation you are referring to
> > > is a workload in which all pages compress to greater than half a page.  If so,
> > > then it doesn't matter what NCHUCNKS_ORDER is, there won't be any pages the
> > > compress enough to fit in the < PAGE_SIZE/2 free space that remains in the
> > > unbuddied zbud pages.
> > > 
> > 
> > There are numerous aspects to this, too many to write them all down.
> > Modelling the external fragmentation one and how it affects swap IO
> > would be a complete pain in the ass so lets consider the following
> > example instead as it's a bit clearer.
> > 
> > Three processes. Process A compresses by 75%, Process B compresses to 15%,
> > Process C pages compress to 15%. They are all adding to zswap in lockstep.
> > Lets say that zswap can hold 100 physical pages.
> > 
> > NCHUNKS == 2
> > 	All Process A pages get rejected.
> 
> Ah, I think this is our disconnect.  Process A pages will not be rejected.
> They will be stored in a zbud page, and that zbud page will be added
> to the 0th unbuddied list.  This list maintains a list of zbud pages
> that will never be buddied because there are no free chunks.
> 

D'oh, good point. Unfortunately, the problem then still exists at the
writeback end which I didn't bring up in the previous mail. Take three
processes writing in lockstep. Process A pages compress to 15%, B compresses
to 15%, C compresses to 60%. Each physical page packing will look like this

nchunks=6	nchunks = 2

Page 0	A B	A B
Page 1	C A	C
Page 2	B C	A B
Page 3	A B	C
Pattern repeats..........

This continues until zswap is full. Now all three process stop and process
D starts writing to zswap, each of its pages compresses to 80%. These will
be freed in LRU order which is effectively FIFO.

With nchunks=6, to store 2 process D pages, it must write out 4 pages
to swap.  With nchunks=2, to store two process D pages, it must write 3
pages so process D stalls for less time with nchunks==2.

This is a variation of the zsmalloc packing problem where greater packing
leads to worse performance when zswap is full. The user bug report will
look something like "performance goes to hell when zswap is full although
swap IO rates look normal". If it was a kernel parameter, setting nchunk=2
as a kernel boot parameter will at least be a workaround.

Of course, this is all hypothetical. It is certainly possible to create
a reference string where nchunks=2 generates more IO but it tends to
generate the IO sooner and more closely resemble existing swap behaviour
that users might be willing to accept as a workaround until their problem
can be resolved. This is why I think the parameter should be available at
boot-time as a debugging/workaround option for developers to recommend to
a user.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
