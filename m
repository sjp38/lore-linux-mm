Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 466366B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:56:37 -0400 (EDT)
Message-ID: <4F67217B.40205@redhat.com>
Date: Mon, 19 Mar 2012 14:07:23 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>   <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>  <4F671B90.3010209@redhat.com> <1332158367.18960.308.camel@twins>
In-Reply-To: <1332158367.18960.308.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 01:59 PM, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 13:42 +0200, Avi Kivity wrote:
> > > Now if you want to be able to scan per-thread, you need per-thread
> > > page-tables and I really don't want to ever see that. That will blow
> > > memory overhead and context switch times.
> > 
> > I thought of only duplicating down to the PDE level, that gets rid of
> > almost all of the overhead. 
>
> You still get the significant CR3 cost for thread switches. 

True.  Not so much for virt, which has one thread per cpu generally.

> [ /me grabs the SDM to find that PDE is what we in Linux call the pmd ]

Yes, sorry.

> That'll cut the memory overhead down but also the severely impact the
> accuracy.
>
> Also, I still don't see how such a scheme would correctly identify
> per-cpu memory in guest kernels. While less frequent its still very
> common to do remote access to per-cpu data. So even if you did page
> granularity you'd get a fair amount of pages that are accesses by all
> threads (vcpus) in the scan interval, even thought they're primarily
> accesses by just one.
>
> If you go to pmd level you get even less information.

That is true.  Which is why I like the explicit vnode thing.  The guest
kernel already knows how to affine vcpus to memory, we don't need to
scan to see if it's actually doing what we told it to do.  Scanning is
good for unmodified non-virt applications, or to prioritize the migration.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
