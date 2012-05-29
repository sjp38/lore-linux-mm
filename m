Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EB7C06B0070
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:53:38 -0400 (EDT)
Date: Tue, 29 May 2012 10:53:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
In-Reply-To: <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205291033360.6723@router.home>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <4FC112AB.1040605@redhat.com> <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On Sat, 26 May 2012, Linus Torvalds wrote:

>
> I'm a *firm* believer that if it cannot be done automatically "well
> enough", the absolute last thing we should ever do is worry about the
> crazy people who think they can tweak it to perfection with complex
> interfaces.
>
> You can't do it, except for trivial loads (often benchmarks), and for
> very specific machines.

NUMA APIs already exist that allow tuning for the NUMA cases by allowing
the application to specify where to get memory from and where to run the
threads of a process. Those require the application to be aware of the
NUMA topology and exploit the capabilities there explicitly. Typically one
would like to reserve processors and memory for a single application that
then does the distribution of the load on its own. NUMA aware applications
like that do not benefit and do not need either of the mechanisms proposed
here.

What these automatic migration schemes (autonuma is really a bad term for
this. These are *migration* schemes where the memory is moved between NUMA
nodes automatically so call it AutoMigration if you like) try to do is to
avoid the tuning bits and automatically distribute generic process loads
in a NUMA aware fashion in order to improve performance. This is no easy
task since the cost of migrating a page is much more expensive that the
additional latency due to access of memory from a distant node. A huge
number of accesses must occur in order to amortize the migration of a
page. Various companies in decades past have tried to implement
automigration schemes without too much success.

I think the proof that we need is that a general mix of applications
actually benefits from an auto migration scheme. I would also like to see
that it does no harm to existing NUMA aware applications.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
