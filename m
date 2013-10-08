Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AAA396B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 17:47:37 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so9251957pdj.39
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 14:47:37 -0700 (PDT)
Date: Tue, 8 Oct 2013 16:47:17 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCHv4 00/10] split page table lock for PMD tables
Message-ID: <20131008214717.GE25735@sgi.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131004201213.GB32110@sgi.com>
 <20131004202602.2D389E0090@blue.fi.intel.com>
 <20131004203147.GE32110@sgi.com>
 <20131007094820.13A0CE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131007094820.13A0CE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 07, 2013 at 12:48:20PM +0300, Kirill A. Shutemov wrote:
> Alex Thorlton wrote:
> > > > Sorry for the delay on these results.  I hit some strange issues with
> > > > running thp_memscale on systems with either of the following
> > > > combinations of configuration options set:
> > > > 
> > > > [thp off]
> > > > HUGETLBFS=y
> > > > HUGETLB_PAGE=y
> > > > NUMA_BALANCING=y
> > > > NUMA_BALANCING_DEFAULT_ENABLED=y
> > > > 
> > > > [thp on or off]
> > > > HUGETLBFS=n
> > > > HUGETLB_PAGE=n
> > > > NUMA_BALANCING=y
> > > > NUMA_BALANCING_DEFAULT_ENABLED=y
> > > > 
> > > > I'm getting segfaults intermittently, as well as some weird RCU sched
> > > > errors.  This happens in vanilla 3.12-rc2, so it doesn't have anything
> > > > to do with your patches, but I thought I'd let you know.  There didn't
> > > > used to be any issues with this test, so I think there's a subtle kernel
> > > > bug here.  That's, of course, an entirely separate issue though.
> > > 
> > > I'll take a look next week, if nobody does it before.
> > 
> > I'm starting a bisect now.  Not sure how long it'll take, but I'll keep
> > you posted.
> 
> I don't see the issue. Could you share your kernel config?

I put my kernel config up on ftp at:

ftp://shell.sgi.com/collect/atconfig/config_bug

I've been investigating the issue today and the smallest run I've seen
the problem on was with 128 threads, so this might not be something that
most people will hit.

With the config I've shared here the problem appears to only be
intermittent at 128 threads.  It happened on every run of the test when
I ran it with 512 threads.

Just for something to compare to, here's a config that seems to behave
just fine for any number of threads:

ftp://shell.sgi.com/collect/atconfig/config_good

It looks like this is a problem all the way back to the current 3.8
stable tree.  I'm still working on tracing back to a kernel where this
problem doesn't show up.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
