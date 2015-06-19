Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 495C26B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:03:14 -0400 (EDT)
Received: by wgez8 with SMTP id z8so95726528wge.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:03:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fu6si5358844wic.110.2015.06.19.11.03.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 11:03:12 -0700 (PDT)
Date: Fri, 19 Jun 2015 14:02:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: memcontrol: bring back the VM_BUG_ON() in
 mem_cgroup_swapout()
Message-ID: <20150619180256.GA11851@cmpxchg.org>
References: <20150619163418.GA21040@linutronix.de>
 <20150619171118.GA11423@cmpxchg.org>
 <55844EE7.7070508@linutronix.de>
 <20150619172802.GA11492@cmpxchg.org>
 <20150619173612.GA7143@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150619173612.GA7143@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, rostedt@goodmis.org, williams@redhat.com

On Fri, Jun 19, 2015 at 07:36:12PM +0200, Sebastian Andrzej Siewior wrote:
> Clark stumbled over a VM_BUG_ON() in -RT which was then was removed by
> Johannes in commit f371763a79d ("mm: memcontrol: fix false-positive
> VM_BUG_ON() on -rt"). The comment before that patch was a tiny bit
> better than it is now. While the patch claimed to fix a false-postive on
> -RT this was not the case. None of the -RT folks ACKed it and it was not a
> false positive report. That was a *real* problem.
> 
> This patch updates the comment that is improper because it refers to
> "disabled preemption" as a consequence of that lock being taken. A
> spin_lock() disables preemption, true, but in this case the code relies on
> the fact that the lock _also_ disables interrupts once it is acquired. And
> this is the important detail (which was checked the VM_BUG_ON()) which needs
> to be pointed out. This is the hint one needs while looking at the code. It
> was explained by Johannes on the list that the per-CPU variables are protected
> by local_irq_save(). The BUG_ON() was helpful. This code has been workarounded
> in -RT in the meantime. I wouldn't mind running into more of those if the code
> in question uses *special* kind of locking since now there is no
> verification (in terms of lockdep or BUG_ON()) and therefore I bring the
> VM_BUG_ON() check back in.
> 
> The two functions after the comment could also have a "local_irq_save()"
> dance around them in order to serialize access to the per-CPU variables.
> This has been avoided because the interrupts should be off.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Much better, thanks.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
