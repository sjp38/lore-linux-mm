Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f173.google.com (mail-gg0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id B62DF6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 19:23:53 -0500 (EST)
Received: by mail-gg0-f173.google.com with SMTP id q4so1055346ggn.32
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:23:53 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id q66si6705053yhm.104.2014.01.09.16.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 16:23:53 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so1147673yhn.18
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:23:52 -0800 (PST)
Date: Thu, 9 Jan 2014 16:23:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
References: <20131210103827.GB20242@dhcp22.suse.cz> <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com> <20131211095549.GA18741@dhcp22.suse.cz> <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com> <20131212103159.GB2630@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com> <20131217162342.GG28991@dhcp22.suse.cz> <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com> <20131218200434.GA4161@dhcp22.suse.cz> <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com> <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
 <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com> <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 9 Jan 2014, Andrew Morton wrote:

> > > It was dropped because the other memcg developers disagreed with it.
> > > 
> > 
> > It was acked-by Michal.
> 
> And Johannes?
> 

Johannes is arguing for the same semantics that VMPRESSURE_CRITICAL and/or 
memory thresholds provides, which disagrees from the list of solutions 
that Documentation/cgroups/memory.txt gives for userspace oom handler 
wakeups and is required for any sane implementation.

> > We REQUIRE this behavior for a sane userspace oom handler implementation.  
> > You've snipped my email quite extensively, but I'd like to know 
> > specifically how you would implement a userspace oom handler described by 
> > Section 10 of Documentation/cgroups/memory.txt without this patch?
> 
> From long experience I know that if I suggest an alternative
> implementation, advocates of the initial implementation will invest
> great effort in demonstrating why my suggestion won't work while
> investing zero effort in thinking up alternatives themselves.
> 

Easy thing to say when you don't suggest an alternative implementation, 
right?

I'm fully aware that I'm the only one in this thread who is charged with 
writing and maintaining userspace oom handlers, so I'm not asking for an 
actual implementation, but rather an answer to the very simple question: 
how does userspace know whether it needs to actually do anything or not 
without this patch?

> So the interface is wrong.  We have two semantically different kernel
> states which are being communicated to userspace in the same way, so
> userspace cannot disambiguate.
> 

We want to notify on one state, which is what is described in 
Documentation/cgroups/memory.txt and works with my patch, and not notify 
on another state which was broken by ME in f9434ad15524 ("memcg: give 
current access to memory reserves if it's trying to die").  Am I allowed 
to fix my own breakage?

Userspace expects to get notified for the reasons listed in the 
documentation, not when the kernel is going to allow memory to be freed 
itself.  You can get notification of oom through vmpressure or memory 
thresholds, memory.oom_control needs to be reserved for situations when 
"something" needs to be done by userspace and as defined by the 
documentation.

> Solution: invent a better communication scheme with a richer payload. 
> Use that, deprecate the old interface if poss.
> 

There are better communication schemes for oom conditions that are not 
actionable, they are memcg memory threshold notifications and vmpressure.

> Johannes' final email in this thread has yet to be replied to, btw.
> 

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
