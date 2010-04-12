Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EDDBC6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:08:35 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:07:48 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412080748.GC18485@elte.hu>
References: <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <20100412070811.GD5656@random.random>
 <20100412072144.GS5683@laptop>
 <4BC2D0C9.3060201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2D0C9.3060201@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/12/2010 10:21 AM, Nick Piggin wrote:
> >>
> >>All data I provided is very real, in addition to building a ton of
> >>packages and running emerge on /usr/portage I've been running all my
> >>real loads. Only problem I only run it for 1 day and half, but the
> >>load I kept it under was significant (surely a lot bigger inode/dentry
> >>load that any hypervisor usage would ever generate).
> >OK, but as a solution for some kind of very specific and highly
> >optimized application already like RDBMS, HPC, hypervisor or JVM,
> >they could just be using hugepages themselves, couldn't they?
> >
> > It seems more interesting as a more general speedup for applications that 
> > can't afford such optimizations? (eg. the common case for most people)
> 
> The problem with hugetlbfs is that you need to commit upfront to using it, 
> and that you need to be the admin.  For virtualization, you want to use 
> hugepages when there is no memory pressure, but you want to use ksm, 
> ballooning, and swapping when there is (and then go back to large pages when 
> pressure is relieved, e.g. by live migration).
> 
> HPC and databases can probably live with hugetlbfs.  JVM is somewhere in the 
> middle, they do allocate memory dynamically.

Even for HPC hugetlbfs is often not good enough: if the data is being 
constantly acquired and put into a file and if it needs to be in persistent 
storage then you dont want to (and cannot) copy it to hugetlbfs (on a poweroff 
you would lose the file).

Furthermore there's also the deployment barrier of marginal improvements: not 
many apps are willing to change for a +0.1% improvement - or even for a +0.9% 
improvement - _especially_ if that improvement also needs admin access and per 
distribution hackery. (each distribution tends to have their own slightly 
different way of handing filesystems and other permission/configuration 
matters)

We've seen that with sendfile() and splice() an it's no different with 
hugetlbs either.

hugetlbfs is basically a non-default poor-man's solution for something that 
the kernel should be providing transparently. It's a bad hack that is good 
enough to prototype that something works, but it has serious deployment, 
configuration and usage limitations. Only a kernel hacker detached from 
everyday application development and packaging constraints can believe that 
it's a high-quality technical solution.

Transparent hugepages eliminates most of the app-visible disadvantages by 
shuffling the problems into the kernel [and no doubt causing follow-on 
headaches there] and by utilizing the 'power of the default' - and thus 
opening up hugetlbs to far more apps. [*]

It's a really simple mechanism.

Thanks,

	Ingo

[*] Note, it would be even better if the kernel provided the C library [a'ka 
    klibc] and if hugetlbs could be utilized via malloc() et al more 
    transparently by us changing the user-space library in the kernel repo and 
    deploying it to apps via a new kernel that provides an updated C library. 
    We dont do that so we are stuck with crappier solutions and slower 
    propagation of changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
