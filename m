Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE8196B025F
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:06:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r28so16138pgu.1
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:06:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c80si2152319pfl.173.2018.01.16.08.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:06:37 -0800 (PST)
Date: Tue, 16 Jan 2018 11:06:33 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116110633.56f48cf7@gandalf.local.home>
In-Reply-To: <20180116061013.GA19801@jagdpanzerIV>
References: <20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180112025612.GB6419@jagdpanzerIV>
	<20180111222140.7fd89d52@gandalf.local.home>
	<20180112100544.GA441@jagdpanzerIV>
	<20180112072123.33bb567d@gandalf.local.home>
	<20180113072834.GA1701@tigerII.localdomain>
	<20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
	<20180115115013.cyeocszurvguc3xu@pathway.suse.cz>
	<20180116061013.GA19801@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue, 16 Jan 2018 15:10:13 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> overall that's very close to what I have in one of my private branches.
> console_trylock_spinning() for some reason does not perform really
> well on my made-up internal printk torture tests. it seems that I

One thing I noticed in my test with the module that does printks on all
cpus, was that the patch spreads out the processing of the consoles.
Before my patch, one printk user would be doing all the work, and all
the other printks only had to load their data into the logbuf then
exit. The majority of printks took a few microseconds, which looks
great if you ignore the one worker that is taking milliseconds to
complete. After my patch, since a printk that comes in while another
one was running would block, then it would start printing, it did
lengthen the time for individual printks to finish. Worst case it
would double the time to do printk. But it removed the burden of a
single printk doing all the work for all new printks that came in.

In other words, I would expect this to make printk on average slower.
But no longer unlimited.

-- Steve


> have a much better stability (no lockups and so on) when I also let
> printk_kthread to sleep on console_sem(). but I will look further.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
