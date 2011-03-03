Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD43A8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 17:30:06 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
In-Reply-To: <1299188667.3062.259.camel@calx>
References: <1299174652.2071.12.camel@dan>  <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan>  <1299188667.3062.259.camel@calx>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 17:30:00 -0500
Message-ID: <1299191400.2071.203.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> Well if it were a 1000x-1000000x difficulty improvement, I would say you
> had a point. But at 10x, it's just not a real obstacle. For instance, in
> this exploit:
> 
> http://www.exploit-db.com/exploits/14814/
> 
> ..there's already detection of successful smashing, so working around
> not having /proc/slabinfo is as simple as putting the initial smash in a
> loop. I can probably improve my odds of success to nearly 100% by
> pre-allocating a ton of objects all at once to get my own private slab
> page and tidy adjoining allocations. I'll only fail if someone does a
> simultaneous allocation between my target objects or I happen to
> straddle slab pages.
> 

For this particular exploit, the allocation and triggering of the
vulnerability were in separate stages, so that's the case, but other
exploits might have additional constraints.  For example, there is a
public exploit for a two-byte SLUB overflow that relies on a partial
overwrite into a free chunk; exploitation of vulnerabilities similar to
this may be significantly hindered by the lack of availability of this
interface.  Still other issues may only get one shot at exploitation
without needing to clean up corrupted heap state to avoid panicking the
kernel.  In short, every exploit is different, and exposure
of /proc/slabinfo may be the thing that puts some more difficult cases
within reach.

> And once an exploit writer has figured that out once, everyone else just
> copies it (like they've copied the slabinfo technique). At which point,
> we might as well make the file more permissive again.. 
> 

This may be true to some extent, but kernel vulnerabilities tend to be
somewhat varied in terms of exploitation constraints, so I'm not
convinced a general technique would apply to enough cases to render this
change completely pointless.

Many security features, for example NX enforcement, have not proven to
be especially significant in completely mitigating exploitation of
userland memory corruption vulnerabilities by themselves, given the
advent of code-reuse exploitation techniques.  They have also come at
the cost of breaking some applications.  However, the reason we don't
just turn them all off is because they provide SOME hurdle, however
small, and given enough incremental improvements, we eventually get to
the point where things are actually hard.

> > > On the other hand, I'm not convinced the contents of this file are of
> > > much use to people without admin access.
> > > 
> > 
> > Exactly.  We might as well do everything we can to make attackers' lives
> > more difficult, especially when the cost is so low.
> 
> There are thousands of attackers and millions of users. Most of those
> millions are on single-user systems with no local attackers. For every
> attacker's life we make trivially more difficult, we're also making a
> few real user's lives more difficult. It's not obvious that this is a
> good trade-off.
> 

I appreciate your input on this, you've made very reasonable points.
I'm just not convinced that those few real users are being substantially
inconvenienced, even if there's only a small benefit for the larger
population of users who are at risk for attacks.  Perhaps others could
contribute their opinions to the discussion.

-Dan

> -- 
> Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
