Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A47016B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:16:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so139014405pgc.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:16:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x15si8639534pgc.190.2017.03.17.06.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 06:16:54 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:16:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317131650.2xtsbh4rwd7qtzef@hirez.programming.kicks-ass.net>
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
Cc: Michal Hocko <mhocko@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Fri, Mar 17, 2017 at 08:33:15PM +0800, Aaron Lu wrote:
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

No, forced idle injection is an abomination.

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

A CPU being idle doesn't mean it'll be idle long enough to do your
additional work.

The CPU not being idle affects scheduling latency. It also increases
power usage and thermals.

If your workload wants peak single threaded throughput, making the other
CPUs do work will lower its turbo boost range for example.

An 'obvious' solution that doesn't work is an idle scheduler; its an
instant priority inversion if you take locks there. Not to mention you
loose any fwd progress guarantees for any work you put in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
