Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 36AD48D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 12:37:16 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p24HBufC027781
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 12:11:57 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 800906E8036
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 12:36:14 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p24HaEaC221496
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 12:36:14 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p24HaDj9019051
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 12:36:13 -0500
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
References: <1299174652.2071.12.camel@dan>	<1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan>	<1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 04 Mar 2011 09:36:04 -0800
Message-ID: <1299260164.8493.4071.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Theodore Tso <tytso@mit.edu>, Dan Rosenberg <drosenberg@vsecurity.com>, Matt Mackall <mpm@selenic.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 08:52 +0200, Pekka Enberg wrote:
> On Fri, Mar 4, 2011 at 2:50 AM, Theodore Tso <tytso@mit.edu> wrote:
> > Being able to monitor /proc/slabinfo is incredibly useful for finding various
> > kernel problems.  We can see if some part of the kernel is out of balance,
> > and we can also find memory leaks.   I once saved a school system's Linux
> > deployment because their systems were crashing once a week, and becoming
> > progressively more unreliable before they crashed, and the school board
> > was about to pull the plug.
> 
> Indeed. However, I'm not sure we need to expose the number of _active
> objects_ to non-CAP_ADMIN users (which could be set to zeros if you
> don't have sufficient privileges). Memory leaks can be detected from
> the total number of objects anyway, no? 

This:

	http://www.exploit-db.com/exploits/14814/

loops doing allocations until total==active, and then does one more
allocation to get the position in the slab it needs.  If we mask
'active', it'll just loop until 'total' gets bumped, and then consider
the _previous_ allocation to have been the one that was in the necessary
position.

As Ted mentioned, the real issue here is being able to infer location
inside the slab by correlating your allocations with when the slab
statistics get bumped.  You can do that with slabinfo pretty precisely,
but you can probably also pull it off with meminfo too, albeit with less
precision.

We need to either keep the bad guys away from the counts (this patch),
or de-correlate the counts moving around with the position of objects in
the slab.  Ted's suggestion is a good one, and the only other thing I
can think of is to make the values useless, perhaps by batching and
delaying the (exposed) counts by a random amount.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
