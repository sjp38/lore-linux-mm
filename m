Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B45A36B0034
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 14:18:12 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md4so6034048pbc.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 11:18:12 -0700 (PDT)
Date: Mon, 3 Jun 2013 11:18:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130601102058.GA19474@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130530150539.GA18155@dhcp22.suse.cz> <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com> <20130531081052.GA32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com> <20130601102058.GA19474@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Sat, 1 Jun 2013, Michal Hocko wrote:

> > Users obviously don't have the ability to attach processes to the root 
> > memcg.  They are constrained to their own subtree of memcgs.
> 
> OK, I assume those groups are generally untrusted, right? So you cannot
> let them register their oom handler even via an admin interface. This
> makes it a bit complicated because it makes much harder demands on the
> handler itself as it has to run under restricted environment.
> 

That's the point of the patch.  We want to allow users to register their 
own oom handler in a subtree (they may attach it to their own subtree root 
and wait on memory.oom_control of a child memcg with a limit less than 
that root) but not insist on an absolutely perfect implementation that can 
never fail when you run on many, many servers.  Userspace implementations 
do fail sometimes, we just accept that.

> I still do not see why you cannot simply read tasks file into a
> preallocated buffer. This would be few pages even for thousands of pids.
> You do not have to track processes as they come and go.
> 

What do you suggest when you read the "tasks" file and it returns -ENOMEM 
because kmalloc() fails because the userspace oom handler's memcg is also 
oom?  Obviously it's not a situation we want to get into, but unless you 
know that handler's exact memory usage across multiple versions, nothing 
else is sharing that memcg, and it's a perfect implementation, you can't 
guarantee it.  We need to address real world problems that occur in 
practice.

> As I said before. oom_delay_millisecs is actually really easy to be done
> from userspace. If you really need a safety break then you can register
> such a handler as a fallback. I am not familiar with eventfd internals
> much but I guess that multiple handlers are possible. The fallback might
> be enforeced by the admin (when a new group is created) or by the
> container itself. Would something like this work for your use case?
> 

You're suggesting another userspace process that solely waits for a set 
duration and then reenables the oom killer?  It faces all the same 
problems as the true userspace oom handler: it's own perfect 
implementation and it's own memcg constraints.

> > If that user is constrained to his or her own subtree, as previously
> > stated, there's also no way to login and rectify the situation at that
> > point and requires admin intervention or a reboot.
> 
> Yes, insisting on the same subtree makes the life much harder for oom
> handlers. I totally agree with you on that. I just feel that introducing
> a new knob to workaround user "inability" to write a proper handler
> (what ever that means) is not justified.
>  

It's not necessarily harder if you assign the userspace oom handlers to 
the root of your subtree with access to more memory than the children.  
There is no "inability" to write a proper handler, but when you have 
dozens of individual users implementing their own userspace handlers with 
changing memcg limits over time, then you might find it hard to have 
perfection every time.  If we had perfection, we wouldn't have to worry 
about oom in the first place.  We can't just let these gazillion memcgs 
sit spinning forever because they get stuck, either.  That's why we've 
used this solution for years as a failsafe.  Disabling the oom killer 
entirely, even for a memcg, is ridiculous, and if you don't have a grace 
period then oom handlers themselves just don't work.

> > Then why does "cat tasks" stall when my memcg is totally depleted of all 
> > memory?
> 
> if you run it like this then cat obviously needs some charged
> allocations. If you had a proper handler which mlocks its buffer for the
> read syscall then you shouldn't require any allocation at the oom time.
> This shouldn't be that hard to do without too much memory overhead. As I
> said we are talking about few (dozens) of pages per handler.
> 

I'm talking about the memory the kernel allocates when reading the "tasks" 
file, not userspace.  This can, and will, return -ENOMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
