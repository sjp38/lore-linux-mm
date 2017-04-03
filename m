Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A66B06B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 06:20:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o70so23400445wrb.11
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 03:20:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si14596514wmg.122.2017.04.03.03.20.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 03:20:33 -0700 (PDT)
Date: Mon, 3 Apr 2017 12:20:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is
 disabled" message
Message-ID: <20170403102029.GJ24661@dhcp22.suse.cz>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
 <20170403083800.GF24661@dhcp22.suse.cz>
 <20170403091153.GH24661@dhcp22.suse.cz>
 <20170403101041.GC29639@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403101041.GC29639@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Mon 03-04-17 13:10:41, Vladimir Davydov wrote:
> On Mon, Apr 03, 2017 at 11:11:53AM +0200, Michal Hocko wrote:
> > [Fixup Vladimir email address]
> > 
> > On Mon 03-04-17 10:38:00, Michal Hocko wrote:
> > > On Sun 02-04-17 12:52:55, Tetsuo Handa wrote:
> > > > I noticed that SysRq-f prints
> > > > 
> > > >   "sysrq: OOM request ignored because killer is disabled"
> > > > 
> > > > when no process was selected (rather than when oom killer was disabled).
> > > > This message was not printed until Linux 4.8 because commit 7c5f64f84483bd13
> > > > ("mm: oom: deduplicate victim selection code for memcg and global oom") changed
> > > >  from "return true;" to "return !!oc->chosen;" when is_sysrq_oom(oc) is true.
> > > > 
> > > > Is this what we meant?
> 
> No that was not intentional.
> 
> > > > 
> > > > [  713.805315] sysrq: SysRq : Manual OOM execution
> > > > [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> > > > [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> > > > [  714.004805] sysrq: SysRq : Manual OOM execution
> > > > [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> > > > [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> > > > [  714.189310] sysrq: SysRq : Manual OOM execution
> > > > [  714.193425] sysrq: OOM request ignored because killer is disabled
> > > > [  714.381313] sysrq: SysRq : Manual OOM execution
> > > > [  714.385158] sysrq: OOM request ignored because killer is disabled
> > > > [  714.573320] sysrq: SysRq : Manual OOM execution
> > > > [  714.576988] sysrq: OOM request ignored because killer is disabled
> > > 
> > > So, what about this?
> > > ---
> > > From 6721932dba5b5143be0fa8110450231038af4238 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Mon, 3 Apr 2017 10:30:14 +0200
> > > Subject: [PATCH] oom: improve oom disable handling
> > > 
> > > Tetsuo has reported that sysrq triggered OOM killer will print a
> > > misleading information when no tasks are selected:
> > > 
> > > [  713.805315] sysrq: SysRq : Manual OOM execution
> > > [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> > > [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> > > [  714.004805] sysrq: SysRq : Manual OOM execution
> > > [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> > > [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> > > [  714.189310] sysrq: SysRq : Manual OOM execution
> > > [  714.193425] sysrq: OOM request ignored because killer is disabled
> > > [  714.381313] sysrq: SysRq : Manual OOM execution
> > > [  714.385158] sysrq: OOM request ignored because killer is disabled
> > > [  714.573320] sysrq: SysRq : Manual OOM execution
> > > [  714.576988] sysrq: OOM request ignored because killer is disabled
> > > 
> > > The real reason is that there are no eligible tasks for the OOM killer
> > > to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
> > > selection code for memcg and global oom") the semantic of out_of_memory
> > > has changed without updating moom_callback.
> > > 
> > > This patch updates moom_callback to tell that no task was eligible
> > > which is the case for both oom killer disabled and no eligible tasks.
> > > In order to help distinguish first case from the second add printk to
> > > both oom_killer_{enable,disable}. This information is useful on its own
> > > because it might help debugging potential memory allocation failures.
> 
> I think this makes sense although personally I find the "No task
> eligible" message in case OOM killer is disabled manually a bit
> confusing: the thing is in order to find out why an OOM request
> failed you'll have to scan the full log, which might be unavailable.
> May be, we'd better just make out_of_memory() return true in case
> is_sysrq_oom() is true and no task was found, as it used to be.

Well, the thing is that the oom killer is disabled only during the PM
suspend and I do not expect we would grow new users. And it is quite
unlikely to invoke sysrq during that time. The OOM killer is disabled is
unlikely to be too far in the past in that case. It is also a matter of
fact that no tasks are eligible during that time period so the message
is not misleading. I have considered is_sysrq_oom approach but I would
rather not add yet another exception for that path, we have quite some
of them already. Especially when the only point of that exception would
be to control a log message.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
