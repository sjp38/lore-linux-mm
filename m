Date: Wed, 5 Jan 2000 07:50:51 -0800 (PST)
From: Chris Mason <mason@suse.com>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3? (resending because
 my  ISP probably lost it)
In-Reply-To: <Pine.LNX.4.02.10001051020180.27314-100000@carissimi.coda.cs.cmu.edu>
Message-ID: <Pine.LNX.4.10.10001050732390.18891-100000@home.suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Peter J. Braam" <braam@cs.cmu.edu>
Cc: Hans Reiser <reiser@idiom.com>, Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, reiserfs@devlinux.com, mason@suse.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>


On Wed, 5 Jan 2000, Peter J. Braam wrote:

> I think I mean joining.  What I need is:
>   
>  braam starts trans
>    does A
>    calls reiser: hans starts
>    does B
>    hans commits; nothing goes to disk yet
>    braam does C
> braam commits/aborts ABC now go or don't
> 
> 
Reiserfs won't do this kind of nesting right now, we also don't have a
transaction abort (aside from crashing the machine).  These can be added
to a future version, but would you mind explaining your transaction needs
in more detail (offline) so I can get a better idea of what you are
looking for?

-chris

> - Peter -
> 
> On Wed, 5 Jan 2000, Hans Reiser wrote:
> 
> > Is nesting really the term you mean to use here, or is joining the term you
> > mean?
> > 
> > Do you really mean transactions within other transactions?
> > 
> > Exactly what functionality do you need?
> > 
> > Hans
> > 
> > "Peter J. Braam" wrote:
> > 
> > > Hi,
> > >
> > > I have one request for the journal API for use by network file systems -
> > > it is a request of a slightly different nature than the ones discussed so
> > > far.
> > >
> > > InterMezzo (www.inter-mezzo.org) exploits an existing disk file system as
> > > a cache and wraps around it. (Any disk file system can be used, but so far
> > > only Ext2 has been exploited.)  High availability file systems need update
> > > logs of changes that were made to the cache so that these may be
> > > propagated to peers when they come back online (to support "disconnected
> > > operation").
> > >
> > > Requested feature:
> > > ------------------------------------------------------------------------
> > >
> > > Stephen's journal API has a tremendously useful feature: it allows nesting
> > > of transactions.   I don't know if Reiser has this (can you tell me
> > > Chris?) but it is _incredibly_ useful.  So:
> > >
> > > - InterMezzo can start a journal transaction
> > >  - execute the underlying Ext3 routine within that transaction
> > >    (i.e. the Ext3 transaction becomes part of the one started
> > >     by InterMezzo)
> > > - InterMezzo finishes its routine (e.g. by noting that an update
> > > took place in its update log) and commits or aborts the transaction
> > >
> > > -------------------------------------------------------------------------
> > >
> > > [So, in particular InterMezzo and Ext3 share the journal transaction log.]
> > >
> > > Why is this useful? There are at least two reasons:
> > >
> > >  - the update InterMezzo update log can be kept in sync with the Ext3 file
> > > system as a cache
> > >
> > >  - InterMezzo will soon manage somewhat more metadata (e.g. it may want to
> > > remmeber a global file identifier, similar to a Coda FID or NFS file
> > > handle) and it can make updates to its metadata atomically with updates
> > > made to Ext3 metadata.
> > >
> > > Both of these reasons touch the core architectural decisions of systems
> > > like Coda/AFS/InterMezzo/DCE-DFS -- so there is some historical reason to
> > > be so delighted with what one can do with Stephen's API.
> > >
> > > Presently, systems like Coda and AFS have a hell of a time keeping caches
> > > in sync with the metadata and to a large extent Coda's really bad
> > > performance is caused by this (an external transaction system is used in
> > > conjunction with synchronous operations on the disk file system, ouch...).
> > > InterMezzo will start using the kernel journal facility that should be
> > > much lighter weight.
> > >
> > > Is this a reasonable thing to ask for?
> > >
> > > - Peter -
> > 
> > --
> > Get Linux (http://www.kernel.org) plus ReiserFS
> >  (http://devlinux.org/namesys).  If you sell an OS or
> > internet appliance, buy a port of ReiserFS!  If you
> > need customizations and industrial grade support, we sell them.
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
