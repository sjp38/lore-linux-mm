Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B76D96B0260
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:03:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l5so216512506ioa.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:03:41 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0100.hostedemail.com. [216.40.44.100])
        by mx.google.com with ESMTPS id z201si13915236itb.5.2016.06.13.09.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 09:03:40 -0700 (PDT)
Date: Mon, 13 Jun 2016 12:03:33 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v8 02/12] kthread: Kthread worker API cleanup
Message-ID: <20160613120333.47141cd9@gandalf.local.home>
In-Reply-To: <20160613151353.GA2725@pathway.suse.cz>
References: <1465480326-31606-1-git-send-email-pmladek@suse.com>
	<1465480326-31606-3-git-send-email-pmladek@suse.com>
	<20160609110710.510c7c67@gandalf.local.home>
	<20160610152905.e99933d99108fa6d9f8d4dca@linux-foundation.org>
	<20160613151353.GA2725@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 13 Jun 2016 17:13:53 +0200
Petr Mladek <pmladek@suse.com> wrote:

> OK, all wants to keep DEFINE stuff as is:
> 
>   DEFINE_KTHREAD_WORKER()		stay
>   DEFINE_KTHREAD_WORK()			stay
>   DEFINE_KTHREAD_WORKER_ONSTACK()	stay
>   DEFINE_KTHREAD_WORKER_ONSTACK()	stay
> 
> 
> Nobody was against renaming the non-init functions:
> 
>   insert_kthread_work()		-> kthread_insert_work()
>   queue_kthread_work()		-> kthread_queue_work()
>   flush_kthread_work()		-> kthread_flush_work()
>   flush_kthread_worker()	-> kthread_flush_worker()

Yep.

> 
> 
> 
> Now, the question seem to be the init() functions.
> Andrew would prefer:
> 
>   __init_kthread_worker()	-> __kthread_worker_init()
>   init_kthread_worker()		-> kthread_worker_init()
>   init_kthread_work()		-> kthread_work_init()
> 
> AFAIK, Steven would prefer to keep it
> 
>   __init_kthread_worker()	stay as is
>   init_kthread_worker()		stay as is
>   init_kthread_work()		stay as is
> 
> I would personally prefer the way from this patch:
> 
>   __init_kthread_worker()	-> __kthread_init_worker()
>   init_kthread_worker()		-> kthread_init_worker()
>   init_kthread_work()		-> kthread_init_work()
> 
> 
> I have several reasons:
> 
> 1. The init functions will be used close to the other functions in
>    the code. It will be easier if all functions use the same
>    naming scheme. Here are some snippets:
> 
> 	kthread_init_work(&w_data->balancing_work, clamp_balancing_func);
> 	kthread_init_delayed_work(&w_data->idle_injection_work,
> 				  clamp_idle_injection_func);
> 	kthread_queue_work(w_data->worker, &w_data->balancing_work);
> 
>    or
> 
> 	kthread_init_delayed_work(&kmemleak_scan_work, kmemleak_scan_func);
> 	kmemleak_scan_worker = kthread_create_worker(0, "kmemleak");
> 
> 
> 2. We are going to add kthread_destroy_worker() which would need
>    to be another exception. Also this function will be used together
>    with the others, for example:
> 
> 	kthread_cancel_delayed_work_sync(&rb_producer_hammer_work);
> 	kthread_destroy_worker(rb_producer_worker);
> 
>    Also here the same naming scheme will help.
> 
> 
> 3. It is closer to the workqueues API, so it reduces confusion.

Using workqueues as an example of "reduces confusion" is not the most
convincing argument ;-)

> 
> 4. Note that there are already several precedents, for example:
> 
> 	amd_iommu_init_device()
> 	free_area_init_node()
> 	jump_label_init_type()
> 	regmap_init_mmio_clk()
> 
> 
> Andrew, Steven, are you really so strongly against my version
> of the init functions, please?
> 
> 

I don't really have that strong opinion on the "init" part. I was much
more concerned about the DEFINE/DECLARE macros.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
