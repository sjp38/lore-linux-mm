Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id E6FA86B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 20:36:26 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so2967052yho.2
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:36:26 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id u24si22364900yhg.206.2013.11.25.17.36.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 17:36:26 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so3490350yhz.8
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:36:25 -0800 (PST)
Date: Mon, 25 Nov 2013 17:36:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131121171307.GB16703@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311251731430.27270@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <20131120172119.GA1848@hp530> <20131120173357.GC18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201937120.7167@chino.kir.corp.google.com>
 <20131121171307.GB16703@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Murzin <murzin.v@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 21 Nov 2013, Michal Hocko wrote:

> > It's an interesting idea but unfortunately a non-starter for us because 
> > our users don't have root,
> 
> I wouldn't see this as a problem. You can still have a module which
> exports the notification interface you need. Including timeout
> fallback. That would be trivial to implement and maybe more appropriate
> to very specific environments. Moreover the global OOM handling wouldn't
> be memcg bound.
> 

The memcg userspace oom handlers are effectively system userspace oom 
handlers for everything at that memcg and its descendant memcgs, the 
interface for the system oom handler and the memcg oom handlers would be 
identical.  We could certainly make the hook into a module by defining 
some sort of API that could be exported, but I believe the proposal 
empowers userspace to handle the oom situations in all possible scenarios 
(notification, memory reserve, timeout) that it would stand alone as the 
only user in the kernel of such an API and that API itself makes the code 
unnecessarily complex.

> > we create their memcg tree and then chown it to the user.  They can
> > freely register for oom notifications but cannot load their own kernel
> > modules for their own specific policy.
> 
> yes I see but that requires just a notification interface. It doesn't
> have to be memcg specific, right?

They also need the memory reserve to do anything useful when the oom 
handler wakes up, so you'd need an API exported to modules that allows you 
to define the set of processes allowed to access such a reserve.  So the 
kernel code providing the needed functionality (notification, reserve, 
timeout) remains constant for any possible userspace oom handler.  Unless 
you're thinking of a possible implementation that can't be addressed in 
this way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
