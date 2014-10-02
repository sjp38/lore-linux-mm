Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 827C46B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:54:25 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so1557509vcb.29
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:54:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si3125110vcq.96.2014.10.02.08.54.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 08:54:24 -0700 (PDT)
Date: Thu, 2 Oct 2014 17:53:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: get_user_pages_locked|unlocked to leverage VM_FAULT_RETRY
Message-ID: <20141002155348.GI2342@redhat.com>
References: <20140926172535.GC4590@redhat.com>
 <20141001153611.GC2843@worktop.programming.kicks-ass.net>
 <20141002123117.GB2342@redhat.com>
 <20141002125052.GF2849@worktop.programming.kicks-ass.net>
 <20141002125638.GE6324@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141002125638.GE6324@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Thu, Oct 02, 2014 at 02:56:38PM +0200, Peter Zijlstra wrote:
> On Thu, Oct 02, 2014 at 02:50:52PM +0200, Peter Zijlstra wrote:
> > On Thu, Oct 02, 2014 at 02:31:17PM +0200, Andrea Arcangeli wrote:
> > > On Wed, Oct 01, 2014 at 05:36:11PM +0200, Peter Zijlstra wrote:
> > > > For all these and the other _fast() users, is there an actual limit to
> > > > the nr_pages passed in? Because we used to have the 64 pages limit from
> > > > DIO, but without that we get rather long IRQ-off latencies.
> > > 
> > > Ok, I would tend to think this is an issue to solve in gup_fast
> > > implementation, I wouldn't blame or modify the callers for it.
> > > 
> > > I don't think there's anything that prevents gup_fast to enable irqs
> > > after certain number of pages have been taken, nop; and disable the
> > > irqs again.
> > > 
> > 
> > Agreed, I once upon a time had a patch set converting the 2 (x86 and
> > powerpc) gup_fast implementations at the time, but somehow that never
> > got anywhere.
> > 
> > Just saying we should probably do that before we add callers with
> > unlimited nr_pages.
> 
> https://lkml.org/lkml/2009/6/24/457
> 
> Clearly there's more work these days. Many more archs grew a gup.c

What about this? The alternative is that I do s/gup_fast/gup_unlocked/
to still retain the mmap_sem scalability benefit. It'd be still better
than the current plain gup() (and it would be equivalent for
userfaultfd point of view).

Or if the below is ok, should I modify all other archs too or are the
respective maintainers going to fix it themself? For example the arm*
gup_fast is a moving target in development on linux-mm right now and I
should only patch the gup_rcu version that didn't hit upstream yet. In
fact after that gup_rcu merge, supposedly the powerpc and sparc
gup_fast can be dropped from arch/* entirely and they can use the
generic version (otherwise having the arm gup_fast in mm/ instead of
arch/ would be a mistake). Right now, I wouldn't touch at least
arm/sparc/powerpc until the gup_rcu hit upstream as those are all
about to disappear.

Thanks,
Andrea
