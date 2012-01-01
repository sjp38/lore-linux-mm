Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 64FA06B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 11:50:39 -0500 (EST)
Message-ID: <4F008ECA.5040703@redhat.com>
Date: Sun, 01 Jan 2012 18:50:18 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com> <1321960128-15191-5-git-send-email-gilad@benyossef.com> <alpine.LFD.2.02.1111230822270.1773@tux.localdomain> <4F00547A.9090204@redhat.com> <CAOtvUMcCzK=tNkHudOrzxjdGkdkZPt02krO8QYRGjyXm+cvRSw@mail.gmail.com>
In-Reply-To: <CAOtvUMcCzK=tNkHudOrzxjdGkdkZPt02krO8QYRGjyXm+cvRSw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, apkm@linux-foundation.org

On 01/01/2012 06:12 PM, Gilad Ben-Yossef wrote:
> >
> > Since this seems to be a common pattern, how about:
> >
> >   zalloc_cpumask_var_or_all_online_cpus(&cpus, GFTP_ATOMIC);
> >   ...
> >   free_cpumask_var(cpus);
> >
> > The long-named function at the top of the block either returns a newly
> > allocated zeroed cpumask, or a static cpumask with all online cpus set.
> > The code in the middle is only allowed to set bits in the cpumask
> > (should be the common usage).  free_cpumask_var() needs to check whether
> > the freed object is the static variable.
>
> Thanks for the feedback and advice! I totally agree the repeating
> pattern needs abstracting.
>
> I ended up chosing to try a different abstraction though - basically a wrapper
> on_each_cpu_cond that gets a predicate function to run per CPU to
> build the mask
> to send the IPI to. It seems cleaner to me not having to mess with
> free_cpumask_var
> and it abstracts more of the general pattern.
>

This converts the algorithm to O(NR_CPUS) from a potentially lower
complexity algorithm.  Also, the existing algorithm may not like to be
driven by cpu number.  Both are true for kvm.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
