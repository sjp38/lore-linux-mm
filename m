Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F31C56B038F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 11:30:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t193so6071870wmt.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 08:30:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si11231292wra.239.2017.03.02.08.30.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 08:30:55 -0800 (PST)
Date: Thu, 2 Mar 2017 17:30:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170302163054.GR1404@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
 <20170301183149.GA14277@cmpxchg.org>
 <20170301185735.GA24905@dhcp22.suse.cz>
 <20170302140101.GA16021@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302140101.GA16021@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu 02-03-17 09:01:01, Johannes Weiner wrote:
> On Wed, Mar 01, 2017 at 07:57:35PM +0100, Michal Hocko wrote:
> > On Wed 01-03-17 13:31:49, Johannes Weiner wrote:
[...]
> > > The error when reading a specific smaps should be completely ok.
> > > 
> > > In numbers: even if your process is madvising from 16 different CPUs,
> > > the error in its smaps file will peak at 896K in the worst case. That
> > > level of concurrency tends to come with much bigger memory quantities
> > > for that amount of error to matter.
> > 
> > It is still an unexpected behavior IMHO and an implementation detail
> > which leaks to the userspace.
> 
> We have per-cpu fuzz in every single vmstat counter. Look at
> calculate_normal_threshold() in vmstat.c and the sample thresholds for
> when per-cpu deltas are flushed. In the vast majority of machines, the
> per-cpu error in these counters is much higher than what we get with
> pagevecs holding back a few pages.

Yes but vmstat counters have a different usecase AFAIK. You mostly look
at those when debugging or watching the system. /proc/<pid>/smaps is
quite often used to do per task metrics which are then used for some
decision making so it should be less fuzzy if that is possible.

> It's not that I think you're wrong: it *is* an implementation detail.
> But we take a bit of incoherency from batching all over the place, so
> it's a little odd to take a stand over this particular instance of it
> - whether demanding that it'd be fixed, or be documented, which would
> only suggest to users that this is special when it really isn't etc.

I am not aware of other counter printed in smaps that would suffer from
the same problem, but I haven't checked too deeply so I might be wrong. 

Anyway it seems that I am alone in my position so I will not insist.
If we have any bug report then we can still fix it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
