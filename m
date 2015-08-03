Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1B69003C8
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 14:33:26 -0400 (EDT)
Received: by ioeg141 with SMTP id g141so153717275ioe.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 11:33:26 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0051.hostedemail.com. [216.40.44.51])
        by mx.google.com with ESMTP id zx8si6626769igc.15.2015.08.03.11.33.25
        for <linux-mm@kvack.org>;
        Mon, 03 Aug 2015 11:33:25 -0700 (PDT)
Date: Mon, 3 Aug 2015 14:33:23 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC PATCH 10/14] ring_buffer: Fix more races when terminating
 the producer in the benchmark
Message-ID: <20150803143323.426ea2fc@gandalf.local.home>
In-Reply-To: <1438094371-8326-11-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
	<1438094371-8326-11-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 28 Jul 2015 16:39:27 +0200
Petr Mladek <pmladek@suse.com> wrote:

> @@ -384,7 +389,7 @@ static int ring_buffer_consumer_thread(void *arg)
>  
>  static int ring_buffer_producer_thread(void *arg)
>  {
> -	while (!kthread_should_stop() && !kill_test) {
> +	while (!break_test()) {
>  		ring_buffer_reset(buffer);
>  
>  		if (consumer) {
> @@ -393,11 +398,15 @@ static int ring_buffer_producer_thread(void *arg)
>  		}
>  
>  		ring_buffer_producer();
> -		if (kill_test)
> +		if (break_test())
>  			goto out_kill;
>  
>  		trace_printk("Sleeping for 10 secs\n");
>  		set_current_state(TASK_INTERRUPTIBLE);
> +		if (break_test()) {
> +			__set_current_state(TASK_RUNNING);

Move the setting of the current state to after the out_kill label.

-- Steve

> +			goto out_kill;
> +		}
>  		schedule_timeout(HZ * SLEEP_TIME);
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
