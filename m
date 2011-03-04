Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C60B8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:08:33 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
In-Reply-To: <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	 <1299260164.8493.4071.camel@nimitz>
	 <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	 <1299262495.3062.298.camel@calx>
	 <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	 <1299270709.3062.313.camel@calx> <1299271377.2071.1406.camel@dan>
	 <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 16:08:27 -0500
Message-ID: <1299272907.2071.1415.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 22:56 +0200, Pekka Enberg wrote:
> On Fri, 2011-03-04 at 14:31 -0600, Matt Mackall wrote:
> >> On Fri, 2011-03-04 at 22:02 +0200, Pekka Enberg wrote:
> >> > On Fri, Mar 4, 2011 at 8:14 PM, Matt Mackall <mpm@selenic.com> wrote:
> >> > >> Of course, as you say, '/proc/meminfo' still does give you the trigger
> >> > >> for "oh, now somebody actually allocated a new page". That's totally
> >> > >> independent of slabinfo, though (and knowing the number of active
> >> > >> slabs would neither help nor hurt somebody who uses meminfo - you
> >> > >> might as well allocate new sockets in a loop, and use _only_ meminfo
> >> > >> to see when that allocated a new page).
> >> > >
> >> > > I think lying to the user is much worse than changing the permissions.
> >> > > The cost of the resulting confusion is WAY higher.
> >> >
> >> > Yeah, maybe. I've attached a proof of concept patch that attempts to
> >> > randomize object layout in individual slabs. I'm don't completely
> >> > understand the attack vector so I don't make any claims if the patch
> >> > helps or not.
> >>
> >> In general, the attack relies on getting an object A (vulnerable to
> >> overrun) immediately beneath an object B (that can be exploited when
> >> overrun).
> >>
> >> I'm not sure how much randomization helps, though. Allocate 1000 objects
> >> of type B, deallocate the 800th, then allocate an object of type A. It's
> >> almost certainly next to a B.
> 
> On Fri, Mar 4, 2011 at 10:42 PM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > On second thought, this does pose a problem.  Even if you don't know how
> > full the most recent slab is or where free vs. used chunks are within
> > it, if you can guarantee that you filled an entire previous slab with
> > your objects and then free and reallocate one of them, then you can
> > still win.
> 
> Guys, I still don't get it, sorry.
> 
> Why can you still win? With my patch, reallocation shouldn't matter;
> the freelist randomization ought to make it less likely for *any* two
> allocated objects to be adjacent.
> 

I could be mistaken on this, so feel free to correct me.  What if you
just fill more than one slab with the object you'd like to overflow
into, then pick an object that's guaranteed to reside in a slab filled
with your objects.  Upon freeing that object and allocating a new
to-be-overflowed object (that's sized so it's handled by the same slab
cache), this new object will be guaranteed to be sitting immediately
before one of your objects (or before the end of the slab if you're
unlucky).  You can still win because it doesn't matter which specific
object you overflow, only that you overflow one of them.

-Dan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
