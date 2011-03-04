Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D1C978D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:12:59 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <AANLkTimvhHxsMCf2FX0O8VqksOa2EAMz=S_C3LQKvE60@mail.gmail.com>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	 <1299260164.8493.4071.camel@nimitz>
	 <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	 <1299262495.3062.298.camel@calx>
	 <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	 <1299271041.2071.1398.camel@dan>
	 <AANLkTimvhHxsMCf2FX0O8VqksOa2EAMz=S_C3LQKvE60@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 15:12:55 -0600
Message-ID: <1299273175.3062.327.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 22:58 +0200, Pekka Enberg wrote:
> On Fri, Mar 4, 2011 at 10:37 PM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > This patch makes these techniques more difficult by making it hard to
> > know whether the last attacker-allocated object resides before a free or
> > allocated object.  Especially with vulnerabilities that only allow one
> > attempt at exploitation before recovery is needed to avoid trashing too
> > much heap state and causing a crash, this could go a long way.  I'd
> > still argue in favor of removing the ability to know how many objects
> > are used in a given slab, since randomizing objects doesn't help if you
> > know every object is allocated.
> 
> So if the attacker knows every object is allocated, how does that help
> if we're randomizing the initial freelist?

First note that all of these attacks are probabilistic. 

Now, with a randomized free list, if I create 1000 objects of type B,
then, on average, the partially-filled page the next allocation comes
from will be half-full of B objects. Thus, the next object will have a
50% chance of being in the right spot for an exploit. 

Now if I delete the 800th B object, it's probably on a slab that's
otherwise full of B objects since we fill partial slabs before creating
new ones. If my next allocation comes from that slab, it will thus get a
spot that's almost guaranteed to be in the right spot.

Similarly, if I create 1000 objects and then delete every tenth one,
I've now got a swiss cheese heap where just about every hole is
well-positioned. 

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
