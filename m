Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC45A6B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:18:29 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 189so7600935iow.8
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:18:29 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0244.hostedemail.com. [216.40.44.244])
        by mx.google.com with ESMTPS id x79si2051374ita.122.2017.11.03.04.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 04:18:29 -0700 (PDT)
Date: Fri, 3 Nov 2017 07:18:24 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171103071824.1cf629ee@vmware.local.home>
In-Reply-To: <20171103101953.GA5280@quack2.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171102115625.13892e18@gandalf.local.home>
	<20171102130605.05e987e8@gandalf.local.home>
	<20171103101953.GA5280@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

On Fri, 3 Nov 2017 11:19:53 +0100
Jan Kara <jack@suse.cz> wrote:

> Hi,
> 
> On Thu 02-11-17 13:06:05, Steven Rostedt wrote:
> > +			if (spin) {
> > +				/* We spin waiting for the owner to release us */
> > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +				/* Owner will clear console_waiter on hand off */
> > +				while (!READ_ONCE(console_waiter))
> > +					cpu_relax();  
> 
> Hum, what prevents us from rescheduling here? And what if the process
> stored in console_owner is scheduled out? Both seem to be possible with
> CONFIG_PREEMPT kernel? Unless I'm missing something you will need to
> disable preemption in some places...

Yes you are missing something ;-)

> 
> Other than that I like the simplicity of your approach.
> 
> 								Honza
> 
> > +
> > +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> > +				printk_safe_exit_irqrestore(flags);

The above line re-enables interrupts. And is done for both the
console_owner and the console_waiter. These are only held with
interrupts disabled. Nothing will preempt it. In fact, if it could,
lockdep would complain (it did in when I screwed it up at first ;-)


-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
