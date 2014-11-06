Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 51560280002
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:01:26 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 20so1363507yks.18
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:01:26 -0800 (PST)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com. [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id v9si6788926qat.45.2014.11.06.07.01.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 07:01:24 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id b13so1013764qcw.9
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:01:24 -0800 (PST)
Date: Thu, 6 Nov 2014 10:01:21 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106150121.GA25642@htj.dyndns.org>
References: <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105174609.GE28226@dhcp22.suse.cz>
 <20141105175527.GH14386@htj.dyndns.org>
 <20141106124953.GD7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106124953.GD7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu, Nov 06, 2014 at 01:49:53PM +0100, Michal Hocko wrote:
> On Wed 05-11-14 12:55:27, Tejun Heo wrote:
> > On Wed, Nov 05, 2014 at 06:46:09PM +0100, Michal Hocko wrote:
> > > Because out_of_memory can be called from mutliple paths. And
> > > the only interesting one should be the page allocation path.
> > > pagefault_out_of_memory is not interesting because it cannot happen for
> > > the frozen task.
> > 
> > Hmmm.... wouldn't that be broken by definition tho?  So, if the oom
> > killer is invoked from somewhere else than page allocation path, it
> > would proceed ignoring the disabled setting and would race against PM
> > freeze path all the same. 
> 
> Not really because try_to_freeze_tasks doesn't finish until _all_ tasks
> are frozen and a task in the page fault path cannot be frozen, can it?

We used to have freezing points deep in file system code which may be
reacheable from page fault.  Please take a step back and look at the
paragraph above.  Doesn't it sound extremely contrived and brittle
even if it's not outright broken?  What if somebody adds another oom
killing site somewhere else?  How can this possibly be a solution that
we intentionally implement?

> I mean there shouldn't be any problem to not invoke OOM killer under
> from the page fault path as well but that might lead to looping in the
> page fault path without any progress until freezer enables OOM killer on
> the failure path because the said task cannot be frozen.
> 
> Is this preferable?

Why would PM freezing make OOM killing fail?  That doesn't make much
sense.  Sure, it can block it for a finite duration for sync purposes
but making OOM killing fail seems the wrong way around.  We're doing
one thing for non-PM freezing and the other way around for PM
freezing, which indicates one of the two directions is wrong.

Shouldn't it be that OOM killing happening while PM freezing is in
progress cancels PM freezing rather than the other way around?  Find a
point in PM suspend/hibernation operation where everything must be
stable, disable OOM killing there and check whether OOM killing
happened inbetween and if so back out.  It seems rather obvious to me
that OOM killing has to have precedence over PM freezing.

Sure, once the system reaches a point where the whole system must be
in a stable state for snapshotting or whatever, disabling OOM killing
is fine but at that point the system is in a very limited execution
mode and sure won't be processing page faults from userland for
example and we can actually disable OOM killing knowing that anything
afterwards is ready to handle memory allocation failures.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
