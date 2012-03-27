Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 124896B00F0
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 11:18:37 -0400 (EDT)
Date: Tue, 27 Mar 2012 16:37:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
Message-ID: <20120327143737.GI5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
 <1332786353.16159.173.camel@twins>
 <4F70C365.8020009@redhat.com>
 <20120326194435.GW5906@redhat.com>
 <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
 <20120326203951.GZ5906@redhat.com>
 <1332837595.16159.208.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332837595.16159.208.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

On Tue, Mar 27, 2012 at 10:39:55AM +0200, Peter Zijlstra wrote:
> You can talk pretty much anything down to O(1) that way. Take an
> algorithm that is O(n) in the number of tasks, since you know you have a
> pid-space constraint of 30bits you can never have more than 2^30 (aka
> 1Gi) tasks, hence your algorithm is O(2^30) aka O(1).

Still this O notation thingy... This is not about the max value but
about the fact the number is _variable_ or _fixed_.

If you have a variable amount of entries (and variable amount of
memory) in a list it's O(N) where N is the number of entries (even if
we know the max ram is maybe 4TB?). If you've a _fixed_ number of them
it's O(1). Even if the fixed number is very large.

It basically shows it won't degraded depending on load, and the cost
per-schedule remains exactly fixed at all times (non liner cacheline
and out-of-order CPU execution/HT effects aside).

If it was O(N) the time this would take to run for each schedule shall
have to vary at runtime depending on a some variable factor N and
that's not the case here.

You can argue about CPU hotplug though.

But this is just math nitpicking because I already pointed out I agree
the cacheline hits on a 1024 way would be measurable and needs fixing.

I'm not sure how useful it is to keep arguing on the O notation when
we agree on what shall be optimized in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
