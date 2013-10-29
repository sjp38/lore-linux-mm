Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 99A7C6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 05:42:34 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so8154089pdj.9
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:42:34 -0700 (PDT)
Received: from psmtp.com ([74.125.245.126])
        by mx.google.com with SMTP id gw3si15349773pac.288.2013.10.29.02.42.17
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 02:42:18 -0700 (PDT)
Date: Tue, 29 Oct 2013 09:42:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Automatic NUMA balancing patches for tip-urgent/stable
Message-ID: <20131029094208.GB2400@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
 <20131026121148.GC24439@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131026121148.GC24439@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Oct 26, 2013 at 02:11:48PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Oct 07, 2013 at 11:28:38AM +0100, Mel Gorman wrote:
> > > This series has roughly the same goals as previous versions despite the
> > > size. It reduces overhead of automatic balancing through scan rate reduction
> > > and the avoidance of TLB flushes. It selects a preferred node and moves tasks
> > > towards their memory as well as moving memory toward their task. It handles
> > > shared pages and groups related tasks together. Some problems such as shared
> > > page interleaving and properly dealing with processes that are larger than
> > > a node are being deferred. This version should be ready for wider testing
> > > in -tip.
> > > 
> > 
> > Hi Ingo,
> > 
> > Off-list we talked with Peter about the fact that automatic NUMA
> > balancing as merged in 3.10, 3.11 and 3.12 shortly may corrupt
> > userspace memory. There is one LKML report on this that I'm aware of --
> > https://lkml.org/lkml/2013/7/31/647 which I prompt forgot to follow up
> > properly on . The user-visible effect is that pages get filled with zeros
> > with results such as null pointer exceptions in JVMs. It is fairly difficult
> > to trigger but it became much easier to trigger during the development of
> > the series "Basic scheduler support for automatic NUMA balancing" which
> > is how it was discovered and finally fixed.
> > 
> > In that series I tagged patches 2-9 for -stable as these patches addressed
> > the problem for me. I did not call it out as clearly as I should have
> > and did not realise the cc: stable tags were stripped. Worse, as it was
> > close to the release and the bug is relatively old I was ok with waiting
> > until 3.12 came out and then treat it as a -stable backport. It has been
> > highlighted that this is the wrong attitude and we should consider merging
> > the fixes now and backporting to -stable sooner rather than later.
> > 
> > The most important patches are 
> > 
> > mm: Wait for THP migrations to complete during NUMA hinting fault
> > mm: Prevent parallel splits during THP migration
> > mm: Close races between THP migration and PMD numa clearing
> > 
> > but on their own they will cause conflicts with tricky fixups and -stable
> > would differ from mainline in annoying ways. Patches 2-9 have been heavily
> > tested in isolation so I'm reasonably confident they fix the problem and are
> > -stable material. While strictly speaking not all the patches are required
> > for the fix, the -stable kernels would then be directly comparable with
> > 3.13 when the full NUMA balancing series is applied. If I rework them at
> > this point then I'll also have to retest delaying things until next week.
> > 
> > Please consider queueing patches 2-9 for 3.12 via -urgent if it is 
> > not too late and preserve the cc: stable tags so Greg will pick 
> > them up automatically.
> 
> Would be nice if you gave me all the specific SHA1 tags of 
> sched/core that are required for the fix. We can certainly
> use a range to make it all safer to apply.
> 

Of course. The range of the relevant commits in tip/sched/core is
ca4be374c5c0ab3d8b84fb2861d663216281e6ac..778ec5247bb79815af12434980164334fb94cc9e

904f64a376e663cd459fb7aec4f12e14c39c24b6 mm: numa: Document automatic NUMA balancing sysctls
1d649bccc8c1370e402b85e1d345ad24f3f0d1b5 sched, numa: Comment fixlets
f961cab8d55d55d6abc0df08ce2abec8ab56f2c8 mm: numa: Do not account for a hinting fault if we raced
6f2a15fc1df62af3ba3be327877b7e53cb16e878 mm: Wait for THP migrations to complete during NUMA hinting faults
4ee547f994c633f2607d222e2c6385b6fe5f07d8 mm: Prevent parallel splits during THP migration
dd83227f0d93fb37d7621a24e8465b13b437faa6 mm: numa: Sanitize task_numa_fault() callsites
efeeacf7b94babff85da7e468fc5450fdfab0900 mm: Close races between THP migration and PMD numa clearing
778ec5247bb79815af12434980164334fb94cc9e mm: Account for a THP NUMA hinting update as one PTE update

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
