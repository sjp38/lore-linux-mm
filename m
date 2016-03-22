Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8356B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:02:04 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id 4so198555668pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 16:02:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yk10si13485755pac.24.2016.03.22.16.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 16:02:03 -0700 (PDT)
Date: Tue, 22 Mar 2016 16:02:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-Id: <20160322160202.9647702367dabf86b003b168@linux-foundation.org>
In-Reply-To: <20160322122345.GN6344@twins.programming.kicks-ass.net>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
	<1458644426-22973-2-git-send-email-mhocko@kernel.org>
	<20160322122345.GN6344@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue, 22 Mar 2016 13:23:45 +0100 Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Mar 22, 2016 at 12:00:18PM +0100, Michal Hocko wrote:
> 
> >  extern signed long schedule_timeout_interruptible(signed long timeout);
> >  extern signed long schedule_timeout_killable(signed long timeout);
> >  extern signed long schedule_timeout_uninterruptible(signed long timeout);
> > +extern signed long schedule_timeout_idle(signed long timeout);
> 
> > +/*
> > + * Like schedule_timeout_uninterruptible(), except this task will not contribute
> > + * to load average.
> > + */
> > +signed long __sched schedule_timeout_idle(signed long timeout)
> > +{
> > +	__set_current_state(TASK_IDLE);
> > +	return schedule_timeout(timeout);
> > +}
> > +EXPORT_SYMBOL(schedule_timeout_idle);
> 
> Yes we have 3 such other wrappers, but I've gotta ask: why? They seem
> pretty pointless.

I like the wrappers.  At least, more than having to read the open-coded
version.  The latter is just more stuff to interpret and to check
whereas I can look at "schedule_timeout_idle" and think "yup, I know
what that does".

But whatever.  I'll probably be sending this series up for 4.6 and we can
worry about the schedule_timeout_foo() stuff later.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
