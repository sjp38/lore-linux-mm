Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 361666B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 05:39:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so16336744wic.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 02:38:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si3595665wiz.29.2015.09.04.02.38.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 02:38:58 -0700 (PDT)
Date: Fri, 4 Sep 2015 11:38:56 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 10/14] ring_buffer: Fix more races when terminating
 the producer in the benchmark
Message-ID: <20150904093856.GI22739@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-11-git-send-email-pmladek@suse.com>
 <20150803143323.426ea2fc@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150803143323.426ea2fc@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-08-03 14:33:23, Steven Rostedt wrote:
> On Tue, 28 Jul 2015 16:39:27 +0200
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > @@ -384,7 +389,7 @@ static int ring_buffer_consumer_thread(void *arg)
> >  
> >  static int ring_buffer_producer_thread(void *arg)
> >  {
> > -	while (!kthread_should_stop() && !kill_test) {
> > +	while (!break_test()) {
> >  		ring_buffer_reset(buffer);
> >  
> >  		if (consumer) {
> > @@ -393,11 +398,15 @@ static int ring_buffer_producer_thread(void *arg)
> >  		}
> >  
> >  		ring_buffer_producer();
> > -		if (kill_test)
> > +		if (break_test())
> >  			goto out_kill;
> >  
> >  		trace_printk("Sleeping for 10 secs\n");
> >  		set_current_state(TASK_INTERRUPTIBLE);
> > +		if (break_test()) {
> > +			__set_current_state(TASK_RUNNING);
> 
> Move the setting of the current state to after the out_kill label.

Please, find below the updated version of this patch.

I also reverted some changes in the consumer code. It never stays
in a loop for too long and it must stay in ring_buffer_producer()
until "reader_finish" variable is set.
