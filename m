Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 239866B0397
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 06:10:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h89so26754756lfi.6
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 03:10:58 -0700 (PDT)
Received: from smtp62.i.mail.ru (smtp62.i.mail.ru. [217.69.128.42])
        by mx.google.com with ESMTPS id 1si7362111ljp.49.2017.04.03.03.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 03:10:50 -0700 (PDT)
Date: Mon, 3 Apr 2017 13:10:41 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is
 disabled" message
Message-ID: <20170403101041.GC29639@esperanza>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
 <20170403083800.GF24661@dhcp22.suse.cz>
 <20170403091153.GH24661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403091153.GH24661@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Mon, Apr 03, 2017 at 11:11:53AM +0200, Michal Hocko wrote:
> [Fixup Vladimir email address]
> 
> On Mon 03-04-17 10:38:00, Michal Hocko wrote:
> > On Sun 02-04-17 12:52:55, Tetsuo Handa wrote:
> > > I noticed that SysRq-f prints
> > > 
> > >   "sysrq: OOM request ignored because killer is disabled"
> > > 
> > > when no process was selected (rather than when oom killer was disabled).
> > > This message was not printed until Linux 4.8 because commit 7c5f64f84483bd13
> > > ("mm: oom: deduplicate victim selection code for memcg and global oom") changed
> > >  from "return true;" to "return !!oc->chosen;" when is_sysrq_oom(oc) is true.
> > > 
> > > Is this what we meant?

No that was not intentional.

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
> > 
> > So, what about this?
> > ---
> > From 6721932dba5b5143be0fa8110450231038af4238 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Mon, 3 Apr 2017 10:30:14 +0200
> > Subject: [PATCH] oom: improve oom disable handling
> > 
> > Tetsuo has reported that sysrq triggered OOM killer will print a
> > misleading information when no tasks are selected:
> > 
> > [  713.805315] sysrq: SysRq : Manual OOM execution
> > [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> > [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> > [  714.004805] sysrq: SysRq : Manual OOM execution
> > [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> > [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> > [  714.189310] sysrq: SysRq : Manual OOM execution
> > [  714.193425] sysrq: OOM request ignored because killer is disabled
> > [  714.381313] sysrq: SysRq : Manual OOM execution
> > [  714.385158] sysrq: OOM request ignored because killer is disabled
> > [  714.573320] sysrq: SysRq : Manual OOM execution
> > [  714.576988] sysrq: OOM request ignored because killer is disabled
> > 
> > The real reason is that there are no eligible tasks for the OOM killer
> > to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
> > selection code for memcg and global oom") the semantic of out_of_memory
> > has changed without updating moom_callback.
> > 
> > This patch updates moom_callback to tell that no task was eligible
> > which is the case for both oom killer disabled and no eligible tasks.
> > In order to help distinguish first case from the second add printk to
> > both oom_killer_{enable,disable}. This information is useful on its own
> > because it might help debugging potential memory allocation failures.

I think this makes sense although personally I find the "No task
eligible" message in case OOM killer is disabled manually a bit
confusing: the thing is in order to find out why an OOM request
failed you'll have to scan the full log, which might be unavailable.
May be, we'd better just make out_of_memory() return true in case
is_sysrq_oom() is true and no task was found, as it used to be.

> > 
> > Fixes: 7c5f64f84483bd13 ("mm: oom: deduplicate victim selection code for memcg and global oom")
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  drivers/tty/sysrq.c | 2 +-
> >  mm/oom_kill.c       | 2 ++
> >  2 files changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> > index 71136742e606..a91f58dc2cb6 100644
> > --- a/drivers/tty/sysrq.c
> > +++ b/drivers/tty/sysrq.c
> > @@ -370,7 +370,7 @@ static void moom_callback(struct work_struct *ignored)
> >  
> >  	mutex_lock(&oom_lock);
> >  	if (!out_of_memory(&oc))
> > -		pr_info("OOM request ignored because killer is disabled\n");
> > +		pr_info("OOM request ignored. No task eligible\n");
> >  	mutex_unlock(&oom_lock);
> >  }
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 51c091849dcb..ad2b112cdf3e 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -682,6 +682,7 @@ void exit_oom_victim(void)
> >  void oom_killer_enable(void)
> >  {
> >  	oom_killer_disabled = false;
> > +	pr_info("OOM killer enabled.\n");
> >  }
> >  
> >  /**
> > @@ -718,6 +719,7 @@ bool oom_killer_disable(signed long timeout)
> >  		oom_killer_enable();
> >  		return false;
> >  	}
> > +	pr_info("OOM killer disabled.\n");
> >  
> >  	return true;
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
