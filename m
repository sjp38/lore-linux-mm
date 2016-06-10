Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53BDA6B0005
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 18:29:07 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w9so99214445oia.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 15:29:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p184si15106610pfb.252.2016.06.10.15.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 15:29:06 -0700 (PDT)
Date: Fri, 10 Jun 2016 15:29:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 02/12] kthread: Kthread worker API cleanup
Message-Id: <20160610152905.e99933d99108fa6d9f8d4dca@linux-foundation.org>
In-Reply-To: <20160609110710.510c7c67@gandalf.local.home>
References: <1465480326-31606-1-git-send-email-pmladek@suse.com>
	<1465480326-31606-3-git-send-email-pmladek@suse.com>
	<20160609110710.510c7c67@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 9 Jun 2016 11:07:10 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu,  9 Jun 2016 15:51:56 +0200
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > A good practice is to prefix the names of functions and macros
> > by the name of the subsystem.
> > 
> > The kthread worker API is a mix of classic kthreads and workqueues.
> > Each worker has a dedicated kthread. It runs a generic function
> > that process queued works. It is implemented as part of
> > the kthread subsystem.
> > 
> > This patch renames the existing kthread worker API to use
> > the corresponding name from the workqueues API prefixed by
> > kthread_/KTHREAD_:
> > 
> > DEFINE_KTHREAD_WORKER()		-> KTHREAD_DECLARE_WORKER()
> > DEFINE_KTHREAD_WORK()		-> KTHREAD_DECLARE_WORK()
> > DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> > DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> > __init_kthread_worker()		-> __kthread_init_worker()
> > init_kthread_worker()		-> kthread_init_worker()
> > init_kthread_work()		-> kthread_init_work()
> > insert_kthread_work()		-> kthread_insert_work()
> > queue_kthread_work()		-> kthread_queue_work()
> > flush_kthread_work()		-> kthread_flush_work()
> > flush_kthread_worker()		-> kthread_flush_worker()
> > 
> 
> I know that Andrew suggested this, but I didn't get a chance to respond
> to his email due to traveling.
> 
> Does this mean we are going to change all APIs like this? Because we
> pretty much use this type of naming everywhere. That is, we start with
> "DEFINE_*" and "DECLARE_*" commonly. As well as "init_*".
> 
> For example DEFINE_PER_CPU(), DEFINE_SPINLOCK(), DEFINE_LGLOCK(),
> DEFINE_MUTEX(), DEFINE_RES_MEME(), DEFINE_TIMER(), DEFINE_IDA(),
> DEFINE_NFS4_*(), and the list goes on. Just do a grep in
> include/linux/*.h for DEFINE_ and DECLARE_.

Yes, there's so much precedence that DEFINE_KTHREAD_WORKER() and
friends can/should be left as-is.

But I do think that init_kthread_worker() is a sore thumb and should
become kthread_worker_init() (not kthread_worker_init())

> Also, are you sure that we should change the DEFINE to a DECLARE,
> because DEFINE is used to create the object in question, DECLARE is for
> header files:

Yes2, these macros expand to definitions, not to declarations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
