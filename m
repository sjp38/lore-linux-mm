Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 60E266B00A7
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:02:25 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id r20so1938357wiv.10
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:02:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si10169815wjw.50.2014.11.06.08.02.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 08:02:24 -0800 (PST)
Date: Thu, 6 Nov 2014 17:02:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106160223.GJ7202@dhcp22.suse.cz>
References: <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105174609.GE28226@dhcp22.suse.cz>
 <20141105175527.GH14386@htj.dyndns.org>
 <20141106124953.GD7202@dhcp22.suse.cz>
 <20141106150121.GA25642@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106150121.GA25642@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu 06-11-14 10:01:21, Tejun Heo wrote:
> On Thu, Nov 06, 2014 at 01:49:53PM +0100, Michal Hocko wrote:
> > On Wed 05-11-14 12:55:27, Tejun Heo wrote:
> > > On Wed, Nov 05, 2014 at 06:46:09PM +0100, Michal Hocko wrote:
> > > > Because out_of_memory can be called from mutliple paths. And
> > > > the only interesting one should be the page allocation path.
> > > > pagefault_out_of_memory is not interesting because it cannot happen for
> > > > the frozen task.
> > > 
> > > Hmmm.... wouldn't that be broken by definition tho?  So, if the oom
> > > killer is invoked from somewhere else than page allocation path, it
> > > would proceed ignoring the disabled setting and would race against PM
> > > freeze path all the same. 
> > 
> > Not really because try_to_freeze_tasks doesn't finish until _all_ tasks
> > are frozen and a task in the page fault path cannot be frozen, can it?
> 
> We used to have freezing points deep in file system code which may be
> reacheable from page fault.

If that is really the case then there is no way around and use
out_of_memory from the page fault path as well. I cannot say I would be
happy about that though. There should be ideally only single freezing
place. But that is another story.

> Please take a step back and look at the paragraph above.  Doesn't
> it sound extremely contrived and brittle even if it's not outright
> broken?  What if somebody adds another oom killing site somewhere
> else?

The only way to add an oom killing site is out_of_memory and that does
all the magic with my patch.

> How can this possibly be a solution that we intentionally implement?
>
> > I mean there shouldn't be any problem to not invoke OOM killer under
> > from the page fault path as well but that might lead to looping in the
> > page fault path without any progress until freezer enables OOM killer on
> > the failure path because the said task cannot be frozen.
> > 
> > Is this preferable?
> 
> Why would PM freezing make OOM killing fail?  That doesn't make much
> sense.  Sure, it can block it for a finite duration for sync purposes
> but making OOM killing fail seems the wrong way around.  

We cannot block in the allocation path because the request might come
from the freezer path itself (e.g. when suspending devices etc.).
At least this is my understanding why the original oom disable approach
was implemented.

> We're doing one thing for non-PM freezing and the other way around for
> PM freezing, which indicates one of the two directions is wrong.

Because those two paths are quite different in their requirements. The
cgroup freezer only cares about freezing tasks and it doesn't have to
care about tasks accessing a possibly half suspended device on their way
out.

> Shouldn't it be that OOM killing happening while PM freezing is in
> progress cancels PM freezing rather than the other way around?  Find a
> point in PM suspend/hibernation operation where everything must be
> stable, disable OOM killing there and check whether OOM killing
> happened inbetween and if so back out. 

This is freeze_processes AFAIU. I might be wrong of course but this is
the time since when nobody should be waking processes up because they
could access half suspended devices.

> It seems rather obvious to me that OOM killing has to have precedence
> over PM freezing.
> 
> Sure, once the system reaches a point where the whole system must be
> in a stable state for snapshotting or whatever, disabling OOM killing
> is fine but at that point the system is in a very limited execution
> mode and sure won't be processing page faults from userland for
> example and we can actually disable OOM killing knowing that anything
> afterwards is ready to handle memory allocation failures.

I am really confused now. This is basically what the final patch does
actually.  Here is the what I have currently just to make the further
discussion easier.
---
