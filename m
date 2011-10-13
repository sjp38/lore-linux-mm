Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 670F36B016F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:50:36 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so655739vcb.14
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:50:35 -0700 (PDT)
Date: Thu, 13 Oct 2011 13:50:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-Id: <20111013135032.7c2c54cd.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1110131052300.18473@router.home>
References: <20111012160202.GA18666@sgi.com>
	<20111012120118.e948f40a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1110121452220.31218@router.home>
	<20111013152355.GB6966@sgi.com>
	<alpine.DEB.2.00.1110131052300.18473@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 13 Oct 2011 10:54:30 -0500 (CDT)
Christoph Lameter <cl@gentwo.org> wrote:

> On Thu, 13 Oct 2011, Dimitri Sivanich wrote:
> 
> > > increase the allowed delta per zone if frequent updates occur via the
> > > overflow checks in vmstat.c. See calculate_*_threshold there.
> >
> > I tried changing the threshold in both directions, with slower throughput in
> > both cases.
> 
> If that is the case check for the vm_stat cacheline being shared with
> another hot kernel variable variable. Maybe that causes cacheline
> eviction.

yup.  `nm -n vmlinux'.

> If there are no updates occurring for a while (due to increased deltas
> and/or vmstat updates) then the vm_stat cacheline should be able to stay
> in shared mode in multiple processors and the performance should increase.
> 

We could cacheline align vm_stat[].  But the thing is pretty small - we
couild put each entry in its own cacheline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
