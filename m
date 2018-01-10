Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6A906B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:42:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f8so11921694pgs.9
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:42:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f64si12516602plf.473.2018.01.10.10.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:42:00 -0800 (PST)
Date: Wed, 10 Jan 2018 13:41:57 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110134157.1c3ce4b9@vmware.local.home>
In-Reply-To: <20180110181252.GK3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180110181252.GK3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 10:12:52 -0800
Tejun Heo <tj@kernel.org> wrote:

> Hello, Steven.
> 
> So, everything else on your message, sure.  You do what you have to
> do, but I really don't understand the following part, and this has
> been the main source of frustration in the whole discussion.
> 
> On Wed, Jan 10, 2018 at 01:05:17PM -0500, Steven Rostedt wrote:
> > You on the other hand are showing unrealistic scenarios, and crying
> > that it's what you see in production, with no proof of it.  
> 
> I've explained the same scenario multiple times.  Unless you're
> assuming that I'm lying, it should be amply clear that the scenario is
> unrealistic - we've been seeing them taking place repeatedly for quite
> a while.

The one scenario you did show was the recursive OOM messages, and as
Peter Zijlstra pointed out that's more of a bug in the net console than
a printk bug.

> 
> What I don't understand is why we can't address this seemingly obvious
> problem.  If there are technical reasons and the consensus is to not
> solve this within flushing logic, sure, we can deal with it otherwise,
> but we at least have to be able to agree that there are actual issues
> here, no?

The issue with the solution you want to do with printk is that it can
break existing printk usages. As Petr said, people want printk to do two
things. 1 - print out data ASAP, 2 - not lock up the system. The two
are fighting each other. You care more about 2 where I (and others,
like Peter Zijlstra and Linus) care more about 1.

My solution can help with 2 without doing anything to hurt 1.

You are NACKing my solution because it doesn't solve this bug with net
console. I believe net console should be fixed. You believe that printk
should have a work around to not let net console type bugs occur. Which
to me is papering over the real bugs.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
