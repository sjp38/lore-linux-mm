Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33CBB6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 06:10:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n5so137568667pgd.19
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 03:10:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f1si13840811pln.331.2017.04.03.03.10.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 03:10:50 -0700 (PDT)
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is disabled" message
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
	<20170403083800.GF24661@dhcp22.suse.cz>
	<20170403091153.GH24661@dhcp22.suse.cz>
In-Reply-To: <20170403091153.GH24661@dhcp22.suse.cz>
Message-Id: <201704031910.GGH56210.QVFFOSHLOMFtJO@I-love.SAKURA.ne.jp>
Date: Mon, 3 Apr 2017 19:10:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, vdavydov.dev@gmail.com

Michal Hocko wrote:
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

I thought below change in out_of_memory().

-	return !!oc->chosen;
+	return oc->chosen || is_sysrq_oom(oc);

You can take either approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
