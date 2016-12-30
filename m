Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCA0B6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 05:40:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so35124275wmi.6
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 02:40:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kr2si61629996wjc.288.2016.12.30.02.40.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 02:40:42 -0800 (PST)
Date: Fri, 30 Dec 2016 11:40:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161230104038.GA13657@dhcp22.suse.cz>
References: <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
 <20161227155532.GI1308@dhcp22.suse.cz>
 <20161229012026.GB15541@bbox>
 <20161229090432.GE29208@dhcp22.suse.cz>
 <20161230020522.GC4184@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230020522.GC4184@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>

On Fri 30-12-16 11:05:22, Minchan Kim wrote:
> On Thu, Dec 29, 2016 at 10:04:32AM +0100, Michal Hocko wrote:
> > On Thu 29-12-16 10:20:26, Minchan Kim wrote:
> > > On Tue, Dec 27, 2016 at 04:55:33PM +0100, Michal Hocko wrote:
[...]
> > > > + * given zone_idx
> > > > + */
> > > > +static unsigned long lruvec_lru_size_zone_idx(struct lruvec *lruvec,
> > > > +		enum lru_list lru, int zone_idx)
> > > 
> > > Nit:
> > > 
> > > Although there is a comment, function name is rather confusing when I compared
> > > it with lruvec_zone_lru_size.
> > 
> > I am all for a better name.
> > 
> > > lruvec_eligible_zones_lru_size is better?
> > 
> > this would be too easy to confuse with lruvec_eligible_zone_lru_size.
> > What about lruvec_lru_size_eligible_zones?
> 
> Don't mind.

I will go with lruvec_lru_size_eligible_zones then.

> > > Nit:
> > > 
> > > With this patch, inactive_list_is_low can use lruvec_lru_size_zone_idx rather than
> > > own custom calculation to filter out non-eligible pages. 
> > 
> > Yes, that would be possible and I was considering that. But then I found
> > useful to see total and reduced numbers in the tracepoint
> > http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org
> > and didn't want to call lruvec_lru_size 2 times. But if you insist then
> > I can just do that.
> 
> I don't mind either but I think we need to describe the reason if you want to
> go with your open-coded version. Otherwise, someone will try to fix it.

OK, I will go with the follow up patch on top of the tracepoints series.
I was hoping that the way how tracing is full of macros would allow us
to evaluate arguments only when the tracepoint is enabled but this
doesn't seem to be the case. Let's CC Steven. Would it be possible to
define a tracepoint in such a way that all given arguments are evaluated
only when the tracepoint is enabled?
---
