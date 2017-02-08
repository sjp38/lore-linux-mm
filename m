Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1A046B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 02:35:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so31104302wjc.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 23:35:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si8124747wra.220.2017.02.07.23.35.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 23:35:30 -0800 (PST)
Date: Wed, 8 Feb 2017 08:35:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208073527.GA5686@dhcp22.suse.cz>
References: <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702072319200.8117@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 23:25:17, Thomas Gleixner wrote:
> On Tue, 7 Feb 2017, Christoph Lameter wrote:
> > On Tue, 7 Feb 2017, Michal Hocko wrote:
> > 
> > > I am always nervous when seeing hotplug locks being used in low level
> > > code. It has bitten us several times already and those deadlocks are
> > > quite hard to spot when reviewing the code and very rare to hit so they
> > > tend to live for a long time.
> > 
> > Yep. Hotplug events are pretty significant. Using stop_machine_XXXX() etc
> > would be advisable and that would avoid the taking of locks and get rid of all the
> > ocmplexity, reduce the code size and make the overall system much more
> > reliable.
> 
> Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> must be simpler solutions than that.

Absolutely agreed. We are in the page allocator path so using the
stop_machine* is just ridiculous. And, in fact, there is a much simpler
solution [1]

[1] http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
