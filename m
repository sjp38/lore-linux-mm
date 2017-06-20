Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2B826B02F4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:44:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q4so30097644lfe.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 06:44:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 10si3787650ljg.235.2017.06.20.06.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 06:44:15 -0700 (PDT)
Date: Tue, 20 Jun 2017 14:43:35 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm,oom: add tracepoints for oom reaper-related events
Message-ID: <20170620134335.GA17724@castle>
References: <1496145932-18636-1-git-send-email-guro@fb.com>
 <20170530123415.GF7969@dhcp22.suse.cz>
 <20170530133335.GB28148@castle>
 <20170530134552.GI7969@dhcp22.suse.cz>
 <20170530185231.GA13412@castle>
 <20170531163928.GZ27783@dhcp22.suse.cz>
 <20170601184113.GA31689@castle>
 <20170602081338.GD29840@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170602081338.GD29840@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew!

Can you, please, pull this patch?

Thank you!

Roman

On Fri, Jun 02, 2017 at 10:13:38AM +0200, Michal Hocko wrote:
> On Thu 01-06-17 19:41:13, Roman Gushchin wrote:
> > On Wed, May 31, 2017 at 06:39:29PM +0200, Michal Hocko wrote:
> > > On Tue 30-05-17 19:52:31, Roman Gushchin wrote:
> > > > >From c57e3674efc609f8364f5e228a2c1309cfe99901 Mon Sep 17 00:00:00 2001
> > > > From: Roman Gushchin <guro@fb.com>
> > > > Date: Tue, 23 May 2017 17:37:55 +0100
> > > > Subject: [PATCH v2] mm,oom: add tracepoints for oom reaper-related events
> > > > 
> > > > During the debugging of the problem described in
> > > > https://lkml.org/lkml/2017/5/17/542 and fixed by Tetsuo Handa
> > > > in https://lkml.org/lkml/2017/5/19/383 , I've found that
> > > > the existing debug output is not really useful to understand
> > > > issues related to the oom reaper.
> > > > 
> > > > So, I assume, that adding some tracepoints might help with
> > > > debugging of similar issues.
> > > > 
> > > > Trace the following events:
> > > > 1) a process is marked as an oom victim,
> > > > 2) a process is added to the oom reaper list,
> > > > 3) the oom reaper starts reaping process's mm,
> > > > 4) the oom reaper finished reaping,
> > > > 5) the oom reaper skips reaping.
> > > > 
> > > > How it works in practice? Below is an example which show
> > > > how the problem mentioned above can be found: one process is added
> > > > twice to the oom_reaper list:
> > > > 
> > > > $ cd /sys/kernel/debug/tracing
> > > > $ echo "oom:mark_victim" > set_event
> > > > $ echo "oom:wake_reaper" >> set_event
> > > > $ echo "oom:skip_task_reaping" >> set_event
> > > > $ echo "oom:start_task_reaping" >> set_event
> > > > $ echo "oom:finish_task_reaping" >> set_event
> > > > $ cat trace_pipe
> > > >         allocate-502   [001] ....    91.836405: mark_victim: pid=502
> > > >         allocate-502   [001] .N..    91.837356: wake_reaper: pid=502
> > > >         allocate-502   [000] .N..    91.871149: wake_reaper: pid=502
> > > >       oom_reaper-23    [000] ....    91.871177: start_task_reaping: pid=502
> > > >       oom_reaper-23    [000] .N..    91.879511: finish_task_reaping: pid=502
> > > >       oom_reaper-23    [000] ....    91.879580: skip_task_reaping: pid=502
> > > 
> > > OK, this is much better! The clue here would be that we got 2
> > > wakeups for the same task, right?
> > > Do you think it would make sense to put more context to those
> > > tracepoints? E.g. skip_task_reaping can be due to lock contention or the
> > > mm gone. wake_reaper is similar.
> > 
> > I agree, that some context might be useful under some circumstances,
> > but I don't think we should add any additional fields until we will have some examples
> > of where this data is actually useful. If we will need it, we can easily add it later.
> 
> OK, fair enough.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
