Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EF1C56B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 14:43:05 -0500 (EST)
Date: Mon, 3 Dec 2012 14:42:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121203194208.GZ24381@cmpxchg.org>
References: <20121127222637.GG2301@cmpxchg.org>
 <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
 <20121128101359.GT8218@suse.de>
 <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de>
 <50B77F84.1030907@leemhuis.info>
 <20121129170512.GI2301@cmpxchg.org>
 <50B8A8E7.4030108@leemhuis.info>
 <20121201004520.GK2301@cmpxchg.org>
 <50BC6314.7060106@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BC6314.7060106@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

On Mon, Dec 03, 2012 at 09:30:12AM +0100, Thorsten Leemhuis wrote:
> >> John was able to reproduce the problem quickly with a kernel that 
> >> contained the patch from your mail. For details see
> >
> > [stripped: all the glory details of what likely went wrong and lead
> > to the problem john sees or saw]
> >
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] mm: vmscan: do not keep kswapd looping forever due
> >  to individual uncompactable zones
> > 
> > When a zone meets its high watermark and is compactable in case of
> > higher order allocations, it contributes to the percentage of the
> > node's memory that is considered balanced.
> > [...]
> 
> FYI: I built a kernel with that patch. I've been running on my x86_64
> machine at home over the weekend and everything was working fine (just
> as without the patch). John gave it a quick try and in
> https://bugzilla.redhat.com/show_bug.cgi?id=866988#c57 reported:
> 
> """
> I just installed
> kernel-3.7.0-0.rc7.git1.2.van.main.knurd.kswap.4.fc18.i686 and ran my
> usual load that triggers the problem.  OK so far.  I'll check again in
> 24hours, but looking good so far.
> """

w00t!

> BTW, I built that kernel without the patch you mentioned in
> http://thread.gmane.org/gmane.linux.kernel.mm/90911/focus=91153
> ("buffer_heads_over_limit can put kswapd into reclaim, but it's ignored
> [...]) It looked to me like that patch was only meant for debugging. Let
> me know if that was wrong. Ohh, and I didn't update to a fresher
> mainline checkout yet to make sure the base for John's testing didn't
> change.

Ah, yes, the ApplyPatch is commented out.

I think we want that upstream as well, but it's not critical.  It'll
reduce kswapd CPU usage marginally on highmem systems in certain
situations, but I don't think any of the 100% CPU usage problems are
fixed by it.

Not rebasing sounds reasonable to me to verify the patch.  It might be
worth testing that the final version that will be 3.8 still works for
John, however, once that is done.  Just to be sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
