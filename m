Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070711.192829.08323972.davem@davemloft.net>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <20070711122324.GA21714@lst.de>
	 <1184203311.6005.664.camel@localhost.localdomain>
	 <20070711.192829.08323972.davem@davemloft.net>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 12:48:41 +1000
Message-Id: <1184208521.6005.695.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hch@lst.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-11 at 19:28 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 12 Jul 2007 11:21:51 +1000
> 
> > To do inter-guest (ie. inter-process) I/O you really have to make sure
> > the other side doesn't go away.
> 
> You should just let it exit and when it does you receive some kind of
> exit notification that resets your virtual device channel.
> 
> I think the reference counting approach is error and deadlock prone.
> Be more loose and let the events reset the virtual devices when
> guests go splat.

There are two places where we grab task refcnt.  One might be avoidable
(will test and get back) but the deferred wakeup isn't really:

        /* We cache one process to wakeup: helps for batching & wakes outside locks. */
        void set_wakeup_process(struct lguest *lg, struct task_struct *p)
        {
        	if (p == lg->wake)
        		return;
        
        	if (lg->wake) {
        		wake_up_process(lg->wake);
        		put_task_struct(lg->wake);
        	}
        	lg->wake = p;
        	if (lg->wake)
        		get_task_struct(lg->wake);
        }

We drop the lock after I/O, and then do this wakeup.  Meanwhile the
other task might have exited.

I could get rid of it, but I don't think there's anything wrong with the
code...

Cheers,
Rusty.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
