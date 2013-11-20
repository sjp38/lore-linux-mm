Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BFF966B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:25:37 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so5268479pab.33
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:25:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.193])
        by mx.google.com with SMTP id xa2si14701510pab.171.2013.11.20.09.25.35
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:25:36 -0800 (PST)
Received: by mail-la0-f48.google.com with SMTP id n7so7402431lam.7
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:25:33 -0800 (PST)
Date: Wed, 20 Nov 2013 18:25:16 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: user defined OOM policies
Message-ID: <20131120172511.GB1848@hp530>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi David

On Wed, Nov 20, 2013 at 12:02:20AM -0800, David Rientjes wrote:
> On Tue, 19 Nov 2013, Michal Hocko wrote:
> 
> > > We have basically ended up with 3 options AFAIR:
> > > 	1) allow memcg approach (memcg.oom_control) on the root level
> > >            for both OOM notification and blocking OOM killer and handle
> > >            the situation from the userspace same as we can for other
> > > 	   memcgs.
> > 
> > This looks like a straightforward approach as the similar thing is done
> > on the local (memcg) level. There are several problems though.
> > Running userspace from within OOM context is terribly hard to do
> > right.
> 
> Not sure it's hard if you have per-memcg memory reserves which I've 
> brought up in the past with true and complete kmem accounting.  Even if 
> you don't allocate slab, it guarantees that there will be at least a 
> little excess memory available so that the userspace oom handler isn't oom 
> itself.
> 
> This involves treating processes waiting on memory.oom_control to be 
> treated as a special class so that they are allowed to allocate an 
> additional pre-configured amount of memory.  For non-root memcgs, this 
> would simply be a dummy usage that would be charged to the memcg when the 
> oom notification is registered and actually accessible only by the oom 
> handler itself while memcg->under_oom.  For root memcgs, this would simply 
> be a PF_MEMALLOC type behavior that dips into per-zone memory reserves.
> 
> > This is true even in the memcg case and we strongly discurage
> > users from doing that. The global case has nothing like outside of OOM
> > context though. So any hang would blocking the whole machine.
> 
> Why would there be a hang if the userspace oom handlers aren't actually 
> oom themselves as described above?
> 
> I'd suggest against the other two suggestions because hierarchical 
> per-memcg userspace oom handlers are very powerful and can be useful 
> without actually killing anything at all, and parent oom handlers can 
> signal child oom handlers to free memory in oom conditions (in other 
> words, defer a parent oom condition to a child's oom handler upon 

Is not vmpressure notifications was designed for that purpose?

Vladimir

> notification).  I was planning on writing a liboom library that would lay 
> the foundation for how this was supposed to work and some generic 
> functions that make use of the per-memcg memory reserves.
> 
> So my plan for the complete solution was:
> 
>  - allow userspace notification from the root memcg on system oom 
>    conditions,
> 
>  - implement a memory.oom_delay_millisecs timeout so that the kernel 
>    eventually intervenes if userspace fails to respond, including for
>    system oom conditions, for whatever reason which would be set to 0
>    if no userspace oom handler is registered for the notification, and
> 
>  - implement per-memcg reserves as described above so that userspace oom 
>    handlers have access to memory even in oom conditions as an upfront
>    charge and have the ability to free memory as necessary.
> 
> We already have the ability to do the actual kill from userspace, both the 
> system oom killer and the memcg oom killer grants access to memory 
> reserves for any process needing to allocate memory if it has a pending 
> SIGKILL which we can send from userspace.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
