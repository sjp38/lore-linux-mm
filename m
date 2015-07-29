Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id ED58B6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:32:54 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so215082308wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:32:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p11si43242240wjw.192.2015.07.29.04.32.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 04:32:53 -0700 (PDT)
Date: Wed, 29 Jul 2015 13:32:49 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 07/14] mm/huge_page: Convert khugepaged() into
 kthread worker API
Message-ID: <20150729113249.GL2673@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-8-git-send-email-pmladek@suse.com>
 <20150728173635.GD5322@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728173635.GD5322@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-07-28 13:36:35, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 28, 2015 at 04:39:24PM +0200, Petr Mladek wrote:
> > -static void khugepaged_wait_work(void)
> > +static void khugepaged_wait_func(struct kthread_work *dummy)
> >  {
> >  	if (khugepaged_has_work()) {
> >  		if (!khugepaged_scan_sleep_millisecs)
> > -			return;
> > +			goto out;
> >  
> >  		wait_event_freezable_timeout(khugepaged_wait,
> > -					     kthread_should_stop(),
> > +					     !khugepaged_enabled(),
> >  			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
> > -		return;
> > +		goto out;
> >  	}
> >  
> >  	if (khugepaged_enabled())
> >  		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
> > +
> > +out:
> > +	if (khugepaged_enabled())
> > +		queue_kthread_work(&khugepaged_worker,
> > +				   &khugepaged_do_scan_work);
> >  }
> 
> There gotta be a better way to do this.  It's outright weird to
> convert it over to work item based interface and then handle idle
> periods by injecting wait work items.  If there's an external event
> which wakes up the worker, convert that to a queueing event.  If it's
> a timed event, implement a delayed work and queue that with delay.

I am going to give it a try.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
