Date: Wed, 7 May 2008 17:56:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <alpine.LFD.1.10.0805071655100.3024@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0805071752490.14829@schroedinger.engr.sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
 <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
 <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
 <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org>
 <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0805071610490.3024@woody.linux-foundation.org>
 <Pine.LNX.4.64.0805071637360.14337@schroedinger.engr.sgi.com>
 <alpine.LFD.1.10.0805071655100.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 7 May 2008, Linus Torvalds wrote:

> On Wed, 7 May 2008, Christoph Lameter wrote:
> > 
> > Multiple vmas may share the same mapping or refer to the same anonymous 
> > vma. The above code will deadlock since we may take some locks multiple 
> > times.
> 
> Ok, so that actually _is_ a problem. It would be easy enough to also add 
> just a flag to the vma (VM_MULTILOCKED), which is still cleaner than doing 
> a vmalloc and a whole sort thing, but if this is really rare, maybe Ben's 
> suggestion of just using stop-machine is actually the right one just 
> because it's _so_ simple.

Set the vma flag when we locked it and then skip when we find it locked 
right? This would be in addition to the global lock?

stop-machine would work for KVM since its a once in a Guest OS time of 
thing. But GRU, KVM and eventually Infiniband need the ability to attach 
in a reasonable timeframe without causing major hiccups for other 
processes.

> (That said, we're not running out of vm flags yet, and if we were, we 
> could just add another word. We're already wasting that space right now on 
> 64-bit by calling it "unsigned long").

We sure have enough flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
