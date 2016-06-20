Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF5CC6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:55:48 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id i1so307887918vkg.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:55:48 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id y62si19847713ywe.89.2016.06.20.12.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 12:55:46 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id i12so2797329ywa.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:55:46 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:55:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 05/12] kthread: Add kthread_create_worker*()
Message-ID: <20160620195544.GW3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-6-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-6-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:24PM +0200, Petr Mladek wrote:
> Kthread workers are currently created using the classic kthread API,
> namely kthread_run(). kthread_worker_fn() is passed as the @threadfn
> parameter.
> 
> This patch defines kthread_create_worker() and
> kthread_create_worker_on_cpu() functions that hide implementation details.
> 
> They enforce using kthread_worker_fn() for the main thread. But I doubt
> that there are any plans to create any alternative. In fact, I think
> that we do not want any alternative main thread because it would be
> hard to support consistency with the rest of the kthread worker API.
> 
> The naming and function of kthread_create_worker() is inspired by
> the workqueues API like the rest of the kthread worker API.
> 
> The kthread_create_worker_on_cpu() variant is motivated by the original
> kthread_create_on_cpu(). Note that we need to bind per-CPU kthread
> workers already when they are created. It makes the life easier.
> kthread_bind() could not be used later for an already running worker.
> 
> This patch does _not_ convert existing kthread workers. The kthread worker
> API need more improvements first, e.g. a function to destroy the worker.
> 
> IMPORTANT:
> 
> kthread_create_worker_on_cpu() allows to use any format of the
> worker name, in compare with kthread_create_on_cpu(). The good thing
> is that it is more generic. The bad thing is that most users will
> need to pass the cpu number in two parameters, e.g.
> kthread_create_worker_on_cpu(cpu, "helper/%d", cpu).
> 
> To be honest, the main motivation was to avoid the need for an
> empty va_list. The only legal way was to create a helper function that
> would be called with an empty list. Other attempts caused compilation
> warnings or even errors on different architectures.
> 
> There were also other alternatives, for example, using #define or
> splitting __kthread_create_worker(). The used solution looked
> like the least ugly.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
