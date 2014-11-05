Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id BAE376B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:01:18 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id l4so886493lbv.40
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:01:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pz8si6942857lbb.36.2014.11.05.08.01.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 08:01:16 -0800 (PST)
Date: Wed, 5 Nov 2014 17:01:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105160115.GA28226@dhcp22.suse.cz>
References: <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105154436.GB14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 10:44:36, Tejun Heo wrote:
> On Wed, Nov 05, 2014 at 02:42:19PM +0100, Michal Hocko wrote:
> > On Wed 05-11-14 14:31:00, Michal Hocko wrote:
> > > On Wed 05-11-14 08:02:47, Tejun Heo wrote:
> > [...]
> > > > Also, why isn't this part of
> > > > oom_killer_disable/enable()?  The way they're implemented is really
> > > > silly now.  It just sets a flag and returns whether there's a
> > > > currently running instance or not.  How were these even useful? 
> > > > Why can't you just make disable/enable to what they were supposed to
> > > > do from the beginning?
> > > 
> > > Because then we would block all the potential allocators coming from
> > > workqueues or kernel threads which are not frozen yet rather than fail
> > > the allocation.
> > 
> > After thinking about this more it would be doable by using trylock in
> > the allocation oom path. I will respin the patch. The API will be
> > cleaner this way.
> 
> In disable, block new invocations of OOM killer and then drain the
> in-progress ones.  This is a common pattern, isn't it?

I am not sure I am following. With the latest patch OOM path is no
longer blocked by the PM (aka oom_killer_disable()). Allocations simply
fail if the read_trylock fails.
oom_killer_disable is moved before tasks are frozen and it will wait for
all on-going OOM killers on the write lock. OOM killer is enabled again
on the resume path.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
