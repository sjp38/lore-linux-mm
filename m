Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8C8B6B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:53:50 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so3021190yho.24
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:53:50 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id e33si19090782yhq.243.2013.11.26.16.53.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 16:53:50 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id f11so4628544yha.0
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:53:49 -0800 (PST)
Date: Tue, 26 Nov 2013 16:53:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131122165100.GN3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org> <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 22 Nov 2013, Johannes Weiner wrote:

> But userspace in all likeliness DOES need to take action.
> 
> Reclaim is a really long process.  If 5 times doing 12 priority cycles
> and scanning thousands of pages is not enough to reclaim a single
> page, what does that say about the health of the memcg?
> 
> But more importantly, OOM handling is just inherently racy.  A task
> might receive the kill signal a split second *after* userspace was
> notified.  Or a task may exit voluntarily a split second after a
> victim was chosen and killed.
> 

That's not true even today without the userspace oom handling proposal 
currently being discussed if you have a memcg oom handler attached to a 
parent memcg with access to more memory than an oom child memcg.  The oom 
handler can disable the child memcg's oom killer with memory.oom_control 
and implement its own policy to deal with any notification of oom.

This patch is required to ensure that in such a scenario that the oom 
handler sitting in the parent memcg only wakes up when it's required to 
intervene.  Making an inference about the "health of the memcg" can 
certainly be done with memory thresholds and vmpressure, if you need that.

I agree with Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
