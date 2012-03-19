Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 31CC56B00E8
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 07:59:49 -0400 (EDT)
Message-ID: <1332158367.18960.308.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 12:59:27 +0100
In-Reply-To: <4F671B90.3010209@redhat.com>
References: <20120316144028.036474157@chello.nl>
	  <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	 <4F671B90.3010209@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 13:42 +0200, Avi Kivity wrote:
> > Now if you want to be able to scan per-thread, you need per-thread
> > page-tables and I really don't want to ever see that. That will blow
> > memory overhead and context switch times.
>=20
> I thought of only duplicating down to the PDE level, that gets rid of
> almost all of the overhead.=20

You still get the significant CR3 cost for thread switches.=20

[ /me grabs the SDM to find that PDE is what we in Linux call the pmd ]

That'll cut the memory overhead down but also the severely impact the
accuracy.

Also, I still don't see how such a scheme would correctly identify
per-cpu memory in guest kernels. While less frequent its still very
common to do remote access to per-cpu data. So even if you did page
granularity you'd get a fair amount of pages that are accesses by all
threads (vcpus) in the scan interval, even thought they're primarily
accesses by just one.

If you go to pmd level you get even less information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
