Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 565C96B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 16:57:55 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so3631002lab.6
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:57:54 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id li6si24832316lbc.87.2014.10.22.13.57.52
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 13:57:53 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Date: Wed, 22 Oct 2014 23:18:20 +0200
Message-ID: <2145559.zOULAq9xLg@vostro.rjw.lan>
In-Reply-To: <20141022142226.GC30802@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz> <3987583.vdsuvlAsHc@vostro.rjw.lan> <20141022142226.GC30802@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wednesday, October 22, 2014 04:22:26 PM Michal Hocko wrote:
> On Wed 22-10-14 16:39:12, Rafael J. Wysocki wrote:
> > On Tuesday, October 21, 2014 04:29:39 PM Michal Hocko wrote:
> > > On Tue 21-10-14 16:41:07, Rafael J. Wysocki wrote:
> > > > On Tuesday, October 21, 2014 04:11:59 PM Michal Hocko wrote:
> > > [...]
> > > > > OK, incremental diff on top. I will post the complete patch if you are
> > > > > happier with this change
> > > > 
> > > > Yes, I am.
> > > ---
> > > From 9ab46fe539cded8e7b6425b2cd23ba9184002fde Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Mon, 20 Oct 2014 18:12:32 +0200
> > > Subject: [PATCH -v2] OOM, PM: OOM killed task shouldn't escape PM suspend
> > > 
> > > PM freezer relies on having all tasks frozen by the time devices are
> > > getting frozen so that no task will touch them while they are getting
> > > frozen. But OOM killer is allowed to kill an already frozen task in
> > > order to handle OOM situtation. In order to protect from late wake ups
> > > OOM killer is disabled after all tasks are frozen. This, however, still
> > > keeps a window open when a killed task didn't manage to die by the time
> > > freeze_processes finishes.
> > > 
> > > Reduce the race window by checking all tasks after OOM killer has been
> > > disabled. This is still not race free completely unfortunately because
> > > oom_killer_disable cannot stop an already ongoing OOM killer so a task
> > > might still wake up from the fridge and get killed without
> > > freeze_processes noticing. Full synchronization of OOM and freezer is,
> > > however, too heavy weight for this highly unlikely case.
> > > 
> > > Introduce and check oom_kills counter which gets incremented early when
> > > the allocator enters __alloc_pages_may_oom path and only check all the
> > > tasks if the counter changes during the freezing attempt. The counter
> > > is updated so early to reduce the race window since allocator checked
> > > oom_killer_disabled which is set by PM-freezing code. A false positive
> > > will push the PM-freezer into a slow path but that is not a big deal.
> > > 
> > > Changes since v1
> > > - push the re-check loop out of freeze_processes into
> > >   check_frozen_processes and invert the condition to make the code more
> > >   readable as per Rafael
> > 
> > I've applied that along with the rest of the series, but what about the
> > following cleanup patch on top of it?
> 
> Sure, looks good to me.

I'll apply it then, thanks!

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
