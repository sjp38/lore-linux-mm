Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D80A6B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:35:05 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so26398807wjc.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:35:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v46si5462168wrc.22.2017.02.07.07.35.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 07:35:03 -0800 (PST)
Date: Tue, 7 Feb 2017 16:34:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207153459.GV5065@dhcp22.suse.cz>
References: <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207141911.GR5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 15:19:11, Michal Hocko wrote:
> On Tue 07-02-17 13:58:46, Mel Gorman wrote:
> > On Tue, Feb 07, 2017 at 01:37:08PM +0100, Michal Hocko wrote:
> [...]
> > > Anyway, shouldn't be it sufficient to disable preemption
> > > on drain_local_pages_wq?
> > 
> > That would be sufficient for a hot-removed CPU moving the drain request
> > to another CPU and avoiding any scheduling events.
> > 
> > > The CPU hotplug callback will not preempt us
> > > and so we cannot work on the same cpus, right?
> > > 
> > 
> > I don't see a specific guarantee that it cannot be preempted and it
> > would depend on an the exact cpu hotplug implementation which is subject
> > to quite a lot of change.
> 
> But we do not care about the whole cpu hotplug code. The only part we
> really do care about is the race inside drain_pages_zone and that will
> run in an atomic context on the specific CPU.
> 
> You are absolutely right that using the mutex is safe as well but the
> hotplug path is already littered with locks and adding one more to the
> picture doesn't sound great to me. So I would really like to not use a
> lock if that is possible and safe (with a big fat comment of course).

And with the full changelog. I hope I haven't missed anything this time.
---
