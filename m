Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB026B0180
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:24:38 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3969337pzk.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:24:36 -0700 (PDT)
Date: Thu, 13 Oct 2011 14:24:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-Id: <20111013142434.4d05cbdc.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1110131602020.26553@router.home>
References: <20111012160202.GA18666@sgi.com>
	<20111012120118.e948f40a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1110121452220.31218@router.home>
	<20111013152355.GB6966@sgi.com>
	<alpine.DEB.2.00.1110131052300.18473@router.home>
	<20111013135032.7c2c54cd.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1110131602020.26553@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 13 Oct 2011 16:02:58 -0500 (CDT)
Christoph Lameter <cl@gentwo.org> wrote:

> On Thu, 13 Oct 2011, Andrew Morton wrote:
> 
> > > If there are no updates occurring for a while (due to increased deltas
> > > and/or vmstat updates) then the vm_stat cacheline should be able to stay
> > > in shared mode in multiple processors and the performance should increase.
> > >
> >
> > We could cacheline align vm_stat[].  But the thing is pretty small - we
> > couild put each entry in its own cacheline.
> 
> Which in turn would increase the cache footprint of some key kernel
> functions (because they need multiple vm_stat entries) and cause eviction
> of other cachelines that then reduce overall system performance again.

Sure, but we gain performance by not having different CPUs treading on
each other when they update different vmstat fields.  Sometimes one
effect will win and other times the other effect will win.  Some
engineering is needed..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
