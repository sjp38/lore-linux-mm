Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B8E4A6B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 19:25:27 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so1040915pde.21
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 16:25:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id k3si38067961pbb.234.2014.01.07.16.25.05
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 16:25:26 -0800 (PST)
Date: Tue, 7 Jan 2014 16:25:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current
 needs access to memory reserves
Message-Id: <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
In-Reply-To: <20131219144134.GH10855@dhcp22.suse.cz>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 19 Dec 2013 15:41:34 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 18-12-13 22:09:12, David Rientjes wrote:
> > On Wed, 18 Dec 2013, Michal Hocko wrote:
> > 
> > > > For memory isolation, we'd only want to bypass memcg charges when 
> > > > absolutely necessary and it seems like TIF_MEMDIE is the only case where 
> > > > that's required.  We don't give processes with pending SIGKILLs or those 
> > > > in the exit() path access to memory reserves in the page allocator without 
> > > > first determining that reclaim can't make any progress for the same reason 
> > > > and then we only do so by setting TIF_MEMDIE when calling the oom killer.  
> > > 
> > > While I do understand arguments about isolation I would also like to be
> > > practical here. How many charges are we talking about? Dozen pages? Much
> > > more?
> > 
> > The PF_EXITING bypass is indeed much less concerning than the 
> > fatal_signal_pending() bypass.

I just spent a happy half hour reliving this thread and ended up
deciding I agreed with everyone!  I appears that many more emails are
needed so I think I'll drop
http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch
for now.

The claim that
mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch
will impact existing userspace seems a bit dubious to me.

> OK, so can we at least agree on the patch posted here:
> https://lkml.org/lkml/2013/12/12/129. This is a real bug and definitely
> worth fixing.

Yes, can we please get Eric's bug fixed?  I don't believe that Eric has
tested either https://lkml.org/lkml/2013/12/12/129 or
http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch.
Is he the only person who can reproduce this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
