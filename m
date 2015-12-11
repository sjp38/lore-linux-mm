Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id AF9796B025B
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:25:57 -0500 (EST)
Received: by vkgj66 with SMTP id j66so22516101vkg.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 08:25:57 -0800 (PST)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id h133si14634672vkh.138.2015.12.11.08.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 08:25:56 -0800 (PST)
Received: by vkay187 with SMTP id y187so118691442vka.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 08:25:56 -0800 (PST)
Date: Fri, 11 Dec 2015 11:25:54 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20151211162554.GS30240@mtj.duckdns.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125174449.GD17308@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mhocko@kernel.org, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, vdavydov@parallels.com, kernel-team@fb.com, Dmitry Vyukov <dvyukov@google.com>

Hello, Peter, Ingo.

On Wed, Nov 25, 2015 at 06:44:49PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 25, 2015 at 06:31:41PM +0300, Andrey Ryabinin wrote:
> > > +       /* scheduler bits, serialized by scheduler locks */
> > >         unsigned sched_reset_on_fork:1;
> > >         unsigned sched_contributes_to_load:1;
> > >         unsigned sched_migrated:1;
> > > +       unsigned __padding_sched:29;
> > 
> > AFAIK the order of bit fields is implementation defined, so GCC could
> > sort all these bits as it wants.
> 
> We're relying on it doing DTRT in other places, so I'm fairly confident
> this'll work, otoh
> 
> > You could use unnamed zero-widht bit-field to force padding:
> > 
> >          unsigned :0; //force aligment to the next boundary.
> 
> That's a nice trick I was not aware of, thanks!

Has this been fixed yet?  While I'm not completely sure and I don't
think there's a way to be certain after the fact, we have a single
report of a machine which is showing ~4G as loadavg and one plausible
explanation could be that one of the ->nr_uninterruptible counters
underflowed from sched_contributes_to_load getting corrupted, so it'd
be great to get this one fixed soon.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
