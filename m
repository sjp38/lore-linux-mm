Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 79E6C6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:22:23 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so2156583pdj.36
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:22:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id xj9si5883456pab.237.2013.11.18.17.22.20
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 17:22:21 -0800 (PST)
Received: by mail-gg0-f182.google.com with SMTP id h3so3181789gge.41
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:22:18 -0800 (PST)
Date: Mon, 18 Nov 2013 17:22:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131118165110.GE32623@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311181719390.4292@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org> <20131118165110.GE32623@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 18 Nov 2013, Michal Hocko wrote:

> > Even though the situation may not require a kill, the user still wants
> > to know that the memory hard limit was breached and the isolation
> > broken in order to prevent a kill.  We just came really close and the
> 
> You can observe that you are getting into troubles from fail counter
> already. The usability without more reclaim statistics is a bit
> questionable but you get a rough impression that something is wrong at
> least.
> 

Agreed, but it seems like the appropriate mechanism for this is through 
the memory.{,memsw.}usage_in_bytes notifiers which already exist.

> > fact that current is exiting is coincidental.  Not everybody is having
> > OOM situations on a frequent basis and they might want to know when
> > they are redlining the system and that the same workload might blow up
> > the next time it's run.
> 
> I am just concerned that signaling temporal OOM conditions which do not
> require any OOM killer action (user or kernel space) might be confusing.
> Userspace would have harder times to tell whether any action is required
> or not.
> 

Completely agreed, in fact there is no reliable and non-racy way in 
userspace to determine "is this a real oom condition that I must act upon 
or can the kernel handle it?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
