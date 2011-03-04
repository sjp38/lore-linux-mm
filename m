Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BDE6C8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 13:15:00 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	 <1299260164.8493.4071.camel@nimitz>
	 <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 12:14:55 -0600
Message-ID: <1299262495.3062.298.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Theodore Tso <tytso@mit.edu>, Dan Rosenberg <drosenberg@vsecurity.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 09:48 -0800, Linus Torvalds wrote:
> On Fri, Mar 4, 2011 at 9:36 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> >
> > We need to either keep the bad guys away from the counts (this patch),
> > or de-correlate the counts moving around with the position of objects in
> > the slab.  Ted's suggestion is a good one, and the only other thing I
> > can think of is to make the values useless, perhaps by batching and
> > delaying the (exposed) counts by a random amount.
> 
> We might just decide to expose the 'active' count for regular users
> (and then, in case there are tools there that parse this as normal
> users, we could set the 'total' fields to be the same as the active
> one, possibly rounded up to the slab allocation or something.
> 
> I know, I know, from a memory usage standpoint, 'active' is secondary,
> but it still correlates fairly well, so it's still useful.  And for
> seeing memory leaks (as opposed to slab fragmentation etc issues),
> it's actually the interesting case.
> 
> And at the same time, it's actually much less involved with actual
> physical allocations than 'total' is, and thus much less of an attack
> vector. The fact that we got another socket allocation when we opened
> a new socket is not "useful" information for an attacker, not in the
> way it is to see a hint of _where_ the socket got allocated.
> 
> Of course, as you say, '/proc/meminfo' still does give you the trigger
> for "oh, now somebody actually allocated a new page". That's totally
> independent of slabinfo, though (and knowing the number of active
> slabs would neither help nor hurt somebody who uses meminfo - you
> might as well allocate new sockets in a loop, and use _only_ meminfo
> to see when that allocated a new page).

I think lying to the user is much worse than changing the permissions.
The cost of the resulting confusion is WAY higher.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
