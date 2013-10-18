Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA756B00E6
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 20:33:12 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so3699791pdi.19
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 17:33:12 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:33:34 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131018003334.GG422@sgi.com>
References: <20131016155429.GP25735@sgi.com>
 <CAA_GA1cnzro65e_qZO3WbJAWGM-R6RgpxhogE_SUmFYdQ5A36g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1cnzro65e_qZO3WbJAWGM-R6RgpxhogE_SUmFYdQ5A36g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Oct 17, 2013 at 07:30:58PM +0800, Bob Liu wrote:
> Hi Alex,
> 
> On Wed, Oct 16, 2013 at 11:54 PM, Alex Thorlton <athorlton@sgi.com> wrote:
> > Hi guys,
> >
> > I ran into a bug a week or so ago, that I believe has something to do
> > with NUMA balancing, but I'm having a tough time tracking down exactly
> > what is causing it.  When running with the following configuration
> > options set:
> >
> > CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
> > CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> > CONFIG_NUMA_BALANCING=y
> > # CONFIG_HUGETLBFS is not set
> > # CONFIG_HUGETLB_PAGE is not set
> >
> 
> What's your kernel version?
> And did you enable CONFIG_TRANSPARENT_HUGEPAGE ?

Ah, two important things that I forgot to include!  The kernel I
originally spotted the problem on was 3.11 and it continued to be an
issue up through 3.12-rc4, but after running a 30-trial run of the
test today, it appears that the issue must have cleared up after the
3.12-rc5 release on Monday.  I'll still include the requested
information, but I guess this is no longer an issue.

I rolled all the way back to 3.7 while researching the issue, and that
appears to be the last kernel where the problem didn't show up.  3.8
is the first kernel where the bug appears; I believe this is also the
kernel where NUMA balancing was officially introduced.

Here are my settings related to THP:

CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set

I did most of my testing with THP set to "always", although the problem
still occurs with THP set to "never".  

> 
> > I get intermittent segfaults when running the memscale test that we've
> > been using to test some of the THP changes.  Here's a link to the test:
> >
> > ftp://shell.sgi.com/collect/memscale/
> >
> > I typically run the test with a line similar to this:
> >
> > ./thp_memscale -C 0 -m 0 -c <cores> -b <memory>
> >
> > Where <cores> is the number of cores to spawn threads on, and <memory>
> > is the amount of memory to reserve from each core.  The <memory> field
> > can accept values like 512m or 1g, etc.  I typically run 256 cores and
> > 512m, though I think the problem should be reproducable on anything with
> > 128+ cores.
> >
> > The test never seems to have any problems when running with hugetlbfs
> > on and NUMA balancing off, but it segfaults every once in a while with
> > the config options above.  It seems to occur more frequently, the more
> > cores you run on.  It segfaults on about 50% of the runs at 256 cores,
> > and on almost every run at 512 cores.  The fewest number of cores I've
> > seen a segfault on has been 128, though it seems to be rare on this many
> > cores.
> >
> 
> Could you please attach some logs?

Here are the relevant chunks from the syslog for a 10-shot run at 256
cores, each chunk is from a separate run.  4 out of 10 failed with
segfaults:

Oct 17 11:36:41 harp83-sys kernel: thp_memscale[21566]: segfault at 0 ip           (null) sp 00007ff8531fcdc0 error 14 in thp_memscale[400000+5000]
Oct 17 11:36:41 harp83-sys kernel: thp_memscale[21565]: segfault at 0 ip           (null) sp 00007ff8539fddc0 error 14 in thp_memscale[400000+5000]
---
Oct 17 12:08:14 harp83-sys kernel: thp_memscale[22893]: segfault at 0 ip           (null) sp 00007ff69cffddc0 error 14 in thp_memscale[400000+5000]
---
Oct 17 12:26:30 harp83-sys kernel: thp_memscale[23995]: segfault at 0 ip           (null) sp 00007fe7af1fcdc0 error 14 in thp_memscale[400000+5000]
Oct 17 12:26:30 harp83-sys kernel: thp_memscale[23994]: segfault at 0 ip           (null) sp 00007fe7af9fddc0 error 14 in thp_memscale[400000+5000]
---
Oct 17 12:32:29 harp83-sys kernel: thp_memscale[24116]: segfault at 0 ip           (null) sp 00007ff77a9fcdc0 error 14 in thp_memscale[400000+5000]

Since this has cleared up in the latest release, I won't be pursuing the
issue any further (though I'll keep an eye out to make sure that it
doesn't show back up).  I am, however, still curious as to what the
cause of the problem was...

> 
> > At this point, I'm not familiar enough with NUMA balancing code to know
> > what could be causing this, and we don't typically run with NUMA
> > balancing on, so I don't see this in my everyday testing, but I felt
> > that it was definitely worth bringing up.
> >
> > If anybody has any ideas of where I could poke around to find a
> > solution, please let me know.
> >
> 
> -- 
> Regards,
> --Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
