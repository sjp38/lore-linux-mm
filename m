Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2A0CA6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:49:36 -0500 (EST)
Date: Mon, 30 Jan 2012 13:49:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
Message-Id: <20120130134933.39779c48.akpm@linux-foundation.org>
In-Reply-To: <CAOtvUMfAd_f=248PTEW6=fqkBxtEB6oahsiqdUC_i2yjfN9m8w@mail.gmail.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-8-git-send-email-gilad@benyossef.com>
	<20120127161236.ff1e7e7e.akpm@linux-foundation.org>
	<CAOtvUMfAd_f=248PTEW6=fqkBxtEB6oahsiqdUC_i2yjfN9m8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Sun, 29 Jan 2012 14:18:32 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

> On Sat, Jan 28, 2012 at 2:12 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 26 Jan 2012 12:02:00 +0200
> > Gilad Ben-Yossef <gilad@benyossef.com> wrote:
> >
> >> Calculate a cpumask of CPUs with per-cpu pages in any zone
> >> and only send an IPI requesting CPUs to drain these pages
> >> to the buddy allocator if they actually have pages when
> >> asked to flush.
> >>
>
> ...
>
> > Can we end up sending an IPI to a now-unplugged CPU? __That won't work
> > very well if that CPU is now sitting on its sysadmin's desk.
> 
> Nope. on_each_cpu_mask() disables preemption and calls smp_call_function_many()
> which then checks the mask against the cpu_online_mask

OK.

General rule of thumb: if a reviewer asked something then it is likely
that others will wonder the same thing when reading the code later on. 
So consider reviewer questions as a sign that the code needs additional
comments!

> > There's also the case of CPU online. __We could end up failing to IPI a
> > CPU which now has some percpu pages. __That's not at all serious - 90%
> > is good enough in page reclaim. __But this thinking merits a mention in
> > the comment. __Or we simply make this code hotplug-safe.
> 
> hmm.. I'm probably daft but I don't see how to make the code hotplug safe for
> CPU online case. I mean, let's say we disable preemption throughout the
> entire ordeal and then the CPU goes online and gets itself some percpu pages
> *after* we've calculated the masks, sent the IPIs and waiting for the
> whole thing
> to finish but before we've returned...

This is inherent to the whole drain-pages design - it's only a
best-effort thing and there's nothing to prevent other CPUs from
undoing your work 2 nanoseconds later.

The exception to this is the case of suspend, which drains the queues
when all tasks (and, hopefully, IRQs) have been frozen.  This is the
only way to make draining 100% "reliable".

> I might be missing something here, but I think that unless you have some other
> means to stop newly hotplugged CPUs to grab per cpus pages there is nothing
> you can do in this code to stop it. Maybe make the race window
> shorter, that's all.
> 
> Would adding a comment such as the following OK?
> 
> "This code is protected against sending  an IPI to an offline CPU but does not
> guarantee sending an IPI to newly hotplugged CPUs"

Looks OK.  I'd mention *how* this protection comes about:
on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
