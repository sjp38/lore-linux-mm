Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 63BF96B007E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:26:28 -0400 (EDT)
Message-ID: <1332933968.2528.26.camel@twins>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 28 Mar 2012 13:26:08 +0200
In-Reply-To: <20120327161540.GS5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
	 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
	 <1332786353.16159.173.camel@twins> <4F70C365.8020009@redhat.com>
	 <20120326194435.GW5906@redhat.com>
	 <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
	 <20120326203951.GZ5906@redhat.com> <1332837595.16159.208.camel@twins>
	 <20120327161540.GS5906@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

On Tue, 2012-03-27 at 18:15 +0200, Andrea Arcangeli wrote:
> This is _purely_ a performance optimization so if my design is so bad,
> and you're also requiring all apps that spans over more than one NUMA
> node to be modified to use your new syscalls, you won't have problems
> to win against AutoNUMA in the benchmarks.=20

Right, so can we agree that the only case where they diverge is single
processes that have multiple threads and are bigger than a single node (eit=
her
in memory, cputime or both)?

I've asked you several times why you care about that one case so much, but
without answer.

I'll grant you that unmodified such processes might do better with your
stuff, however:

 - your stuff assumes there is a fair amount of locality to exploit.

   I'm not seeing how this is true in general, since data partitioning is h=
ard
   and for those problems where its possible people tend to already do so,
   yielding natural points to add the syscalls.

 - your stuff doesn't actually nest, since a guest kernel has no clue as to
   what constitutes a node (or if there even is such a thing) it will rando=
mly
   move tasks around on the vcpus, with complete disrespect for whatever ho=
st
   vcpu<->page mappings you set up.

   guest kernels actively scramble whatever relations you're building by
   scanning, destroying whatever (temporal) locality you think you might
   have found.

 - also, by not exposing NUMA to the guest kernel, the guest kernel/userspa=
ce
   has no clue it needs to behave as if there's multiple nodes etc..

Furthermore, most applications that are really big tend to have already tho=
ught
about parallelism and have employed things like data-parallelism if at all
possible. If this is not possible (many problems fall in this category) the=
re
really isn't much you can do.

Related to this is that all applications that currently use mbind() and
sched_setaffinity() are trivial to convert.

Also, really big threaded programs have a natural enemy, the shared state t=
hat
makes it a process, most dominantly the shared address space (mmap_sem etc.=
.).

There's also the reason Avi mentioned, core count tends to go up, which mea=
ns
nodes are getting bigger and bigger.

But most importantly, your solution is big, complex and costly specifically=
 to
handle this case which, as per the above reasons, I think is not very
interesting.

So why not do the simple thing first before going overboard for a case that
might be irrelevant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
