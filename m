Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 55A0C6B005A
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 08:31:12 -0500 (EST)
Message-ID: <4F01B187.7060008@redhat.com>
Date: Mon, 02 Jan 2012 15:30:47 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com> <1321960128-15191-5-git-send-email-gilad@benyossef.com> <alpine.LFD.2.02.1111230822270.1773@tux.localdomain> <4F00547A.9090204@redhat.com> <CAOtvUMcCzK=tNkHudOrzxjdGkdkZPt02krO8QYRGjyXm+cvRSw@mail.gmail.com> <4F008ECA.5040703@redhat.com> <CAOtvUMfWKpXaR6Ph1ZN6g0QhgmZtbcf=hMSgtkD-1pLpkzSuNA@mail.gmail.com>
In-Reply-To: <CAOtvUMfWKpXaR6Ph1ZN6g0QhgmZtbcf=hMSgtkD-1pLpkzSuNA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, apkm@linux-foundation.org

On 01/02/2012 01:59 PM, Gilad Ben-Yossef wrote:
> On Sun, Jan 1, 2012 at 6:50 PM, Avi Kivity <avi@redhat.com> wrote:
> > On 01/01/2012 06:12 PM, Gilad Ben-Yossef wrote:
> >> >
> >> > Since this seems to be a common pattern, how about:
> >> >
> >> >   zalloc_cpumask_var_or_all_online_cpus(&cpus, GFTP_ATOMIC);
> >> >   ...
> >> >   free_cpumask_var(cpus);
> >> >
> >> > The long-named function at the top of the block either returns a newly
> >> > allocated zeroed cpumask, or a static cpumask with all online cpus set.
> >> > The code in the middle is only allowed to set bits in the cpumask
> >> > (should be the common usage).  free_cpumask_var() needs to check whether
> >> > the freed object is the static variable.
> >>
> >> Thanks for the feedback and advice! I totally agree the repeating
> >> pattern needs abstracting.
> >>
> >> I ended up chosing to try a different abstraction though - basically a wrapper
> >> on_each_cpu_cond that gets a predicate function to run per CPU to
> >> build the mask
> >> to send the IPI to. It seems cleaner to me not having to mess with
> >> free_cpumask_var
> >> and it abstracts more of the general pattern.
> >>
> >
> > This converts the algorithm to O(NR_CPUS) from a potentially lower
> > complexity algorithm.  Also, the existing algorithm may not like to be
> > driven by cpu number.  Both are true for kvm.
> >
>
> Right, I was only thinking on my own uses, which are O(NR_CPUS) by nature.
>
> I wonder if it would be better to create a safe_cpumask_var type with
> its own alloc function
> free and and sset_cpu function but no clear_cpu function so that the
> compiler will catch
> cases of trying to clear bits off of such a cpumask?
>
> It seems safer and also makes handling the free function easier.
>
> Does that makes sense or am I over engineering it? :-)

It makes sense.  Depends on the number of call sites, really.  If there
are several, consolidation helps, also makes it easier to further refactor.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
