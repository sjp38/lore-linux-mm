Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 850666B025E
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 11:54:49 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v77so256128389ywg.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:54:49 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id q188si1884673ybq.257.2016.06.24.08.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 08:54:48 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id l125so15285523ywb.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:54:48 -0700 (PDT)
Date: Fri, 24 Jun 2016 11:54:47 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160624155447.GY3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
 <20160622205445.GV30909@twins.programming.kicks-ass.net>
 <20160623213258.GO3262@mtj.duckdns.org>
 <20160624070515.GU30154@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624070515.GU30154@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Jun 24, 2016 at 09:05:15AM +0200, Peter Zijlstra wrote:
> > Given how rare that is 
> 
> Could you then not remove/rework these few cases for workqueue as well
> and make that 'better' too?

Usage of draining is rare for workqueue but that still means several
legitimate users.  With draining there, it's logical to use it during
shutdown.  I don't think it makes sense to change it on workqueue
side.

> > and the extra
> > complexity of identifying self-requeueing cases, let's forget about
> > draining and on destruction clear the worker pointer to block further
> > queueing and then flush whatever is in flight.
> 
> You're talking about regular workqueues here?

No, kthread worker.  It's unlikely that kthread worker is gonna need
chained draining especially given that most of its usages are gonna be
conversions from raw kthread usages.  We won't lose much if anything
by just ignoring draining and making the code simpler.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
