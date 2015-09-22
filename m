Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id A9C256B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:27:05 -0400 (EDT)
Received: by ykdz138 with SMTP id z138so18290669ykd.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:27:05 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id v139si1813694ywa.47.2015.09.22.11.27.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:27:04 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so18322247ykd.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:27:04 -0700 (PDT)
Date: Tue, 22 Sep 2015 14:26:59 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 03/18] kthread: Add drain_kthread_worker()
Message-ID: <20150922182659.GB17659@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-4-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-4-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2015 at 03:03:44PM +0200, Petr Mladek wrote:
> flush_kthread_worker() returns when the currently queued works are proceed.
								     ^
								   processed?

> But some other works might have been queued in the meantime.
...
> +/**
> + * drain_kthread_worker - drain a kthread worker
> + * @worker: worker to be drained
> + *
> + * Wait until there is none work queued for the given kthread worker.
                          ^
                          no

> + * Only currently running work on @worker can queue further work items
                                             ^^^^^^^^^
				 should be queueing is prolly more accurate

> + * on it.  @worker is flushed repeatedly until it becomes empty.
> + * The number of flushing is determined by the depth of chaining
> + * and should be relatively short.  Whine if it takes too long.
> + *
> + * The caller is responsible for blocking all existing works
> + * from an infinite re-queuing!
           
The caller is responsible for preventing the existing work items from
requeueing themselves indefinitely.

> + *
> + * Also the caller is responsible for blocking all the kthread
> + * worker users from queuing any new work. It is especially
> + * important if the queue has to stay empty once this function
> + * finishes.

The last sentence reads a bit weird to me.  New work items just aren't
allowed while draining.  It isn't "especially important" for certain
cases.  It's just buggy otherwise.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
