Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A64C76B004D
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 23:32:30 -0400 (EDT)
Date: Mon, 27 Apr 2009 20:27:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: meminfo Committed_AS underflows
Message-Id: <20090427202707.9d36ce8a.akpm@linux-foundation.org>
In-Reply-To: <20090428092400.EBB6.A69D9226@jp.fujitsu.com>
References: <20090415084713.GU7082@balbir.in.ibm.com>
	<20090427132722.926b07f1.akpm@linux-foundation.org>
	<20090428092400.EBB6.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ebmunson@us.ibm.com, mel@linux.vnet.ibm.com, cl@linux-foundation.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 12:07:59 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, 15 Apr 2009 14:17:13 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 13:10:06]:
> > > 
> > > > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:
> > > > > 
> > > > > >  	committed = atomic_long_read(&vm_committed_space);
> > > > > > +	if (committed < 0)
> > > > > > +		committed = 0;
> > > > > 
> > 
> > Is there a reason why we can't use a boring old percpu_counter for
> > vm_committed_space?  That way the meminfo code can just use
> > percpu_counter_read_positive().
> > 
> > Or perhaps just percpu_counter_read().  The percpu_counter code does a
> > better job of handling large cpu counts than the
> > mysteriously-duplicative open-coded stuff we have there.
> 
> At that time, I thought smallest patch is better because it can send -stable
> tree easily.
> but maybe I was wrong. it made bikeshed discussion :(

Yes, I know what you mean.  But otoh it's a good idea to keep -stable
in sync with mainline - it means that -stable can merge things which
have had a suitable amount of testing.

> ok, I'm going to right way.
> 
> 
> =========================================
> Subject: [PATCH] fix Committed_AS underfolow on large NR_CPUS environment
> 
> As reported by Dave Hansen, the Committed_AS field can underflow in certain
> situations:
> 
> >         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
> >               1 Committed_AS: 18446744073709323392 kB
> >              11 Committed_AS: 18446744073709455488 kB
> >               6 Committed_AS:    35136 kB
> >               5 Committed_AS: 18446744073709454400 kB
> >               7 Committed_AS:    35904 kB
> >               3 Committed_AS: 18446744073709453248 kB
> >               2 Committed_AS:    34752 kB
> >               9 Committed_AS: 18446744073709453248 kB
> >               8 Committed_AS:    34752 kB
> >               3 Committed_AS: 18446744073709320960 kB
> >               7 Committed_AS: 18446744073709454080 kB
> >               3 Committed_AS: 18446744073709320960 kB
> >               5 Committed_AS: 18446744073709454080 kB
> >               6 Committed_AS: 18446744073709320960 kB
> 
> Because NR_CPUS can be greater than 1000 and meminfo_proc_show() does not check
> for underflow.
> 
> But NR_CPUS proportional isn't good calculation. In general, possibility of
> lock contention is proportional to the number of online cpus, not theorical
> maximum cpus (NR_CPUS).
> the current kernel has generic percpu-counter stuff. using it is right way.
> it makes code simplify and percpu_counter_read_positive() don't make underflow issue.
> 
> 
> Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Eric B Munson <ebmunson@us.ibm.com>
> ---
>  fs/proc/meminfo.c    |    2 +-
>  include/linux/mman.h |    9 +++------
>  mm/mmap.c            |   12 ++++++------
>  mm/nommu.c           |   13 +++++++------
>  mm/swap.c            |   46 ----------------------------------------------
>  5 files changed, 17 insertions(+), 65 deletions(-)

Well that was nice.

There's potential here for weird performance regressions, so I think
that if we do this in mainline, we should wait a while (a few weeks?)
before backporting it.

Do we know how long this bug has existed for?  Quite a while, I expect?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
