Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 53C366B0036
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 02:07:14 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id u12so900004bkz.14
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 23:07:13 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id kr4si4562022bkb.49.2014.01.15.23.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 23:07:13 -0800 (PST)
Date: Thu, 16 Jan 2014 02:07:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: oom_kill: revert 3% system memory bonus for
 privileged tasks
Message-ID: <20140116070709.GM6963@cmpxchg.org>
References: <20140115234308.GB4407@cmpxchg.org>
 <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 15, 2014 at 04:18:47PM -0800, David Rientjes wrote:
> On Wed, 15 Jan 2014, Johannes Weiner wrote:
> 
> > With a63d83f427fb ("oom: badness heuristic rewrite"), the OOM killer
> > tries to avoid killing privileged tasks by subtracting 3% of overall
> > memory (system or cgroup) from their per-task consumption.  But as a
> > result, all root tasks that consume less than 3% of overall memory are
> > considered equal, and so it only takes 33+ privileged tasks pushing
> > the system out of memory for the OOM killer to do something stupid and
> > kill sshd or dhclient.  For example, on a 32G machine it can't tell
> > the difference between the 1M agetty and the 10G fork bomb member.
> > 
> > The changelog describes this 3% boost as the equivalent to the global
> > overcommit limit being 3% higher for privileged tasks, but this is not
> > the same as discounting 3% of overall memory from _every privileged
> > task individually_ during OOM selection.
> > 
> > Revert back to the old priority boost of pretending root tasks are
> > only a quarter of their actual size.
> > 
> 
> Unfortunately, I think this could potentially be too much of a bonus.  On 
> your same 32GB machine, if a root process is using 18GB and a user process 
> is using 14GB, the user process ends up getting selected while the current 
> discount of 3% still selects the root process.
> 
> I do like the idea of scaling this bonus depending on points, however.  I 
> think it would be better if we could scale the discount but also limit it 
> to some sane value.

I just reverted to the /= 4 because we had that for a long time and it
seemed to work.  I don't really mind either way as long as we get rid
of that -3%.  Do you have a suggestion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
