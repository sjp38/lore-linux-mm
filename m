Date: Thu, 13 Jan 2005 10:27:06 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
In-Reply-To: <20050113.170218.77038944.taka@valinux.co.jp>
Message-ID: <Pine.LNX.4.58.0501131022190.31154@skynet>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB008C77C45@fmsmsx406.amr.corp.intel.com>
 <Pine.LNX.4.58.0501122247390.18142@skynet> <20050113.170218.77038944.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: matthew.e.tolentino@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2005, Hirokazu Takahashi wrote:

> Hi Mel,
>
> The global list looks interesting.
>
> > > >Instead of having one global MAX_ORDER-sized array of free
> > > >lists, there are
> > > >three, one for each type of allocation. Finally, there is a
> > > >list of pages of
> > > >size 2^MAX_ORDER which is a global pool of the largest pages
> > > >the kernel deals with.
>
> > > is it so that the pages can
> > > evolve according to system demands (assuming MAX_ORDER sized
> > > chunks are eventually available again)?
> > >
> >
> > Exactly. Once a 2^MAX_ORDER block has been merged again, it will not be
> > reserved until the next split.
>
> FYI, MAX_ORDER is huge in some architectures.
> I guess another watermark should be introduced instead of MAX_ORDER.
>

It could be, but remember that the watermark will decide what the largest
non-fragmented block-size will be and I am not sure that is something
architectures really want. i.e. why would an architecture not want to push
to have the largest possible block available?

If they did really want the option, I could add MAX_FRAG_ORDER (ok, bad
name but it's morning) that architectures can optionally define. then in
the main code, just

#ifndef MAX_FRAG_ORDER
  #define MAX_FRAG_ORDER MAX_ORDER
#endif

The global lists would then be expected to hold the lists between
MAX_FRAG_ORDER and MAX_ORDER. Would that make sense and would
architectures really want it? If yes, I can code it up.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
