Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id BDE286B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:53:11 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 20so4961167yks.4
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 20:53:11 -0800 (PST)
Received: from mail-gg0-x22f.google.com (mail-gg0-x22f.google.com [2607:f8b0:4002:c02::22f])
        by mx.google.com with ESMTPS id r4si9065399yhg.235.2014.01.21.20.53.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 20:53:10 -0800 (PST)
Received: by mail-gg0-f175.google.com with SMTP id c2so2916577ggn.34
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 20:53:10 -0800 (PST)
Date: Tue, 21 Jan 2014 20:53:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: oom_kill: revert 3% system memory bonus for privileged
 tasks
In-Reply-To: <20140116070709.GM6963@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com>
References: <20140115234308.GB4407@cmpxchg.org> <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com> <20140116070709.GM6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Jan 2014, Johannes Weiner wrote:

> > Unfortunately, I think this could potentially be too much of a bonus.  On 
> > your same 32GB machine, if a root process is using 18GB and a user process 
> > is using 14GB, the user process ends up getting selected while the current 
> > discount of 3% still selects the root process.
> > 
> > I do like the idea of scaling this bonus depending on points, however.  I 
> > think it would be better if we could scale the discount but also limit it 
> > to some sane value.
> 
> I just reverted to the /= 4 because we had that for a long time and it
> seemed to work.  I don't really mind either way as long as we get rid
> of that -3%.  Do you have a suggestion?
> 

How about simply using 3% of the root process's points so that root 
processes get some bonus compared to non-root processes with the same 
memory usage and it's scaled to the usage rather than amount of available 
memory?

So rather than points /= 4, we do

	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
		points -= (points * 3) / 100;

instead.  Sound good?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
