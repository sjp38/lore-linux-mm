Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id E607C6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 19:22:21 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so5606922yha.11
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 16:22:21 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id 41si29389633yhf.227.2013.11.27.16.22.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 16:22:21 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so5631706yha.3
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 16:22:20 -0800 (PST)
Date: Wed, 27 Nov 2013 16:22:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131127231931.GG3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271613340.10617@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com> <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz> <20131122165100.GN3556@cmpxchg.org> <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com> <20131127163435.GA3556@cmpxchg.org> <alpine.DEB.2.02.1311271343250.9222@chino.kir.corp.google.com>
 <20131127231931.GG3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> > The patch is drawing the line at "the kernel can no longer do anything to 
> > free memory", and that's the line where userspace should be notified or a 
> > process killed by the kernel.
> >
> > Giving current access to memory reserves in the oom killer is an
> > optimization so that all reclaim is exhausted prior to declaring
> > that they are necessary, the kernel still has the ability to allow
> > that process to exit and free memory.
> 
> "they" are necessary?
> 

Memory reserves.

> > This is the same as the oom notifiers within the kernel that free
> > memory from s390 and powerpc archs: the kernel still has the ability
> > to free memory.
> 
> They're not the same at all.  One is the kernel freeing memory, the
> other is a random coincidence.
> 

Current is on the way to memory freeing because it has a pending SIGKILL 
or is already exiting, it simply needs access to memory reserves to do so.  
This was originally introduced to prevent the oom killer from having to 
scan the set of eligible processes and silently giving it access to memory 
reserves; we didn't want to emit all of the messages to the kernel log 
because scripts (and admins) were looking at the kernel log and seeing 
that the oom killer killed something when it really came from a different 
source or was already exiting.

We have a differing opinion on what to consider the point of oom (the 
"notification line that has to be drawn").  My position is to notify 
userspace when the kernel has exhausted its capability to free memory 
without killing something.  In the case of current exiting or having a 
pending SIGKILL, memory is going to be freed, the oom killer simply needs 
to preempt the tasklist scan.  The situation is going to be remedied.  I 
defined the notification with this patch to only happen when the kernel 
can't free any memory without a kill so that userspace may do so itself.  
Michal concurred with that position.

So I'll repeat: if you are interested in situations when the limit is 
reached, use memory thresholds, if you are interested in situations where 
reclaim is struggling to free memory, use VMPRESSURE_CRITICAL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
