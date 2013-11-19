Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 81A986B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:25:19 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1779825pab.15
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:25:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id kn3si10883602pbc.64.2013.11.18.17.25.17
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 17:25:18 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id i7so3868949yha.32
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:25:16 -0800 (PST)
Date: Mon, 18 Nov 2013 17:25:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, memcg: add memory.oom_control notification for
 system oom
In-Reply-To: <20131118185213.GA12923@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311181722380.4292@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141526300.30112@chino.kir.corp.google.com>
 <20131118185213.GA12923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 18 Nov 2013, Michal Hocko wrote:

> > A subset of applications that wait on memory.oom_control don't disable
> > the oom killer for that memcg and simply log or cleanup after the kernel
> > oom killer kills a process to free memory.
> > 
> > We need the ability to do this for system oom conditions as well, i.e.
> > when the system is depleted of all memory and must kill a process.  For
> > convenience, this can use memcg since oom notifiers are already present.
> 
> Using the memcg interface for "read-only" interface without any plan for
> the "write" is only halfway solution. We want to handle global OOM in a
> more user defined ways but we have to agree on the proper interface
> first. I do not want to end up with something half baked with memcg and
> a different interface to do the real thing just because memcg turns out
> to be unsuitable.
> 

This patch isn't really a halfway solution, you can still determine if the 
open(O_WRONLY) succeeds or not to determine if that feature has been 
implemented.  I'm concerned about disabling the oom killer entirely for 
system oom conditions, though, so I didn't implement it to be writable.  I 
don't think we should be doing anything special in terms of "write" 
behavior for the root memcg memory.oom_control, so I'd argue against doing 
anything other than disabling the oom killer.  That's scary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
