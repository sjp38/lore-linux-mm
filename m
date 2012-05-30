Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 587566B0062
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:06:31 -0400 (EDT)
Message-ID: <1338368763.26856.207.camel@twins>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 30 May 2012 11:06:03 +0200
In-Reply-To: <4FC5D973.3080108@gmail.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	   <1337965359-29725-14-git-send-email-aarcange@redhat.com>
	  <1338297385.26856.74.camel@twins> <4FC4D58A.50800@redhat.com>
	 <1338303251.26856.94.camel@twins> <4FC5D973.3080108@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, 2012-05-30 at 04:25 -0400, KOSAKI Motohiro wrote:
> (5/29/12 10:54 AM), Peter Zijlstra wrote:
> > On Tue, 2012-05-29 at 09:56 -0400, Rik van Riel wrote:
> >> On 05/29/2012 09:16 AM, Peter Zijlstra wrote:
> >>> On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> >>
> >>> 24 bytes per page.. or ~0.6% of memory gone. This is far too great a
> >>> price to pay.
> >>>
> >>> At LSF/MM Rik already suggested you limit the number of pages that ca=
n
> >>> be migrated concurrently and use this to move the extra list_head out=
 of
> >>> struct page and into a smaller amount of extra structures, reducing t=
he
> >>> total overhead.
> >>
> >> For THP, we should be able to track this NUMA info on a
> >> 2MB page granularity.
> >
> > Yeah, but that's another x86-only feature, _IF_ we're going to do this
> > it must be done for all archs that have CONFIG_NUMA, thus we're stuck
> > with 4k (or other base page size).
>=20
> Even if THP=3Dn, we don't need 4k granularity. All modern malloc implemen=
tation have
> per-thread heap (e.g. glibc call it as arena) and it is usually 1-8MB siz=
e. So, if
> it is larger than 2MB, we can always use per-pmd tracking. iow, memory co=
nsumption
> reduce to 1/512.

Yes, and we all know objects allocated in one thread are never shared
with other threads.. the producer-consumer pattern seems fairly popular
and will destroy your argument.

> My suggestion is, track per-pmd (i.e. 2M size) granularity and fix glibc =
too (current
> glibc malloc has dynamically arena size adjusting feature and then it oft=
en become
> less than 2M).

The trouble with making this per pmd is that you then get the false
sharing per pmd, so if there's shared data on the 2m page you'll not
know where to put it.

I also know of some folks who did a strict per-cpu allocator based on
some kernel patches I hope to see posted sometime soon. This because if
you have many more threads than cpus the wasted space in your areas is
tremendous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
