Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDC36B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 11:41:34 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so26804275wjb.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 08:41:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si5682388wrb.72.2017.02.07.08.41.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 08:41:33 -0800 (PST)
Date: Tue, 7 Feb 2017 17:41:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207164130.GY5065@dhcp22.suse.cz>
References: <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207162224.elnrlgibjegswsgn@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 16:22:24, Mel Gorman wrote:
> On Tue, Feb 07, 2017 at 04:34:59PM +0100, Michal Hocko wrote:
> > > But we do not care about the whole cpu hotplug code. The only part we
> > > really do care about is the race inside drain_pages_zone and that will
> > > run in an atomic context on the specific CPU.
> > > 
> > > You are absolutely right that using the mutex is safe as well but the
> > > hotplug path is already littered with locks and adding one more to the
> > > picture doesn't sound great to me. So I would really like to not use a
> > > lock if that is possible and safe (with a big fat comment of course).
> > 
> > And with the full changelog. I hope I haven't missed anything this time.
> > ---
> > From 8c6af3116520251cc4ec2213f0a4ed2544bb4365 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 7 Feb 2017 16:08:35 +0100
> > Subject: [PATCH] mm, page_alloc: do not depend on cpu hotplug locks inside the
> >  allocator
> > 
> > <SNIP>
> >
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Not that I can think of. It's almost identical to the diff I posted with
> the exception of the mutex in the cpu hotplug teardown path. I agree that
> in the current implementation that it should be unnecessary even if I
> thought it would be more robust against any other hotplug churn.

I am always nervous when seeing hotplug locks being used in low level
code. It has bitten us several times already and those deadlocks are
quite hard to spot when reviewing the code and very rare to hit so they
tend to live for a long time.

> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks! I will wait for Tejun to confirm my assumptions are correct and
post the patch to Andrew if there are no further problems spotted. Btw.
this will also get rid of another lockdep report which seem to be false
possitive though
http://lkml.kernel.org/r/20170203145548.GC19325@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
