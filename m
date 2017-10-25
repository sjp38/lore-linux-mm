Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00E766B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 08:41:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g75so20855113pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 05:41:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u21si1922623pfl.480.2017.10.25.05.41.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 05:41:52 -0700 (PDT)
Date: Wed, 25 Oct 2017 14:41:47 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20171025124147.bvd4huwtykf6icmb@dhcp22.suse.cz>
References: <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
 <201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
 <20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
 <201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
 <20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
 <201710252115.JII86453.tFFSLHQOOOVMJF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710252115.JII86453.tFFSLHQOOOVMJF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Wed 25-10-17 21:15:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 25-10-17 19:48:09, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > The OOM killer is the last hand break. At the time you hit the OOM
> > > > condition your system is usually hard to use anyway. And that is why I
> > > > do care to make this path deadlock free. I have mentioned multiple times
> > > > that I find real life triggers much more important than artificial DoS
> > > > like workloads which make your system unsuable long before you hit OOM
> > > > killer.
> > > 
> > > Unable to invoke the OOM killer (i.e. OOM lockup) is worse than hand break injury.
> > > 
> > > If you do care to make this path deadlock free, you had better stop depending on
> > > mutex_trylock(&oom_lock). Not only printk() from oom_kill_process() can trigger
> > > deadlock due to console_sem versus oom_lock dependency but also
> > 
> > And this means that we have to fix printk. Completely silent oom path is
> > out of question IMHO
> 
> We cannot fix printk() without giving enough CPU resource to printk().

This is a separate discussion but having a basically unbound time spent
in printk is simply a no-go.
 
> I don't think "Completely silent oom path" can happen, for warn_alloc() is called
> again when it is retried. But anyway, let's remove warn_alloc().

I mean something else. We simply cannot do the oom killing without
telling userspace about that. And printk is the only API we can use for
that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
