Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 274A1900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:42:01 -0400 (EDT)
Date: Thu, 18 Aug 2011 16:41:53 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Message-ID: <20110818144153.GA19920@redhat.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
 <20110818093800.GA2268@redhat.com>
 <96939.1313677618@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96939.1313677618@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, Aug 18, 2011 at 10:26:58AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 18 Aug 2011 11:38:00 +0200, Johannes Weiner said:
> 
> > Note that on non-x86, these operations themselves actually disable and
> > reenable preemption each time, so you trade a pair of add and sub on
> > x86
> > 
> > -	preempt_disable()
> > 	__this_cpu_xxx()
> > 	__this_cpu_yyy()
> > -	preempt_enable()
> > 
> > with
> > 
> > 	preempt_disable()
> > 	__this_cpu_xxx()
> > +	preempt_enable()
> > +	preempt_disable()
> > 	__this_cpu_yyy()
> > 	preempt_enable()
> > 
> > everywhere else.
> 
> That would be an unexpected race condition on non-x86, if you expected _xxx and
> _yyy to be done together without a preempt between them. Would take mere
> mortals forever to figure that one out. :)

That should be fine, we don't require the two counters to be perfectly
coherent with respect to each other, which is the justification for
this optimization in the first place.

But on non-x86, the operation to increase a single per-cpu counter
(read-modify-write) itself is made atomic by disabling preemption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
