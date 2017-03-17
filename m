Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E49C6B0390
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:07:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q126so129233274pga.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:07:32 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e13si7841876pgn.345.2017.03.17.01.07.30
        for <linux-mm@kvack.org>;
        Fri, 17 Mar 2017 01:07:31 -0700 (PDT)
Date: Fri, 17 Mar 2017 17:07:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317080724.GA30170@bbox>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
 <1489689381.2733.114.camel@linux.intel.com>
 <20170317074707.GB26298@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317074707.GB26298@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Fri, Mar 17, 2017 at 08:47:08AM +0100, Michal Hocko wrote:
> On Thu 16-03-17 11:36:21, Tim Chen wrote:
> [...]
> > Perhaps we can only do this expedited exit only when there are idle cpus around.
> > We can use the root sched domain's overload indicator for such a quick check.
> 
> This is not so easy, I am afraid. Those CPUs might be idle for a good
> reason (power saving etc.). You will never know by simply checking
> one metric. This is why doing these optimistic parallelization
> optimizations is far from trivial. This is not the first time somebody
> wants to do this.  People are trying to make THP migration faster
> doing the similar thing. I guess we really need a help from the
> scheduler to do this properly, though. I've been thinking about an API
> (e.g. try_to_run_in_backgroun) which would evaluate all these nasty
> details and either return with -EBUSY or kick the background thread to
> accomplish the work if the system is reasonably idle. I am not really

I agree with Michal's opinion.

In fact, I had prototyped zram parallel write(i.e., if there are many
CPU in the system, zram can compress a bio's pages in parallel via
multiple CPUs) and it seems to work well but my concern was out of
control about power, cpu load, wakeup latency and so on.

> sure whether such an API is viable though.  Peter, what do you think?

If scheduler can support such API(ie, return true and queue the job
if new job is scheduled into other CPU right now because there is
idle CPU in the system), it would be really great for things which
want to use multiple CPU power in parallel to complete the job asap.
Of course, it could sacrifice power but it's trade-off, IMHO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
