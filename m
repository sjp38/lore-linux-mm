Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADBBE6B0392
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 00:36:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so40890053pgi.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 21:36:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l3si2151736pgl.298.2017.03.07.21.36.17
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 21:36:18 -0800 (PST)
Date: Wed, 8 Mar 2017 14:36:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170308053615.GC11206@bbox>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
 <20170301183149.GA14277@cmpxchg.org>
 <20170301185735.GA24905@dhcp22.suse.cz>
 <20170302140101.GA16021@cmpxchg.org>
 <20170302163054.GR1404@dhcp22.suse.cz>
 <20170303161027.6fe4ceb0bcd27e1dbed44a5d@linux-foundation.org>
 <20170307100545.GC28642@dhcp22.suse.cz>
 <20170307144338.023080a8cd600172f37dfe16@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307144338.023080a8cd600172f37dfe16@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

Hi Andrew,

On Tue, Mar 07, 2017 at 02:43:38PM -0800, Andrew Morton wrote:
> On Tue, 7 Mar 2017 11:05:45 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 03-03-17 16:10:27, Andrew Morton wrote:
> > > On Thu, 2 Mar 2017 17:30:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > > It's not that I think you're wrong: it *is* an implementation detail.
> > > > > But we take a bit of incoherency from batching all over the place, so
> > > > > it's a little odd to take a stand over this particular instance of it
> > > > > - whether demanding that it'd be fixed, or be documented, which would
> > > > > only suggest to users that this is special when it really isn't etc.
> > > > 
> > > > I am not aware of other counter printed in smaps that would suffer from
> > > > the same problem, but I haven't checked too deeply so I might be wrong. 
> > > > 
> > > > Anyway it seems that I am alone in my position so I will not insist.
> > > > If we have any bug report then we can still fix it.
> > > 
> > > A single lru_add_drain_all() right at the top level (in smaps_show()?)
> > > won't kill us
> > 
> > I do not think we want to put lru_add_drain_all cost to a random
> > process reading /proc/<pid>/smaps.
> 
> Why not?  It's that process which is calling for the work to be done.
> 
> > If anything the one which does the
> > madvise should be doing this.
> 
> But it would be silly to do extra work in madvise() if nobody will be
> reading smaps for the next two months.
> 
> How much work is it anyway?  What would be the relative impact upon a
> smaps read?

I agree only if the draining guarantees all of mapped pages in the range
could be marked to lazyfree. However, it's not true because there are a
few of logics to skip the page marking in madvise_free_pte_range.

So, my conclusion is drainning helps a bit but not gaurantees.
In such case, IMHO, let's not do the effort to make better.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
