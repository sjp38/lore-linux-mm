From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Tue, 18 Sep 2007 09:56:06 -0700
References: <20070814142103.204771292@sgi.com> <200709172211.26493.phillips@phunq.net> <20070918115836.1394a051@twins>
In-Reply-To: <20070918115836.1394a051@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709180956.07772.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Snitzer <snitzer@gmail.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>, Wouter Verhelst <w@uter.be>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
List-ID: <linux-mm.kvack.org>

On Tuesday 18 September 2007 02:58, Peter Zijlstra wrote:
> On Mon, 17 Sep 2007 22:11:25 -0700 Daniel Phillips wrote:
> > > I've been using Avi Kivity's patch from some time ago:
> > > http://lkml.org/lkml/2004/7/26/68
> >
> > Yes.  Ddsnap includes a bit of code almost identical to that, which
> > we wrote independently.  Seems wild and crazy at first blush,
> > doesn't it? But this approach has proved robust in practice, and is
> > to my mind, obviously correct.
>
> I'm so not liking this :-(

Why don't you share your specific concerns?

> Can't we just run the user-space part as mlockall and extend netlink
> to work with PF_MEMALLOC where needed?
>
> I did something like that for iSCSI.

Not sure what you mean by extend netlink.  We do run the user daemons 
under mlockall of course, this is one of the rules I stated earlier for 
daemons running in the block IO path.  The problem is, if this 
userspace daemon allocates even one page, for example in sys_open, it 
can deadlock.  Running the daemon in PF_MEMALLOC mode fixes this 
problem robustly, provided that the necessary audit of memory 
allocation patterns and library dependencies has been done.

I suppose you are worried that the userspace code could unexpectedly 
allocate a large amount of memory and exhaust the entire PF_MEMALLOC 
reserve?  Kernel code could do that too.  This userspace code just 
needs to be checked carefully.  Perhaps we could come up with a kernel 
debugging option to verify that a task does in fact stay within some 
bounded number of page allocs while in PF_MEMALLOC mode.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
