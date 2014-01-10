Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id BFA016B0037
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 19:12:49 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so3687547pbc.15
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:12:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tb5si5231224pac.307.2014.01.09.16.12.47
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 16:12:48 -0800 (PST)
Date: Thu, 9 Jan 2014 16:12:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current
 needs access to memory reserves
Message-Id: <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
References: <20131210103827.GB20242@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
	<20131211095549.GA18741@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
	<20131212103159.GB2630@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
	<20131217162342.GG28991@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
	<20131218200434.GA4161@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
	<20131219144134.GH10855@dhcp22.suse.cz>
	<20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
	<alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
	<20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
	<alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 9 Jan 2014 16:01:15 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Thu, 9 Jan 2014, Andrew Morton wrote:
> 
> > > I'm not sure why this was dropped since it's vitally needed for any sane 
> > > userspace oom handler to be effective.
> > 
> > It was dropped because the other memcg developers disagreed with it.
> > 
> 
> It was acked-by Michal.

And Johannes?

> > I'd really prefer not to have to spend a great amount of time parsing
> > argumentative and repetitive emails to make a tie-break decision which
> > may well be wrong anyway.
> > 
> > Please work with the other guys to find an acceptable implementation. 
> > There must be *something* we can do?
> > 
> 
> We REQUIRE this behavior for a sane userspace oom handler implementation.  
> You've snipped my email quite extensively, but I'd like to know 
> specifically how you would implement a userspace oom handler described by 
> Section 10 of Documentation/cgroups/memory.txt without this patch?

>From long experience I know that if I suggest an alternative
implementation, advocates of the initial implementation will invest
great effort in demonstrating why my suggestion won't work while
investing zero effort in thinking up alternatives themselves.

> Are you suggesting that userspace is supposed to wait for successive 
> wakeups over some arbitrarily defined period of time to determine whether 
> memory freeing (i.e. a process in the exit() path or with a pending 
> SIGKILL making forward progress to free its memory) can be done or whether 
> it needs to do something to free memory?  If not, how else is userspace 
> supposed to know that it should act?
> 
> How do you prevent unnecessary oom killing if the userspace oom handler 
> wakes up and kills something concurrent with the process triggering the 
> notification getting access to memory reserves, exiting, and freeing its 
> memory?  Userspace just killed a process unnecessarily.  This is the exact 
> reason why the kernel oom killer doesn't do a damn thing in these 
> conditions, because it's NOT ACTIONABLE by the oom killer, a process 
> simply needs to exit.

So the interface is wrong.  We have two semantically different kernel
states which are being communicated to userspace in the same way, so
userspace cannot disambiguate.

Solution: invent a better communication scheme with a richer payload. 
Use that, deprecate the old interface if poss.

Another solution: add a mode knob to select between alternative kernel
behaviors (yuk).

Another solution: get David to think of a solution which addresses the
issues which others have raised.

Johannes' final email in this thread has yet to be replied to, btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
