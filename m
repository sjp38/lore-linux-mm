Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 000C16B2EB4
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 21:40:53 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d3so3440619pgv.23
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:40:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w185sor60646110pgd.7.2018.11.22.18.40.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 18:40:52 -0800 (PST)
Date: Fri, 23 Nov 2018 11:40:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181123024048.GD1582@jagdpanzerIV>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
 <20181122101606.GP2131@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122101606.GP2131@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On (11/22/18 11:16), Peter Zijlstra wrote:
> > So maybe we need to switch debug objects print-outs to _always_
> > printk_deferred(). Debug objects can be used in code which cannot
> > do direct printk() - timekeeping is just one example.
> 
> No, printk_deferred() is a disease, it needs to be eradicated, not
> spread around.

deadlock-free printk() is deferred, but OK.


Another idea then:

---

diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index 70935ed91125..3928c2b2f77c 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -323,10 +323,13 @@ static void debug_print_object(struct debug_obj *obj, char *msg)
 		void *hint = descr->debug_hint ?
 			descr->debug_hint(obj->object) : NULL;
 		limit++;
+
+		bust_spinlocks(1);
 		WARN(1, KERN_ERR "ODEBUG: %s %s (active state %u) "
 				 "object type: %s hint: %pS\n",
 			msg, obj_states[obj->state], obj->astate,
 			descr->name, hint);
+		bust_spinlocks(0);
 	}
 	debug_objects_warnings++;
 }

---

This should make serial consoles re-entrant.
So printk->console_driver_write() hopefully will not deadlock.

IOW, this turns serial consoles into early_consoles, for a while ;)

	-ss
