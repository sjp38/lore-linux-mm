Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 317636B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 15:36:22 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so18799387pav.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 12:36:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y189si52811735pfb.83.2016.06.01.12.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 12:36:21 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:36:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 03/10] kthread: Add create_kthread_worker*()
Message-Id: <20160601123619.6cadd1d09287c71b0639e226@linux-foundation.org>
In-Reply-To: <1464620371-31346-4-git-send-email-pmladek@suse.com>
References: <1464620371-31346-1-git-send-email-pmladek@suse.com>
	<1464620371-31346-4-git-send-email-pmladek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 30 May 2016 16:59:24 +0200 Petr Mladek <pmladek@suse.com> wrote:

> Kthread workers are currently created using the classic kthread API,
> namely kthread_run(). kthread_worker_fn() is passed as the @threadfn
> parameter.
> 
> This patch defines create_kthread_worker() and
> create_kthread_worker_on_cpu() functions that hide implementation details.

I hate to nick pits, but the naming isn't good.

A good, disciplined and pretty common naming scheme is to lead the
overall identifier with the name of the relevant subsystem.  kthread
has done that *fairly* well:


Things we got right:

kthread_create_on_node
kthread_create
kthread_create_on_cpu
kthread_run
kthread_bind
kthread_bind_mask
kthread_stop
kthread_should_stop
kthread_should_park
kthread_freezable_should_stop
kthread_data
kthread_park
kthread_unpark
kthread_parkme
kthreadd
kthread_work_func_t
KTHREAD_WORKER_INIT
KTHREAD_WORK_INIT
KTHREAD_WORKER_INIT_ONSTACK
kthread_worker_fn

Things we didn't:

probe_kthread_data
DEFINE_KTHREAD_WORKER
DEFINE_KTHREAD_WORK
DEFINE_KTHREAD_WORKER_ONSTACK
DEFINE_KTHREAD_WORKER_ONSTACK
__init_kthread_worker
init_kthread_worker
init_kthread_work
queue_kthread_work
flush_kthread_work
flush_kthread_worker


So I suggest kthread_create_worker() and
kthread_create_worker_on_cpu(), please.

And this might be a suitable time to regularize some of the "things we
didn't" identifiers, if you're feeling keen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
