Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 799946B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:28 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so5587897yhz.22
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:28 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id l26si19342644yhg.262.2013.12.11.14.40.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 14:40:27 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id b6so5615636yha.23
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:27 -0800 (PST)
Date: Wed, 11 Dec 2013 14:40:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131211095549.GA18741@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
References: <20131202200221.GC5524@dhcp22.suse.cz> <20131202212500.GN22729@cmpxchg.org> <20131203120454.GA12758@dhcp22.suse.cz> <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com> <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com> <20131209124840.GC3597@dhcp22.suse.cz> <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com> <20131210103827.GB20242@dhcp22.suse.cz> <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 11 Dec 2013, Michal Hocko wrote:

> > Triggering a pointless notification with PF_EXITING is rare, yet one 
> > pointless notification can be avoided with the patch. 
> 
> Sigh. Yes it will avoid one particular and rare race. There will still
> be notifications without oom kills.
> 

Would you prefer doing the mem_cgroup_oom_notify() in two places instead:

 - immediately before doing oom_kill_process() when it's guaranteed that
   the kernel would have killed something, and

 - when memory.oom_control == 1 in mem_cgroup_oom_synchronize()?

> Anyway.
> Does the reclaim make any sense for PF_EXITING tasks? Shouldn't we
> simply bypass charges of these tasks automatically. Those tasks will
> free some memory anyway so why to trigger reclaim and potentially OOM
> in the first place? Do we need to go via TIF_MEMDIE loop in the first
> place?
> 

I don't see any reason to make an optimization there since they will get 
TIF_MEMDIE set if reclaim has failed on one of their charges or if it 
results in a system oom through the page allocator's oom killer.  It would 
be nice to ensure reclaim has had a chance to free memory in the presence 
of any other potential parallel memory freeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
