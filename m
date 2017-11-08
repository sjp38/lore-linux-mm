Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2C16B02D8
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 00:20:02 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v2so1342814pfa.10
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 21:20:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a7sor877160pfh.111.2017.11.07.21.20.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 21:20:01 -0800 (PST)
Date: Wed, 8 Nov 2017 14:19:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171108051955.GA468@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
 <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
 <20171107014015.GA1822@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107014015.GA1822@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org
Cc: Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

(Ccing Tejun)

On (11/07/17 10:40), Sergey Senozhatsky wrote:
> On (11/06/17 21:06), Tetsuo Handa wrote:
> > I tried your patch with warn_alloc() torture. It did not cause lockups.
> > But I felt that possibility of failing to flush last second messages (such
> > as SysRq-c or SysRq-b) to consoles has increased. Is this psychological?
> 
> do I understand it correctly that there are "lost messages"?
> 
> sysrq-b does an immediate emergency reboot. "normally" it's not expected
> to flush any pending logbuf messages because it's an emergency-reboot...
> but in fact it does. and this is why sysrq-b is not 100% reliable:
> 
> 	__handle_sysrq()
> 	{
> 	  pr_info("SysRq : ");
> 
> 	  op_p = __sysrq_get_key_op(key);
> 	  pr_cont("%s\n", op_p->action_msg);
> 
> 	    op_p->handler(key);
> 
> 	  pr_cont("\n");
> 	}
> 
> those pr_info()/pr_cont() calls can spoil sysrq-b, depending on how
> badly the system is screwed. if pr_info() deadlocks, then we never
> go to op_p->handler(key)->emergency_restart(). even if you suppress
> printing of info loglevel messages, pr_info() still goes to
> console_unlock() and prints [console_seq, log_next_seq] messages,
> if there any.
> 
> there is, however, a subtle behaviour change, I think.
> 
> previously, in some cases [?], pr_info("SysRq : ") from __handle_sysrq()
> would flush logbuf messages. now we have that "break out of console_unlock()
> loop even though there are pending messages, there is another CPU doing
> printk()". so sysrb-b instead of looping in console_unlock() goes directly
> to emergency_restart(). without the change it would have continued looping
> in console_unlock() and would have called emergency_restart() only when
> "console_seq == log_next_seq".
> 
> now... the "subtle" part here is that we had that thing:
> 	- *IF* __handle_sysrq() grabs the console_sem then it will not
> 	  return from console_unlock() until logbuf is empty. so
> 	  concurrent printk() messages won't get lost.
> 
> what we have now is:
> 	- if there are concurrent printk() then __handle_sysrq() does not
> 	  fully flush the logbuf *even* if it grabbed the console_sem.

the change goes further. I did express some of my concerns during the KS,
I'll just bring them to the list.


we now always shift printing from a save - scheduleable - context to
a potentially unsafe one - atomic. by example:

CPU0			CPU1~CPU10	CPU11

console_lock()

			printk();

console_unlock()			IRQ
 set console_owner			printk()
					 sees console_owner
					 set console_waiter
 sees console_waiter
 break
					 console_unlock()
					 ^^^^ lockup [?]


so we are forcibly moving console_unlock() from safe CPU0 to unsafe CPU11.
previously we would continue printing from a schedulable context.


another case. bare with me.

suppose that call_console_drivers() is slower than printk() -> log_store(),
which is often the case.

now assume the following:

CPU0				CPU1

IRQ				IRQ

printk()			printk()
printk()			printk()
printk()			printk()


which probably could have been handled something like this:

CPU0				CPU1

IRQ				IRQ

printk()			printk()
 log_store()
				 log_store()
 console_unlock()
  call_console_drivers()
				printk()
				 log_store()
 goto again;
  call_console_drivers()
				printk()
				 log_store()
 goto again;
  call_console_drivers()
printk()
 log_store()
  console_unlock()
   call_console_drivers()
printk()
 log_store()
  console_unlock()
   call_console_drivers()


so CPU0 printed all the messages.
CPU1 simply did 3 * log_store()
	// + spent some cycles on logbuf_lock spin_lock
	// + console_sem trylock


but now every CPU will do call_console_drivers() + busy loop.


CPU0				CPU1

IRQ				IRQ

printk()			printk()
 log_store()
				 log_store()
 console_unlock()
  set console_owner
				 sees console_owner
				 sets console_waiter
				 spin
  call_console_drivers()
  sees console_waiter
   break

printk()
 log_store()
				 console_unlock()
				  set console_owner
 sees console_owner
 sets console_waiter
 spin
				 call_console_drivers()
				 sees console_waiter
				  break

				printk()
				 log_store()
 console_unlock()
  set console_owner
				 sees console_owner
				 sets console_waiter
				 spin
  call_console_drivers()
  sees console_waiter
  break

printk()
 log_store()
				 console_unlock()
				  set console_owner
 sees console_owner
 sets console_waiter
 spin

				.... and so on

which not only brings the cost of call_console_drivers() from
CPU's own printk(), but it also brings the cost [busy spin] of
call_console_drivers() happening on _another_ CPU. am I wrong?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
