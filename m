Date: Thu, 8 May 2008 05:41:33 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508034133.GY8276@duo.random>
References: <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com> <20080508025652.GW8276@duo.random> <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 08:10:33PM -0700, Christoph Lameter wrote:
> On Thu, 8 May 2008, Andrea Arcangeli wrote:
> 
> > to the sort function to break the loop. After that we remove the 512
> > vma cap and mm_lock is free to run as long as it wants like
> > /dev/urandom, nobody can care less how long it will run before
> > returning as long as it reacts to signals.
> 
> Look Linus has told you what to do. Why not simply do it?

When it looked like we could use vm_flags to remove sort, that looked
an ok optimization, no problem with optimizations, I'm all for
optimizations if they cost nothing to the VM fast paths and VM footprint.

But removing sort isn't worth it if it takes away ram from the VM even
when global_mm_lock will never be called.

sort is like /dev/urandom so after sort is fixed to handle signals
(and I expect Matt will help with this) we'll remove the 512 vmas cap.
In the meantime we can live with the 512 vmas cap that guarantees sort
won't take more than a few dozen usec. Removing sort() is the only
thing that the anon vma bitflag can achieve and it's clearly not worth
it and it would go in the wrong direction (fixing sort to handle
signals is clearly the right direction, if sort is a concern at all).

Adding the global lock around global_mm_lock to avoid one
global_mm_lock to collide against another global_mm_lock is sure ok
with me, if that's still wanted now that it's clear removing sort
isn't worth it, I'm neutral on this.

Christoph please go ahead and add the bitflag to anon-vma yourself if
you want. If something isn't technically right I don't do it no matter
who asks it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
