Date: Sun, 2 Jan 2000 15:24:48 -0700 (MST)
From: "Peter J. Braam" <braam@cs.cmu.edu>
Subject: Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <Pine.GSO.4.05.9912260325130.3937-100000@aa.eps.jhu.edu>
Message-ID: <Pine.LNX.4.10.10001021506350.12799-100000@wolf.rockies.stelias.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>

Hi, 


I have one request for the journal API for use by network file systems -
it is a request of a slightly different nature than the ones discussed so
far.

InterMezzo (www.inter-mezzo.org) exploits an existing disk file system as
a cache and wraps around it. (Any disk file system can be used, but so far
only Ext2 has been exploited.)  High availability file systems need update
logs of changes that were made to the cache so that these may be
propagated to peers when they come back online (to support "disconnected
operation").


Requested feature: 
------------------------------------------------------------------------

Stephen's journal API has a tremendously useful feature: it allows nesting
of transactions.   I don't know if Reiser has this (can you tell me
Chris?) but it is _incredibly_ useful.  So: 

- InterMezzo can start a journal transaction
 - execute the underlying Ext3 routine within that transaction 
   (i.e. the Ext3 transaction becomes part of the one started 
    by InterMezzo)
- InterMezzo finishes its routine (e.g. by noting that an update
took place in its update log) and commits or aborts the transaction

-------------------------------------------------------------------------

[So, in particular InterMezzo and Ext3 share the journal transaction log.]

Why is this useful? There are at least two reasons:

 - the update InterMezzo update log can be kept in sync with the Ext3 file
system as a cache

 - InterMezzo will soon manage somewhat more metadata (e.g. it may want to
remmeber a global file identifier, similar to a Coda FID or NFS file
handle) and it can make updates to its metadata atomically with updates
made to Ext3 metadata.

Both of these reasons touch the core architectural decisions of systems
like Coda/AFS/InterMezzo/DCE-DFS -- so there is some historical reason to
be so delighted with what one can do with Stephen's API.

Presently, systems like Coda and AFS have a hell of a time keeping caches
in sync with the metadata and to a large extent Coda's really bad
performance is caused by this (an external transaction system is used in
conjunction with synchronous operations on the disk file system, ouch...).
InterMezzo will start using the kernel journal facility that should be
much lighter weight.

Is this a reasonable thing to ask for? 

- Peter -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
