Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C80816B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:10:12 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so198485266wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:10:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d73si28183272wma.57.2016.02.16.08.10.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:10:10 -0800 (PST)
Date: Tue, 16 Feb 2016 17:10:09 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4 04/22] kthread: Add create_kthread_worker*()
Message-ID: <20160216161009.GO3305@pathway.suse.cz>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-5-git-send-email-pmladek@suse.com>
 <20160125185339.GB3628@mtj.duckdns.org>
 <20160216154443.GW12548@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160216154443.GW12548@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2016-02-16 16:44:43, Petr Mladek wrote:
> On Mon 2016-01-25 13:53:39, Tejun Heo wrote:
> > On Mon, Jan 25, 2016 at 04:44:53PM +0100, Petr Mladek wrote:
> > > +struct kthread_worker *
> > > +create_kthread_worker_on_cpu(int cpu, const char namefmt[])
> > > +{
> > > +	if (cpu < 0 || cpu > num_possible_cpus())
> > > +		return ERR_PTR(-EINVAL);
> > 
> > Comparing cpu ID to num_possible_cpus() doesn't make any sense.  It
> > should either be testing against cpu_possible_mask or testing against
> > nr_cpu_ids.  Does this test need to be in this function at all?
> 
> I wanted to be sure. The cpu number is later passed to
> cpu_to_node(cpu) in kthread_create_on_cpu().
> 
> I am going to replace this with a check against nr_cpu_ids in
> kthread_create_on_cpu() which makes more sense.
> 
> I might be too paranoid. But this is slow path. People
> do mistakes...

I take it back. I will remove the check at all.
Michal Hocko persuaded me offline that it does not make
much sense. This function is used from kernel code.
I need to believe that the usage is sane at this level.
Also too many checks makes the code harder to read.

Thanks,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
