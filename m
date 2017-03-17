Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C624F6B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:05:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n11so3719621wma.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:05:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si11146982wry.83.2017.03.17.06.05.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 06:05:15 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:05:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317130512.GH26298@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
 <1489689381.2733.114.camel@linux.intel.com>
 <20170317074707.GB26298@dhcp22.suse.cz>
 <20170317125333.xyhm5fl2srygxcbv@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317125333.xyhm5fl2srygxcbv@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Fri 17-03-17 13:53:33, Peter Zijlstra wrote:
> On Fri, Mar 17, 2017 at 08:47:08AM +0100, Michal Hocko wrote:
> > On Thu 16-03-17 11:36:21, Tim Chen wrote:
> > [...]
> > > Perhaps we can only do this expedited exit only when there are idle cpus around.
> > > We can use the root sched domain's overload indicator for such a quick check.
> > 
> > This is not so easy, I am afraid. Those CPUs might be idle for a good
> > reason (power saving etc.). You will never know by simply checking
> > one metric. This is why doing these optimistic parallelization
> > optimizations is far from trivial. This is not the first time somebody
> > wants to do this.  People are trying to make THP migration faster
> > doing the similar thing. I guess we really need a help from the
> > scheduler to do this properly, though. I've been thinking about an API
> > (e.g. try_to_run_in_backgroun) which would evaluate all these nasty
> > details and either return with -EBUSY or kick the background thread to
> > accomplish the work if the system is reasonably idle. I am not really
> > sure whether such an API is viable though. 
> 
> > Peter, what do you think?
> 
> Much pain lies this way.

I somehow exptected this answer ;)
 
> Also, -enocontext.

Well, the context is that there are more users emerging which would like
to move some part of the heavy operation (e.g. munmap in exit or THP
migration) to the background thread because that operation can be split
and parallelized. kworker API is used for this purpose currently and I
believe that this is not the right approach because optimization for one
workload might be too disruptive on anybody else. On the other side
larger machines which would benefit from these optimizations are more
likely to have idle CPUs to (ab)use. So the idea was to provide an API
which would tell whether kicking a background worker(s) to accomplish
the task is feasible. The scheduler sounds like the best candidate to
ask this question to me. I might be wrong here of course but a
centralized API sounds like a better approach than ad-hoc solutions
developed for each particular usecase.  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
