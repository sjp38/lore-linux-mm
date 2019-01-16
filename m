Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8CB8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 14:27:52 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v131so3562952ywb.19
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:27:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s64sor1030882ywf.94.2019.01.16.11.27.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 11:27:46 -0800 (PST)
Date: Wed, 16 Jan 2019 14:27:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Message-ID: <20190116192744.GA1576@cmpxchg.org>
References: <20190110220718.261134-1-surenb@google.com>
 <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
 <20190116132446.GF10803@hirez.programming.kicks-ass.net>
 <CAJuCfpEJW6Uq4GSGEGLKOM4K7ySHUeTGrSUGM1+EJSQ16d8SJg@mail.gmail.com>
 <20190116191728.GA1380@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116191728.GA1380@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Wed, Jan 16, 2019 at 02:17:28PM -0500, Johannes Weiner wrote:
> On Wed, Jan 16, 2019 at 09:39:13AM -0800, Suren Baghdasaryan wrote:
> > On Wed, Jan 16, 2019 at 5:24 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > >
> > > On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> > > > For memory ordering (which Johannes also pointed out) the critical point is:
> > > >
> > > > times[cpu] += delta           | if g->polling:
> > > > smp_wmb()                     |   g->polling = polling = 0
> > > > cmpxchg(g->polling, 0, 1)     |   smp_rmb()
> > > >                               |   delta = times[*] (through goto SLOWPATH)
> > > >
> > > > So that hotpath writes to times[] then g->polling and slowpath reads
> > > > g->polling then times[]. cmpxchg() implies a full barrier, so we can
> > > > drop smp_wmb(). Something like this:
> > > >
> > > > times[cpu] += delta           | if g->polling:
> > > > cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
> > > >                               |   smp_rmb()
> > > >                               |   delta = times[*] (through goto SLOWPATH)
> > > >
> > > > Would that address your concern about ordering?
> > >
> > > cmpxchg() implies smp_mb() before and after, so the smp_wmb() on the
> > > left column is superfluous.
> > 
> > Should I keep it in the comments to make it obvious and add a note
> > about implicit barriers being the reason we don't call smp_mb() in the
> > code explicitly?
> 
> I'd keep 'em out if they aren't actually in the code. But I'd switch
> 
> 	delta = times[*]
> 
> in this comment to to
> 
> 	get_recent_times() // implies smp_mb()

Actually, I might have been mistaken about this. The seqcount locking
does an smp_rmb() and an smp_wmb(), and that orders reads and writes
respectively, but doesn't necessarily order reads against writes.

So I think we need an explicit smp_mb() after all.
