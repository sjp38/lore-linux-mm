Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC666B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 13:01:42 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so10092571pbb.22
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 10:01:42 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id iw3si11603492pac.14.2014.04.01.10.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 10:01:42 -0700 (PDT)
Message-ID: <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 01 Apr 2014 10:01:39 -0700
In-Reply-To: <20140331170546.3b3e72f0.akpm@linux-foundation.org>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	 <20140331170546.3b3e72f0.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-03-31 at 17:05 -0700, Andrew Morton wrote:
> On Mon, 31 Mar 2014 16:25:32 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > On Mon, 2014-03-31 at 16:13 -0700, Andrew Morton wrote:
> > > On Mon, 31 Mar 2014 15:59:33 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> > > 
> > > > > 
> > > > > - Shouldn't there be a way to alter this namespace's shm_ctlmax?
> > > > 
> > > > Unfortunately this would also add the complexity I previously mentioned.
> > > 
> > > But if the current namespace's shm_ctlmax is too small, you're screwed.
> > > Have to shut down the namespace all the way back to init_ns and start
> > > again.
> > > 
> > > > > - What happens if we just nuke the limit altogether and fall back to
> > > > >   the next check, which presumably is the rlimit bounds?
> > > > 
> > > > afaik we only have rlimit for msgqueues. But in any case, while I like
> > > > that simplicity, it's too late. Too many workloads (specially DBs) rely
> > > > heavily on shmmax. Removing it and relying on something else would thus
> > > > cause a lot of things to break.
> > > 
> > > It would permit larger shm segments - how could that break things?  It
> > > would make most or all of these issues go away?
> > > 
> > 
> > So sysadmins wouldn't be very happy, per man shmget(2):
> > 
> > EINVAL A new segment was to be created and size < SHMMIN or size >
> > SHMMAX, or no new segment was to be created, a segment with given key
> > existed, but size is greater than the size of that segment.
> 
> So their system will act as if they had set SHMMAX=enormous.  What
> problems could that cause?

So, just like any sysctl configurable, only privileged users can change
this value. If we remove this option, users can theoretically create
huge segments, thus ignoring any custom limit previously set. This is
what I fear. Think of it kind of like mlock's rlimit. And for that
matter, why does sysctl exist at all, the same would go for the rest of
the limits.

> Look.  The 32M thing is causing problems.  Arbitrarily increasing the
> arbitrary 32M to an arbitrary 128M won't fix anything - we still have
> the problem.  Think bigger, please: how can we make this problem go
> away for ever?

That's the thing, I don't think we can make it go away without breaking
userspace. I'm not saying that my 4x increase is the correct value, I
don't think any default value is really correct, as with any other
hardcoded limits there are pros and cons. That's really why we give
users the option to change it to the "correct" one via sysctl. All I'm
saying is that 32mb is just too small for default in today's systems,
and increasing it is just making a bad situation a tiny bit better.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
