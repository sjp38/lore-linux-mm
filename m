Date: Fri, 1 Jun 2007 12:48:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180726713.5278.80.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>  <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
 <1180726713.5278.80.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Lee Schermerhorn wrote:

> > Same here and I wish we had a clean memory region based implementation.
> > But that is just what your patches do *not* provide. Instead they are file 
> > based. They should be memory region based.
> > 
> > Would you please come up with such a solution?
> 
> Christoph:
> 
> I don't understand what you mean by "memory region based".

Memory policies are controlling allocations for regions of memory of a 
process. They are not file based policies (they may have been on Tru64).

> So, for a shared memory mapped file, the inode+address_space--i.e., the
> in-memory incarnation of the file--is as close to a "memory region" as

Not at all. Consider a mmapped memory region by a database. The database
is running on nodes 5-8 and has specified an interleave policy for the 
data.

Now another process starts on node 1 and it also mapped to mmap the same 
file used by the database. It specifies allocation on node 1 and then 
terminates.

Now the database will attempt to satisfy its big memory needs from node 1?

This scheme is not working.

> You're usually gung-ho about locality on a NUMA platform, avoiding off
> node access or page allocations, respecting the fast path, ...  Why the
> resistance here?

Yes I want consistent memory policies. There are already consistency 
issues that need to be solved. Forcing in a Tru64 concept of file memory 
allocation policies will just make the situation worse.

And shmem is not really something that should be taken as a general rule. 
Shmem allocations can be controlled via a kernel boot option. They exist 
even after a process terminates. etc etc.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
