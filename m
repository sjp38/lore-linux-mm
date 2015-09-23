Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5746B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:50:09 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so60877129wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:50:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ly8si10038590wic.103.2015.09.23.02.50.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Sep 2015 02:50:07 -0700 (PDT)
Date: Wed, 23 Sep 2015 11:50:06 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 09/18] mm/huge_page: Convert khugepaged() into kthread
 worker API
Message-ID: <20150923095006.GB12406@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-10-git-send-email-pmladek@suse.com>
 <20150922202604.GG17659@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150922202604.GG17659@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-09-22 16:26:04, Tejun Heo wrote:
> Hello,
> 
> On Mon, Sep 21, 2015 at 03:03:50PM +0200, Petr Mladek wrote:
> > +static int khugepaged_has_work(void)
> > +{
> > +	return !list_empty(&khugepaged_scan.mm_head) &&
> > +		khugepaged_enabled();
> > +}
> 
> Hmmm... no biggie but this is a bit bothering.

This function has been there even before and is used on more locations.
I have just moved the definition.

> > @@ -425,7 +447,10 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
> >  		return -EINVAL;
> >  
> >  	khugepaged_scan_sleep_millisecs = msecs;
> > -	wake_up_interruptible(&khugepaged_wait);
> > +	if (khugepaged_has_work())
> > +		mod_delayed_kthread_work(khugepaged_worker,
> > +					 &khugepaged_do_scan_work,
> > +					 0);
> 
> What's wrong with just doing the following?
> 
> 	if (khugepaged_enabled())
> 		mod_delayed_kthread_work(...);

It was just an optimization. It does not make sense to queue the work
if there is nothing to do.

Note that the timeout between the scans is there to throttle the work.
If all pages are scanned, the work stops re-queuing until
__khugepaged_enter() adds new job.

Thanks a lot for review. I am going to update the patchset according
to the other comments.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
