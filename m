Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE9526B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 07:08:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n6so9875853pfg.19
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:08:25 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m82si9628370pfi.343.2018.01.15.04.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jan 2018 04:08:25 -0800 (PST)
Date: Mon, 15 Jan 2018 07:08:21 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115070821.40f044d6@gandalf.local.home>
In-Reply-To: <20180112125536.GC24497@linux.suse>
References: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180112025612.GB6419@jagdpanzerIV>
	<20180111222140.7fd89d52@gandalf.local.home>
	<20180112100544.GA441@jagdpanzerIV>
	<20180112072123.33bb567d@gandalf.local.home>
	<20180112125536.GC24497@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018 13:55:37 +0100
Petr Mladek <pmladek@suse.com> wrote:

> > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > PREEMPT kernels than !PREEMPT ones.  
> 
> I would say that the patch improves also console_unlock() but only in
> non-preemttive context.
> 
> By other words, it makes console_unlock() finite in preemptible context
> (limited by buffer size). It might still be unlimited in
> non-preemtible context.

Since I'm worried most about printk(), I would argue to make printk
console unlock always non-preempt.

	preempt_disable();
	if (console_trylock_spinning())
		console_unlock();
	preempt_enable();

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
