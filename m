Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DF9F88D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:44:31 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1299186986.2071.90.camel@dan>
References: <1299174652.2071.12.camel@dan>  <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 15:44:27 -0600
Message-ID: <1299188667.3062.259.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-03-03 at 16:16 -0500, Dan Rosenberg wrote:
> > 
> > Looking at a couple of these exploits, my suspicion is that looking at
> > slabinfo simply improves the odds of success by a small factor (ie 10x
> > or so) and doesn't present a real obstacle to attackers. All that
> > appears to be required is to arrange that an overrunnable object be
> > allocated next to one that is exploitable when overrun. And that can be
> > arranged with fairly high probability on SLUB's merged caches.
> > 
> 
> This is accurate, but the primary goal of exploit mitigation isn't
> necessarily to completely prevent the possibility of exploitation (time
> has shown that this is unlikely to be feasible), but rather to increase
> the cost of investment required to develop a reliable exploit.  If
> removing read access to /proc/slabinfo means that heap exploits are even
> slightly more likely to fail, then that's a win as far as I'm concerned
> and may be the thing that prevents some helpless end user from getting
> compromised.

Well if it were a 1000x-1000000x difficulty improvement, I would say you
had a point. But at 10x, it's just not a real obstacle. For instance, in
this exploit:

http://www.exploit-db.com/exploits/14814/

..there's already detection of successful smashing, so working around
not having /proc/slabinfo is as simple as putting the initial smash in a
loop. I can probably improve my odds of success to nearly 100% by
pre-allocating a ton of objects all at once to get my own private slab
page and tidy adjoining allocations. I'll only fail if someone does a
simultaneous allocation between my target objects or I happen to
straddle slab pages.

And once an exploit writer has figured that out once, everyone else just
copies it (like they've copied the slabinfo technique). At which point,
we might as well make the file more permissive again.. 

> > On the other hand, I'm not convinced the contents of this file are of
> > much use to people without admin access.
> > 
> 
> Exactly.  We might as well do everything we can to make attackers' lives
> more difficult, especially when the cost is so low.

There are thousands of attackers and millions of users. Most of those
millions are on single-user systems with no local attackers. For every
attacker's life we make trivially more difficult, we're also making a
few real user's lives more difficult. It's not obvious that this is a
good trade-off.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
