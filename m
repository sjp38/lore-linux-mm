Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 670876B00B5
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:36:08 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id x3so1062255qcv.21
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:36:08 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com. [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id 69si12621985qge.37.2014.11.06.08.36.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 08:36:06 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id dc16so998328qab.6
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:36:06 -0800 (PST)
Date: Thu, 6 Nov 2014 11:28:45 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106162845.GD25642@htj.dyndns.org>
References: <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105174609.GE28226@dhcp22.suse.cz>
 <20141105175527.GH14386@htj.dyndns.org>
 <20141106124953.GD7202@dhcp22.suse.cz>
 <20141106150121.GA25642@htj.dyndns.org>
 <20141106160223.GJ7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106160223.GJ7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu, Nov 06, 2014 at 05:02:23PM +0100, Michal Hocko wrote:
> > Why would PM freezing make OOM killing fail?  That doesn't make much
> > sense.  Sure, it can block it for a finite duration for sync purposes
> > but making OOM killing fail seems the wrong way around.  
> 
> We cannot block in the allocation path because the request might come
> from the freezer path itself (e.g. when suspending devices etc.).
> At least this is my understanding why the original oom disable approach
> was implemented.

I was saying that it could temporarily block either direction to
implement proper synchronization while guaranteeing forward progress.

> > We're doing one thing for non-PM freezing and the other way around for
> > PM freezing, which indicates one of the two directions is wrong.
> 
> Because those two paths are quite different in their requirements. The
> cgroup freezer only cares about freezing tasks and it doesn't have to
> care about tasks accessing a possibly half suspended device on their way
> out.

I don't think the fundamental relationship between freezing and oom
killing are different between the two and the failure to recognize
that is what's leading to these weird issues.

> > Shouldn't it be that OOM killing happening while PM freezing is in
> > progress cancels PM freezing rather than the other way around?  Find a
> > point in PM suspend/hibernation operation where everything must be
> > stable, disable OOM killing there and check whether OOM killing
> > happened inbetween and if so back out. 
> 
> This is freeze_processes AFAIU. I might be wrong of course but this is
> the time since when nobody should be waking processes up because they
> could access half suspended devices.

No, you're doing it before freezing starts.  The system is in no way
in a quiescent state at that point.

> > It seems rather obvious to me that OOM killing has to have precedence
> > over PM freezing.
> > 
> > Sure, once the system reaches a point where the whole system must be
> > in a stable state for snapshotting or whatever, disabling OOM killing
> > is fine but at that point the system is in a very limited execution
> > mode and sure won't be processing page faults from userland for
> > example and we can actually disable OOM killing knowing that anything
> > afterwards is ready to handle memory allocation failures.
> 
> I am really confused now. This is basically what the final patch does
> actually.  Here is the what I have currently just to make the further
> discussion easier.

Please see above.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
