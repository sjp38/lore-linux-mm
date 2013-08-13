Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E80D86B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 18:26:23 -0400 (EDT)
Date: Tue, 13 Aug 2013 15:26:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
Message-Id: <20130813152622.f15dcaaa672ba182308ce29f@linux-foundation.org>
In-Reply-To: <520AAF9C.1050702@tilera.com>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
	<201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
	<20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
	<52099187.80301@tilera.com>
	<20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
	<20130813201958.GA28996@mtj.dyndns.org>
	<20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
	<520A9E4A.2050203@tilera.com>
	<20130813141329.c55deccf462f3ad49129bbca@linux-foundation.org>
	<520AAF9C.1050702@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 13 Aug 2013 18:13:48 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:

> On 8/13/2013 5:13 PM, Andrew Morton wrote:
> > On Tue, 13 Aug 2013 16:59:54 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:
> >
> >>> Then again, why does this patchset exist?  It's a performance
> >>> optimisation so presumably someone cares.  But not enough to perform
> >>> actual measurements :(
> >> The patchset exists because of the difference between zero overhead on
> >> cpus that don't have drainable lrus, and non-zero overhead.  This turns
> >> out to be important on workloads where nohz cores are handling 10 Gb
> >> traffic in userspace and really, really don't want to be interrupted,
> >> or they drop packets on the floor.
> > But what is the effect of the patchset?  Has it been tested against the
> > problematic workload(s)?
> 
> Yes.  The result is that syscalls such as mlockall(), which otherwise interrupt
> every core, don't interrupt the cores that are running purely in userspace.
> Since they are purely in userspace they don't have any drainable pagevecs,
> so the patchset means they don't get interrupted and don't drop packets.
> 
> I implemented this against Linux 2.6.38 and our home-grown version of nohz
> cpusets back in July 2012, and we have been shipping it to customers since then.

argh.

Those per-cpu LRU pagevecs were a nasty but very effective locking
amortization hack back in, umm, 2002.  They have caused quite a lot of
weird corner-case behaviour, resulting in all the lru_add_drain_all()
calls sprinkled around the place.  I'd like to nuke the whole thing,
but that would require a fundamental rethnik/rework of all the LRU list
locking.

According to the 8891d6da17db0f changelog, the lru_add_drain_all() in
sys_mlock() isn't really required: "it isn't must.  but it reduce the
failure of moving to unevictable list.  its failure can rescue in
vmscan later.  but reducing is better."

I suspect we could just kill it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
