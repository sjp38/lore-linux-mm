Message-ID: <3B3840CD.B60448EB@uow.edu.au>
Date: Tue, 26 Jun 2001 17:59:09 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [RFC] VM statistics to gather
References: <3B380E7B.6609337F@uow.edu.au> <Pine.LNX.4.21.0106260206240.1676-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
> On Tue, 26 Jun 2001, Andrew Morton wrote:
> 
> > Rik van Riel wrote:
> > >
> > > Hi,
> > >
> > > I am starting the process of adding more detailed instrumentation
> > > to the VM subsystem and am wondering which statistics to add.
> > > A quick start of things to measure are below, but I've probably
> > > missed some things. Comments are welcome ...
> >
> > Neat.
> >
> > - bdflush wakeups
> > - pages written via page_launder's writepage by kswapd
> > - pages written via page_launder's writepage by non-PF_MEMALLOC
> >   tasks.  (ext3 has an interest in this because of nasty cross-fs
> >   reentrancy and journal overflow problems with writepage)
> 
> Does ext3 call page_launder() with __GFP_IO ?
> 
> If it does not (which I believe so), page_launder() without PF_MEMALLOC
> never happens.

OK, I was using PF_MEMALLOC as shorthand for `kswapd', with
unsuccessful accuracy.  I think it's OK to block non-kswapd
tasks in writepage() while we open a new transaction, but it's
perhaps not so good to block kswapd there.

At present, if the caller is PF_MEMALLOC we make a non-blocking
attempt to open a transaction handle.  If it fails, redirty the
page and return.  It usually succeeds.  This may be excessively
paranoid.

I haven't played with it a lot recently, but it may turn out to
be useful to know whether the caller is kswapd or someone else,
and it'd be nice to know the calling context by means other than
inferring it from PF_MEMALLOC.  What happened to the writepage
`priority' patch you had, BTW?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
