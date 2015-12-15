Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABCB6B025A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 14:22:55 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id o64so9525516pfb.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:22:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g16si3503031pfg.219.2015.12.15.11.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 11:22:54 -0800 (PST)
Date: Tue, 15 Dec 2015 20:22:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20151215192245.GK6357@twins.programming.kicks-ass.net>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
 <20151211162554.GS30240@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151211162554.GS30240@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mhocko@kernel.org, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, vdavydov@parallels.com, kernel-team@fb.com, Dmitry Vyukov <dvyukov@google.com>

On Fri, Dec 11, 2015 at 11:25:54AM -0500, Tejun Heo wrote:
> Hello, Peter, Ingo.
> 
> On Wed, Nov 25, 2015 at 06:44:49PM +0100, Peter Zijlstra wrote:
> > On Wed, Nov 25, 2015 at 06:31:41PM +0300, Andrey Ryabinin wrote:
> > > > +       /* scheduler bits, serialized by scheduler locks */
> > > >         unsigned sched_reset_on_fork:1;
> > > >         unsigned sched_contributes_to_load:1;
> > > >         unsigned sched_migrated:1;
> > > > +       unsigned __padding_sched:29;
> > > 
> > > AFAIK the order of bit fields is implementation defined, so GCC could
> > > sort all these bits as it wants.
> > 
> > We're relying on it doing DTRT in other places, so I'm fairly confident
> > this'll work, otoh
> > 
> > > You could use unnamed zero-widht bit-field to force padding:
> > > 
> > >          unsigned :0; //force aligment to the next boundary.
> > 
> > That's a nice trick I was not aware of, thanks!
> 
> Has this been fixed yet?  While I'm not completely sure and I don't
> think there's a way to be certain after the fact, we have a single
> report of a machine which is showing ~4G as loadavg and one plausible
> explanation could be that one of the ->nr_uninterruptible counters
> underflowed from sched_contributes_to_load getting corrupted, so it'd
> be great to get this one fixed soon.

Nope, lemme write a Changelog and queue it. Thanks for the reminder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
