Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC1896B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 03:32:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so18962202wmh.0
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 00:32:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si23226527edj.167.2017.06.03.00.32.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Jun 2017 00:32:26 -0700 (PDT)
Date: Sat, 3 Jun 2017 09:32:21 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170603073221.GB21524@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170601115936.GA9091@dhcp22.suse.cz>
 <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Fri 02-06-17 12:59:44, Andrew Morton wrote:
> On Fri, 2 Jun 2017 09:18:18 +0200 Michal Hocko <mhocko@suse.com> wrote:
> 
> > On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > > On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > > 
> > > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > > > >
> > > > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > > > on the vanilla up-to-date kernel?
> > > > > 
> > > > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > > > enterprise distributions would choose for their next long term supported
> > > > > version.
> > > > > 
> > > > > And please stop saying "can you reproduce your problem with latest
> > > > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > > > up-to-date kernel!
> > > > 
> > > > The changelog mentioned that the source of stalls is not clear so this
> > > > might be out-of-tree patches doing something wrong and dump_stack
> > > > showing up just because it is called often. This wouldn't be the first
> > > > time I have seen something like that. I am not really keen on adding
> > > > heavy lifting for something that is not clearly debugged and based on
> > > > hand waving and speculations.
> > > 
> > > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > > output from concurrent calls getting all jumbled together?
> > 
> > dump_stack already serializes concurrent calls.
> 
> Sure.  But warn_alloc() doesn't.

I really do not see why that would be much better, really. warn_alloc is
more or less one line + dump_stack + warn_alloc_show_mem. Single line
shouldn't be a big deal even though this is a continuation line
actually. dump_stack already contains its own synchronization and the
meminfo stuff is ratelimited to one per second. So why do we exactly
wantt to put yet another lock on top? Just to stick them together? Well
is this worth a new lock dependency between memory allocation and the
whole printk stack or dump_stack? Maybe yes but this needs a much deeper
consideration.

Tetsuo is arguing that the locking will throttle warn_alloc callers and
that can help other processes to move on. I would call it papering over
a real issue which might be somewhere else and that is why I push back so
hard. The initial report is far from complete and seeing 30+ seconds
stalls without any indication that this is just a repeating stall after
10s and 20s suggests that we got stuck somewhere in the reclaim path.

Moreover let's assume that the unfair locking in dump_stack has caused
the stall. How would an warn_alloc lock help when there are other
sources of dump_stack all over the kernel?

Seriously, this whole discussion is based on hand waving. Like for
any other patches, the real issue should be debugged, explained and
discussed based on known facts, not speculations. As things stand now,
my NACK still holds. I am not going to waste my time repeating same
points all over again.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
