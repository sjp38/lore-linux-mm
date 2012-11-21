Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 56FF26B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 17:16:00 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <habanero@linux.vnet.ibm.com>;
	Wed, 21 Nov 2012 15:15:59 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C16563E40041
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:15:54 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qALMFuHW329564
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:15:56 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qALMHmwf008186
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:17:49 -0700
Subject: Re: numa/core regressions fixed - more testers wanted
From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Reply-To: habanero@linux.vnet.ibm.com
In-Reply-To: <20121121115255.GA8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
	 <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>
	 <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>
	 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	 <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com>
	 <20121120175647.GA23532@gmail.com>
	 <1353462853.31820.93.camel@oc6622382223.ibm.com>
	 <20121121115255.GA8218@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Nov 2012 16:15:52 -0600
Message-ID: <1353536152.31820.112.camel@oc6622382223.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Wed, 2012-11-21 at 11:52 +0000, Mel Gorman wrote:
> On Tue, Nov 20, 2012 at 07:54:13PM -0600, Andrew Theurer wrote:
> > On Tue, 2012-11-20 at 18:56 +0100, Ingo Molnar wrote:
> > > * Ingo Molnar <mingo@kernel.org> wrote:
> > > 
> > > > ( The 4x JVM regression is still an open bug I think - I'll
> > > >   re-check and fix that one next, no need to re-report it,
> > > >   I'm on it. )
> > > 
> > > So I tested this on !THP too and the combined numbers are now:
> > > 
> > >                                           |
> > >   [ SPECjbb multi-4x8 ]                   |
> > >   [ tx/sec            ]  v3.7             |  numa/core-v16
> > >   [ higher is better  ] -----             |  -------------
> > >                                           |
> > >               +THP:      639k             |       655k            +2.5%
> > >               -THP:      510k             |       517k            +1.3%
> > > 
> > > So it's not a regression anymore, regardless of whether THP is 
> > > enabled or disabled.
> > > 
> > > The current updated table of performance results is:
> > > 
> > > -------------------------------------------------------------------------
> > >   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
> > >   [ lower is better ]   -----  --------   |  -------------    -----------
> > >                                           |
> > >   numa01                340.3    192.3    |      139.4          +144.1%
> > >   numa01_THREAD_ALLOC   425.1    135.1    |	 121.1          +251.0%
> > >   numa02                 56.1     25.3    |       17.5          +220.5%
> > >                                           |
> > >   [ SPECjbb transactions/sec ]            |
> > >   [ higher is better         ]            |
> > >                                           |
> > >   SPECjbb 1x32 +THP      524k     507k    |	  638k           +21.7%
> > >   SPECjbb 1x32 !THP      395k             |       512k           +29.6%
> > >                                           |
> > > -----------------------------------------------------------------------
> > >                                           |
> > >   [ SPECjbb multi-4x8 ]                   |
> > >   [ tx/sec            ]  v3.7               numa/core-v16
> > >   [ higher is better  ] -----             |  -------------
> > >                                           |
> > >               +THP:      639k             |       655k            +2.5%
> > >               -THP:      510k             |       517k            +1.3%
> > > 
> > > So I think I've addressed all regressions reported so far - if 
> > > anyone can still see something odd, please let me know so I can 
> > > reproduce and fix it ASAP.
> > 
> > I can confirm single JVM JBB is working well for me.  I see a 30%
> > improvement over autoNUMA.  What I can't make sense of is some perf
> > stats (taken at 80 warehouses on 4 x WST-EX, 512GB memory):
> > 
> 
> I'm curious about possible effects with profiling. Can you rerun just
> this test without any profiling and see if the gain is the same? My own
> tests are running monitors but they only fire every 10 seconds and are
> not running profiles.

After using the patch Hugh provided, I did make a 2nd run, this time
with no profiling at all, and the run was 2% higher.  Not sure if this
is due to profiling gone, or just run to run variance, but nevertheless
a pretty low difference.

-Andrew Theurer


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
