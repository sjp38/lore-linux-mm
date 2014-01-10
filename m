Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9544A6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 19:01:19 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so1118377yhn.4
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:01:19 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id p5si6598767yho.284.2014.01.09.16.01.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 16:01:18 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so1126991yha.40
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:01:18 -0800 (PST)
Date: Thu, 9 Jan 2014 16:01:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
References: <20131210103827.GB20242@dhcp22.suse.cz> <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com> <20131211095549.GA18741@dhcp22.suse.cz> <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com> <20131212103159.GB2630@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com> <20131217162342.GG28991@dhcp22.suse.cz> <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com> <20131218200434.GA4161@dhcp22.suse.cz> <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com> <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 9 Jan 2014, Andrew Morton wrote:

> > I'm not sure why this was dropped since it's vitally needed for any sane 
> > userspace oom handler to be effective.
> 
> It was dropped because the other memcg developers disagreed with it.
> 

It was acked-by Michal.

> I'd really prefer not to have to spend a great amount of time parsing
> argumentative and repetitive emails to make a tie-break decision which
> may well be wrong anyway.
> 
> Please work with the other guys to find an acceptable implementation. 
> There must be *something* we can do?
> 

We REQUIRE this behavior for a sane userspace oom handler implementation.  
You've snipped my email quite extensively, but I'd like to know 
specifically how you would implement a userspace oom handler described by 
Section 10 of Documentation/cgroups/memory.txt without this patch?

Are you suggesting that userspace is supposed to wait for successive 
wakeups over some arbitrarily defined period of time to determine whether 
memory freeing (i.e. a process in the exit() path or with a pending 
SIGKILL making forward progress to free its memory) can be done or whether 
it needs to do something to free memory?  If not, how else is userspace 
supposed to know that it should act?

How do you prevent unnecessary oom killing if the userspace oom handler 
wakes up and kills something concurrent with the process triggering the 
notification getting access to memory reserves, exiting, and freeing its 
memory?  Userspace just killed a process unnecessarily.  This is the exact 
reason why the kernel oom killer doesn't do a damn thing in these 
conditions, because it's NOT ACTIONABLE by the oom killer, a process 
simply needs to exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
