Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 288058D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:02:42 -0500 (EST)
Date: Tue, 22 Feb 2011 19:02:34 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110222180234.GZ5818@one.firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-9-git-send-email-andi@firstfloor.org> <1298392586.9829.22566.camel@nimitz> <20110222164331.GA31195@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222164331.GA31195@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Tue, Feb 22, 2011 at 05:43:31PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 22, 2011 at 08:36:26AM -0800, Dave Hansen wrote:
> > On Mon, 2011-02-21 at 11:07 -0800, Andi Kleen wrote:
> > > From: Andi Kleen <ak@linux.intel.com>
> > > 
> > > I found it difficult to make sense of transparent huge pages without
> > > having any counters for its actions. Add some counters to vmstat
> > > for allocation of transparent hugepages and fallback to smaller
> > > pages.
> > > 
> > > Optional patch, but useful for development and understanding the system.
> > 
> > Very nice.  I did the same thing, splits-only.  I also found this stuff
> > a must-have for trying to do any work with transparent hugepages.  It's
> > just impossible otherwise.
> 
> This patch is good too. 1 and 8 I think can go in, patch 1 is high
> priority.
> 
> Patches 2-5 I've an hard time to see how they're not hurting
> performance instead of improving it, especially patch 3 looks dead

Well right now THP destroys memory locality and that is a quite bad
regression. Destroying memory locality hurts performance significantly.

In general the assumption that you can get the full policy from the 
vma only is wrong: for local you always have to look at the node 
of the existing page too.

I haven't had any reports of KSM doing so, but it seems better
to fix it in the same way. Don't feel very strongly about KSM
for this though, i guess these parts could be dropped too. I guess
you're right and KSM is a bit of a lost cause for NUMA anyways.
Also in my experience KSM is very little memory usually anyways so
it shouldn't matter too much. I guess I can drop that part if it's
controversal.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
