Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFB76B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:18:51 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id b6so744464yha.8
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:18:51 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id q69si7267911yhd.195.2014.01.15.16.18.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 16:18:50 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id b6so746849yha.36
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:18:50 -0800 (PST)
Date: Wed, 15 Jan 2014 16:18:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: oom_kill: revert 3% system memory bonus for privileged
 tasks
In-Reply-To: <20140115234308.GB4407@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
References: <20140115234308.GB4407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Jan 2014, Johannes Weiner wrote:

> With a63d83f427fb ("oom: badness heuristic rewrite"), the OOM killer
> tries to avoid killing privileged tasks by subtracting 3% of overall
> memory (system or cgroup) from their per-task consumption.  But as a
> result, all root tasks that consume less than 3% of overall memory are
> considered equal, and so it only takes 33+ privileged tasks pushing
> the system out of memory for the OOM killer to do something stupid and
> kill sshd or dhclient.  For example, on a 32G machine it can't tell
> the difference between the 1M agetty and the 10G fork bomb member.
> 
> The changelog describes this 3% boost as the equivalent to the global
> overcommit limit being 3% higher for privileged tasks, but this is not
> the same as discounting 3% of overall memory from _every privileged
> task individually_ during OOM selection.
> 
> Revert back to the old priority boost of pretending root tasks are
> only a quarter of their actual size.
> 

Unfortunately, I think this could potentially be too much of a bonus.  On 
your same 32GB machine, if a root process is using 18GB and a user process 
is using 14GB, the user process ends up getting selected while the current 
discount of 3% still selects the root process.

I do like the idea of scaling this bonus depending on points, however.  I 
think it would be better if we could scale the discount but also limit it 
to some sane value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
