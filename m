Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7FAA6B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 11:07:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 5so60081647ioy.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:07:15 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTPS id e67si7885242ioa.63.2016.06.09.08.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 08:07:14 -0700 (PDT)
Date: Thu, 9 Jun 2016 11:07:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v8 02/12] kthread: Kthread worker API cleanup
Message-ID: <20160609110710.510c7c67@gandalf.local.home>
In-Reply-To: <1465480326-31606-3-git-send-email-pmladek@suse.com>
References: <1465480326-31606-1-git-send-email-pmladek@suse.com>
	<1465480326-31606-3-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu,  9 Jun 2016 15:51:56 +0200
Petr Mladek <pmladek@suse.com> wrote:

> A good practice is to prefix the names of functions and macros
> by the name of the subsystem.
> 
> The kthread worker API is a mix of classic kthreads and workqueues.
> Each worker has a dedicated kthread. It runs a generic function
> that process queued works. It is implemented as part of
> the kthread subsystem.
> 
> This patch renames the existing kthread worker API to use
> the corresponding name from the workqueues API prefixed by
> kthread_/KTHREAD_:
> 
> DEFINE_KTHREAD_WORKER()		-> KTHREAD_DECLARE_WORKER()
> DEFINE_KTHREAD_WORK()		-> KTHREAD_DECLARE_WORK()
> DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> __init_kthread_worker()		-> __kthread_init_worker()
> init_kthread_worker()		-> kthread_init_worker()
> init_kthread_work()		-> kthread_init_work()
> insert_kthread_work()		-> kthread_insert_work()
> queue_kthread_work()		-> kthread_queue_work()
> flush_kthread_work()		-> kthread_flush_work()
> flush_kthread_worker()		-> kthread_flush_worker()
> 

I know that Andrew suggested this, but I didn't get a chance to respond
to his email due to traveling.

Does this mean we are going to change all APIs like this? Because we
pretty much use this type of naming everywhere. That is, we start with
"DEFINE_*" and "DECLARE_*" commonly. As well as "init_*".

For example DEFINE_PER_CPU(), DEFINE_SPINLOCK(), DEFINE_LGLOCK(),
DEFINE_MUTEX(), DEFINE_RES_MEME(), DEFINE_TIMER(), DEFINE_IDA(),
DEFINE_NFS4_*(), and the list goes on. Just do a grep in
include/linux/*.h for DEFINE_ and DECLARE_.

Also, are you sure that we should change the DEFINE to a DECLARE,
because DEFINE is used to create the object in question, DECLARE is for
header files:

X.h:

DECLARE_PER_CPU(int, x);


X.c


DEFINE_PER_CPU(int, x);


-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
