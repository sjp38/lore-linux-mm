Date: Thu, 8 May 2008 07:49:31 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508054931.GB8276@duo.random>
References: <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com> <20080508025652.GW8276@duo.random> <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com> <20080508034133.GY8276@duo.random> <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org> <20080508052019.GA8276@duo.random> <84144f020805072227i3382465eleccded79d9fcf532@mail.gmail.com> <84144f020805072230g2a619d65x8e3bb1fbf9d130d8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020805072230g2a619d65x8e3bb1fbf9d130d8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 08:30:20AM +0300, Pekka Enberg wrote:
> On Thu, May 8, 2008 at 8:27 AM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > You might want to read carefully what Linus wrote:
> >
> >  > The one that already has a 4 byte padding thing on x86-64 just after the
> >  > spinlock? And that on 32-bit x86 (with less than 256 CPU's) would have two
> >  > bytes of padding if we didn't just make the spinlock type unconditionally
> >  > 32 bits rather than the 16 bits we actually _use_?
> >
> >  So you need to add the flag _after_ ->lock and _before_ ->head....
> 
> Oh should have taken my morning coffee first, before ->lock works
> obviously as well.

Sorry, Linus's right: I didn't realize the "after the spinlock" was
literally after the spinlock, I didn't see the 4 byte padding when I
read the code and put the flag:1 in. If put between ->lock and ->head
it doesn't take more memory on x86-64 as described literlly. So the
next would be to find another place like that in the address
space. Perhaps after the private_lock using the same trick or perhaps
the slab alignment won't actually alter the number of slabs per page
regardless.

I leave that to Christoph, he's surely better than me at doing this, I
give it up entirely and I consider my attempt to merge a total failure
and I strongly regret it.

On a side note the anon_vma will change to this when XPMEM support is
compiled in:

 struct anon_vma {
-	spinlock_t lock;	/* Serialize access to vma list */
+	atomic_t refcount;	/* vmas on the list */
+	struct rw_semaphore sem;/* Serialize access to vma list */
 	struct list_head head;	   /* List of private "related" vmas
	*/
 };

not sure if it'll grow in size or not after that but let's say it's
not a big deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
