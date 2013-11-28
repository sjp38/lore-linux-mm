Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id B138C6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 21:38:35 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so5730266yhl.34
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:38:35 -0800 (PST)
Received: from mail-yh0-x22e.google.com (mail-yh0-x22e.google.com [2607:f8b0:4002:c01::22e])
        by mx.google.com with ESMTPS id k26si29741735yha.254.2013.11.27.18.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 18:38:34 -0800 (PST)
Received: by mail-yh0-f46.google.com with SMTP id l109so5662843yhq.19
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:38:34 -0800 (PST)
Date: Wed, 27 Nov 2013 18:38:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131128021809.GI3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
 <20131128021809.GI3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> > The task that is bypassing the memcg charge to the root memcg may not be 
> > the process that is chosen by the oom killer, and it's possible the amount 
> > of memory freed by killing the victim is less than the amount of memory 
> > bypassed.
> 
> That's true, though unlikely.
> 

Well, the "goto bypass" allows it and it's trivial to cause by 
manipulating /proc/pid/oom_score_adj values to prefer processes with very 
little rss.  It will just continue looping and killing processes as they 
are forked and never cause the memcg to free memory below its limit.  At 
least the "goto nomem" allows us to free some memory instead of leaking to 
the root memcg.

> > Were you targeting these to 3.13 instead?  If so, it would have already 
> > appeared in 3.13-rc1 anyway.  Is it still a work in progress?
> 
> I don't know how to answer this question.
> 

It appears as though this work is being developed in Linus's tree rather 
than -mm, so I'm asking if we should consider backing some of it out for 
3.14 instead.

> > Should we be checking mem_cgroup_margin() here to ensure 
> > task_in_memcg_oom() is still accurate and we haven't raced by freeing 
> > memory?
> 
> We would have invoked the OOM killer long before this point prior to
> my patches.  There is a line we draw and from that point on we start
> killing things.  I tried to explain multiple times now that there is
> no race-free OOM killing and I'm tired of it.  Convince me otherwise
> or stop repeating this non-sense.
> 

In our internal kernel we call mem_cgroup_margin() with the order of the 
charge immediately prior to sending the SIGKILL to see if it's still 
needed even after selecting the victim.  It makes the race smaller.

It's obvious that after the SIGKILL is sent, either from the kernel or 
from userspace, that memory might subsequently be freed or another process 
might exit before the process killed could even wake up.  There's nothing 
we can do about that since we don't have psychic abilities.  I think we 
should try to reduce the chance for unnecessary oom killing as much as 
possible, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
