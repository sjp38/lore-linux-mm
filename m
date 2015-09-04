Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id E2A3F6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 09:15:37 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so11974341igc.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 06:15:37 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0062.hostedemail.com. [216.40.44.62])
        by mx.google.com with ESMTP id h4si2444797iga.101.2015.09.04.06.15.36
        for <linux-mm@kvack.org>;
        Fri, 04 Sep 2015 06:15:36 -0700 (PDT)
Date: Fri, 4 Sep 2015 09:15:33 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC PATCH 09/14] ring_buffer: Initialize completions
 statically in the benchmark
Message-ID: <20150904091533.77752d3e@gandalf.local.home>
In-Reply-To: <20150904093126.GH22739@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
	<1438094371-8326-10-git-send-email-pmladek@suse.com>
	<20150803143109.0b13925b@gandalf.local.home>
	<20150904093126.GH22739@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 4 Sep 2015 11:31:26 +0200
Petr Mladek <pmladek@suse.com> wrote:

> 1st scenario:
> -------------
> 
> CPU0					CPU1
> 
> ring_buffer_producer_thread()
>   wake_up_process(consumer);
>   wait_for_completion(&read_start);
> 
> 					ring_buffer_consumer_thread()
> 					  complete(&read_start);
> 
>   ring_buffer_producer()
>     # producing data in
>     # the do-while cycle
> 
> 					  ring_buffer_consumer();
> 					    # reading data
> 					    # got error

So you're saying the error condition can cause this race? OK, I'll
admit that. Although, I don't think it's that big of a bug because the
error condition will also trigger a WARN_ON() and it means the ring
buffer code is broken, which also means the kernel is broken. Things
that go wrong after that is just tough luck.

But I'm not saying we couldn't fix it either.

> 					    # set kill_test = 1;
> 					    set_current_state(
> 						TASK_INTERRUPTIBLE);
> 					    if (reader_finish)  # false
> 					    schedule();
> 
>     # producer still in the middle of
>     # do-while cycle
>     if (consumer && !(cnt % wakeup_interval))
>       wake_up_process(consumer);
> 
> 					    # spurious wakeup
> 					    while (!reader_finish &&
> 						   !kill_test)
> 					    # leaving because
> 					    # kill_test == 1
> 					    reader_finish = 0;
> 					    complete(&read_done);
> 
> 1st BANG: We might access uninitialized "read_done" if this is the
> 	  the first round.
> 
>     # producer finally leaving
>     # the do-while cycle because kill_test == 1;
> 
>     if (consumer) {
>       reader_finish = 1;
>       wake_up_process(consumer);
>       wait_for_completion(&read_done);
> 
> 2nd BANG: This will never complete because consumer already did
> 	  the completion.
> 
> 2nd scenario:
> -------------
> 
> CPU0					CPU1
> 
> ring_buffer_producer_thread()
>   wake_up_process(consumer);
>   wait_for_completion(&read_start);
> 
> 					ring_buffer_consumer_thread()
> 					  complete(&read_start);
> 
>   ring_buffer_producer()
>     # CPU3 removes the module	  <--- difference from
>     # and stops producer          <--- the 1st scenario
>     if (kthread_should_stop())
>       kill_test = 1;
> 
> 					  ring_buffer_consumer();
> 					    while (!reader_finish &&
> 						   !kill_test)
> 					    # kill_test == 1 => we never go
> 					    # into the top level while()
> 					    reader_finish = 0;
> 					    complete(&read_done);
> 
>     # producer still in the middle of
>     # do-while cycle
>     if (consumer && !(cnt % wakeup_interval))
>       wake_up_process(consumer);
> 
> 					    # spurious wakeup
> 					    while (!reader_finish &&
> 						   !kill_test)
> 					    # leaving because kill_test == 1
> 					    reader_finish = 0;
> 					    complete(&read_done);
> 
> BANG: We are in the same "bang" situations as in the 1st scenario.

This scenario I believe is a true bug, because it can happen on a
kernel that is not broken.

> 
> Root of the problem:
> --------------------
> 
> ring_buffer_consumer() must complete "read_done" only when "reader_finish"
> variable is set. It must not be skipped because of other conditions.

"It must not be skipped due to other conditions."

> 
> Note that we still must keep the check for "reader_finish" in a loop
> because there might be the spurious wakeup as described in the

"might be spurious wakeups"

> above scenarios..
> 
> Solution:
> ----------
> 
> The top level cycle in ring_buffer_consumer() will finish only when
> "reader_finish" is set. The data will be read in "while-do" cycle
> so that they are not read after an error (kill_test == 1) and
> the spurious wake up.

"or a spurious wake up"

> 
> In addition, "reader_finish" is manipulated by the producer thread.
> Therefore we add READ_ONCE() to make sure that the fresh value is
> read in each cycle. Also we add the corresponding barrier
> to synchronize the sleep check.
> 
> Next we set back TASK_RUNNING state for the situation when we
> did not sleep.

"Next we set the state back to TASK_RUNNING for the situation where we
did not sleep"

> 
> Just from paranoid reasons, we initialize both completions statically.
> It should be more safe if there is other race that we do not know of.

"This is safer, in case there are other races that we are unaware of."


> 
> As a side effect we could remove the memory barrier from
> ring_buffer_producer_thread(). IMHO, this was the reason of

"the reason for"

> the barrier. ring_buffer_reset() uses spin locks that should
> provide the needed memory barrier for using the buffer.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>
> ---
>  kernel/trace/ring_buffer_benchmark.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
> index a1503a027ee2..045e0a24c2a0 100644
> --- a/kernel/trace/ring_buffer_benchmark.c
> +++ b/kernel/trace/ring_buffer_benchmark.c
> @@ -24,8 +24,8 @@ struct rb_page {
>  static int wakeup_interval = 100;
>  
>  static int reader_finish;
> -static struct completion read_start;
> -static struct completion read_done;
> +static DECLARE_COMPLETION(read_start);
> +static DECLARE_COMPLETION(read_done);
>  
>  static struct ring_buffer *buffer;
>  static struct task_struct *producer;
> @@ -178,10 +178,14 @@ static void ring_buffer_consumer(void)
>  	read_events ^= 1;
>  
>  	read = 0;
> -	while (!reader_finish && !kill_test) {
> -		int found;
> +	/*
> +	 * Always wait until we are asked to finish and the producer
> +	 * is ready to wait for the completion.

"Continue running until the producer specifically asks to stop and is
ready for the completion."

> +	 */
> +	while (!READ_ONCE(reader_finish)) {
> +		int found = 1;
>  
> -		do {
> +		while (found && !kill_test) {
>  			int cpu;
>  
>  			found = 0;
> @@ -195,17 +199,29 @@ static void ring_buffer_consumer(void)
>  
>  				if (kill_test)
>  					break;
> +
>  				if (stat == EVENT_FOUND)
>  					found = 1;
> +
>  			}
> -		} while (found && !kill_test);
> +		}
>  
> +		/*
> +		 * Sleep a bit. Producer with wake up us when some more data
> +		 * are available or when we should finish reading.

"Wait till the producer wakes us up when there is more data available or
when the producer wants us to finish reading"

> +		 */
>  		set_current_state(TASK_INTERRUPTIBLE);
> +		/*
> +		 * Make sure that we read the updated finish variable
> +		 * before producer tries to wakeup us.
> +		 */
> +		smp_rmb();

The above is unneeded. Look at the definition of set_current_state().

>  		if (reader_finish)
>  			break;
>  
>  		schedule();
>  	}
> +	__set_current_state(TASK_RUNNING);
>  	reader_finish = 0;
>  	complete(&read_done);
>  }
> @@ -389,13 +405,10 @@ static int ring_buffer_consumer_thread(void *arg)
>  
>  static int ring_buffer_producer_thread(void *arg)
>  {
> -	init_completion(&read_start);
> -
>  	while (!kthread_should_stop() && !kill_test) {
>  		ring_buffer_reset(buffer);
>  
>  		if (consumer) {
> -			smp_wmb();
>  			wake_up_process(consumer);
>  			wait_for_completion(&read_start);
>  		}

Please make the above changes and submit the patch again as a separate
patch.

Thanks!

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
