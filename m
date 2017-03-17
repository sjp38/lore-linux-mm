Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 552626B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 08:59:33 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u48so13525962wrc.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 05:59:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p201si3156017wme.108.2017.03.17.05.59.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 05:59:32 -0700 (PDT)
Date: Fri, 17 Mar 2017 13:59:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317125928.GG26298@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
 <1489689381.2733.114.camel@linux.intel.com>
 <20170317074707.GB26298@dhcp22.suse.cz>
 <20170317123315.GA1929@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317123315.GA1929@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Fri 17-03-17 20:33:15, Aaron Lu wrote:
> On Fri, Mar 17, 2017 at 08:47:08AM +0100, Michal Hocko wrote:
> > On Thu 16-03-17 11:36:21, Tim Chen wrote:
> > [...]
> > > Perhaps we can only do this expedited exit only when there are idle cpus around.
> > > We can use the root sched domain's overload indicator for such a quick check.
> > 
> > This is not so easy, I am afraid. Those CPUs might be idle for a good
> > reason (power saving etc.). You will never know by simply checking
> 
> Is it that those CPUs are deliberately put into idle mode to save power?

I am not a scheduler expert. All I know is that there is strong pressure
to make the schedule power aware and so some cpus are kept idle while
the workload is spread over other (currently active) cpus. And all I am
trying to tell is that this will be hard to guess without any assistance
from the scheduler. Especially when this should be long term
maintainable.

> IIRC, idle injection driver could be used to do this and if so, the
> injected idle task is a realtime one so the spawned kworker will not be
> able to preempt(disturb) it.
> 
> > one metric. This is why doing these optimistic parallelization
> > optimizations is far from trivial. This is not the first time somebody
> > wants to do this.  People are trying to make THP migration faster
> > doing the similar thing. I guess we really need a help from the
> > scheduler to do this properly, though. I've been thinking about an API
> > (e.g. try_to_run_in_backgroun) which would evaluate all these nasty
> > details and either return with -EBUSY or kick the background thread to
> > accomplish the work if the system is reasonably idle. I am not really
> > sure whether such an API is viable though.  Peter, what do you think?
> 
> I would very much like to know what these nasty details are and what
> 'reasonably idle' actually means, I think they are useful to understand
> the problem and define the API.

I would love to give you more specific information but I am not sure
myself. All I know is that the scheduler is the only place where we
have at least some idea about the recent load characteristics and some
policies on top. And that is why I _think_ we need to have an api and
which cooperates with the scheduler.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
