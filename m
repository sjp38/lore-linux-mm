Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C11E6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:13:57 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id jf8so51402603lbc.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:13:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si30133410wjx.37.2016.06.13.08.13.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Jun 2016 08:13:55 -0700 (PDT)
Date: Mon, 13 Jun 2016 17:13:53 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v8 02/12] kthread: Kthread worker API cleanup
Message-ID: <20160613151353.GA2725@pathway.suse.cz>
References: <1465480326-31606-1-git-send-email-pmladek@suse.com>
 <1465480326-31606-3-git-send-email-pmladek@suse.com>
 <20160609110710.510c7c67@gandalf.local.home>
 <20160610152905.e99933d99108fa6d9f8d4dca@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610152905.e99933d99108fa6d9f8d4dca@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 2016-06-10 15:29:05, Andrew Morton wrote:
> On Thu, 9 Jun 2016 11:07:10 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > On Thu,  9 Jun 2016 15:51:56 +0200
> > Petr Mladek <pmladek@suse.com> wrote:
> > 
> > > A good practice is to prefix the names of functions and macros
> > > by the name of the subsystem.
> > > 
> > > The kthread worker API is a mix of classic kthreads and workqueues.
> > > Each worker has a dedicated kthread. It runs a generic function
> > > that process queued works. It is implemented as part of
> > > the kthread subsystem.
> > > 
> > > This patch renames the existing kthread worker API to use
> > > the corresponding name from the workqueues API prefixed by
> > > kthread_/KTHREAD_:
> > > 
> > > DEFINE_KTHREAD_WORKER()		-> KTHREAD_DECLARE_WORKER()
> > > DEFINE_KTHREAD_WORK()		-> KTHREAD_DECLARE_WORK()
> > > DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> > > DEFINE_KTHREAD_WORKER_ONSTACK()	-> KTHREAD_DECLARE_WORKER_ONSTACK()
> > > __init_kthread_worker()		-> __kthread_init_worker()
> > > init_kthread_worker()		-> kthread_init_worker()
> > > init_kthread_work()		-> kthread_init_work()
> > > insert_kthread_work()		-> kthread_insert_work()
> > > queue_kthread_work()		-> kthread_queue_work()
> > > flush_kthread_work()		-> kthread_flush_work()
> > > flush_kthread_worker()		-> kthread_flush_worker()
> > > 
> > 
> > I know that Andrew suggested this, but I didn't get a chance to respond
> > to his email due to traveling.
> > 
> > Does this mean we are going to change all APIs like this? Because we
> > pretty much use this type of naming everywhere. That is, we start with
> > "DEFINE_*" and "DECLARE_*" commonly. As well as "init_*".
> > 
> > For example DEFINE_PER_CPU(), DEFINE_SPINLOCK(), DEFINE_LGLOCK(),
> > DEFINE_MUTEX(), DEFINE_RES_MEME(), DEFINE_TIMER(), DEFINE_IDA(),
> > DEFINE_NFS4_*(), and the list goes on. Just do a grep in
> > include/linux/*.h for DEFINE_ and DECLARE_.
> 
> Yes, there's so much precedence that DEFINE_KTHREAD_WORKER() and
> friends can/should be left as-is.
> 
> But I do think that init_kthread_worker() is a sore thumb and should
> become kthread_worker_init() (not kthread_worker_init())

OK, all wants to keep DEFINE stuff as is:

  DEFINE_KTHREAD_WORKER()		stay
  DEFINE_KTHREAD_WORK()			stay
  DEFINE_KTHREAD_WORKER_ONSTACK()	stay
  DEFINE_KTHREAD_WORKER_ONSTACK()	stay


Nobody was against renaming the non-init functions:

  insert_kthread_work()		-> kthread_insert_work()
  queue_kthread_work()		-> kthread_queue_work()
  flush_kthread_work()		-> kthread_flush_work()
  flush_kthread_worker()	-> kthread_flush_worker()



Now, the question seem to be the init() functions.
Andrew would prefer:

  __init_kthread_worker()	-> __kthread_worker_init()
  init_kthread_worker()		-> kthread_worker_init()
  init_kthread_work()		-> kthread_work_init()

AFAIK, Steven would prefer to keep it

  __init_kthread_worker()	stay as is
  init_kthread_worker()		stay as is
  init_kthread_work()		stay as is

I would personally prefer the way from this patch:

  __init_kthread_worker()	-> __kthread_init_worker()
  init_kthread_worker()		-> kthread_init_worker()
  init_kthread_work()		-> kthread_init_work()


I have several reasons:

1. The init functions will be used close to the other functions in
   the code. It will be easier if all functions use the same
   naming scheme. Here are some snippets:

	kthread_init_work(&w_data->balancing_work, clamp_balancing_func);
	kthread_init_delayed_work(&w_data->idle_injection_work,
				  clamp_idle_injection_func);
	kthread_queue_work(w_data->worker, &w_data->balancing_work);

   or

	kthread_init_delayed_work(&kmemleak_scan_work, kmemleak_scan_func);
	kmemleak_scan_worker = kthread_create_worker(0, "kmemleak");


2. We are going to add kthread_destroy_worker() which would need
   to be another exception. Also this function will be used together
   with the others, for example:

	kthread_cancel_delayed_work_sync(&rb_producer_hammer_work);
	kthread_destroy_worker(rb_producer_worker);

   Also here the same naming scheme will help.


3. It is closer to the workqueues API, so it reduces confusion.

4. Note that there are already several precedents, for example:

	amd_iommu_init_device()
	free_area_init_node()
	jump_label_init_type()
	regmap_init_mmio_clk()


Andrew, Steven, are you really so strongly against my version
of the init functions, please?


> > Also, are you sure that we should change the DEFINE to a DECLARE,
> > because DEFINE is used to create the object in question, DECLARE is for
> > header files:
> 
> Yes2, these macros expand to definitions, not to declarations.

Shame on me. I played with many variants, looked for the most
consistent solution, and got lost in all the constrains.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
