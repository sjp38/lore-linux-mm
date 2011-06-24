Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D865B90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 14:54:27 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
In-reply-to: <m2liwrul1f.fsf@firstfloor.org>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com> <m2liwrul1f.fsf@firstfloor.org>
Date: Fri, 24 Jun 2011 14:54:11 -0400
Message-Id: <1308941289-sup-5157@shiny>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Lutomirski <luto@mit.edu>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, intel-gfx <intel-gfx@lists.freedesktop.org>

Excerpts from Andi Kleen's message of 2011-06-24 14:44:12 -0400:
> Andrew Lutomirski <luto@mit.edu> writes:
> 
> [Putting the Intel graphics driver developers in cc.]
> 
> > I'm back :-/
> >
> > I just triggered the kswapd bug on 2.6.39.1, which has the
> > cond_resched in shrink_slab.  This time my system's still usable (I'm
> > tying this email on it), but kswapd0 is taking 100% cpu.  It *does*
> > schedule (tested by setting its affinity the same as another CPU hog
> > and confirming that each one gets 50%).
> >
> > It appears to be calling i915_gem_inactive_shrink in a loop.  I have
> > probes on entry and return of i915_gem_inactive_shrink and on return
> > of shrink_slab.  I see:
> >
> >          kswapd0    47 [000] 59599.956573: mm_vmscan_kswapd_wake: nid=0 order=0
> >          kswapd0    47 [000] 59599.956575: shrink_zone:
> > (ffffffff810c848c) priority=12 zone=ffff8801005fe000
> >          kswapd0    47 [000] 59599.956576: shrink_zone_return:
> > (ffffffff810c848c <- ffffffff810c96c6) arg1=0
> >          kswapd0    47 [000] 59599.956578: i915_gem_inactive_shrink:

A similar trace came up a bunch of times in Jejb's NMI softlockup/kswapd
consumes the machine thread.  That one was tracked down to slub high
order allocations.

I'm sure that one is burned in on Mel's memory, but after a while the
individual traces fell out of the thread, and I'm not sure the i915 part
stuck out.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
