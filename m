Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A04CB6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:34:59 -0400 (EDT)
Date: Wed, 2 Jun 2010 23:33:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
	of !mm to skip kthreads
Message-ID: <20100602213331.GA31949@redhat.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com> <20100602223612.F52D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/02, David Rientjes wrote:
>
> On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:
>
> > > Again, the question is whether or not the fix is rc material or not,
> > > otherwise there's no difference in the route that it gets upstream: the
> > > patch is duplicated in both series.  If you feel that this minor issue
> > > (which has never been reported in at least the last three years and
> > > doesn't have any side effects other than a couple of millisecond delay
> > > until unuse_mm() when the oom killer will kill something else) should be
> > > addressed in 2.6.35-rc2, then that's a conversation to be had with Andrew.
> >
> > Well, we have bugfix-at-first development rule. Why do you refuse our
> > development process?
>
> This isn't a bugfix, it simply prevents a recall to the oom killer after
> the kthread has called unuse_mm().  Please show where any side effects of
> oom killing a kthread, which cannot exit, as a result of use_mm() causes a
> problem _anywhere_.

I already showed you the side effects, but you removed this part in your
reply.

>From http://marc.info/?l=linux-kernel&m=127542732121077

	It can't die but force_sig() does bad things which shouldn't be done
	with workqueue thread. Note that it removes SIG_IGN, sets
	SIGNAL_GROUP_EXIT, makes signal_pending/fatal_signal_pedning true, etc.

A workqueue thread must not run with SIGNAL_GROUP_EXIT set, SIGKILL
must be ignored, signal_pending() must not be true.

This is bug. It is minor, agreed, currently use_mm() is only used by aio.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
