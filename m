Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A6CDB6B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 13:18:36 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so24617080wic.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:18:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bq3si20943007wjc.50.2015.06.19.10.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 10:18:35 -0700 (PDT)
Message-ID: <55844EE7.7070508@linutronix.de>
Date: Fri, 19 Jun 2015 19:18:31 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memcontrol: correct the comment in mem_cgroup_swapout()
References: <20150619163418.GA21040@linutronix.de> <20150619171118.GA11423@cmpxchg.org>
In-Reply-To: <20150619171118.GA11423@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, rostedt@goodmis.org, williams@redhat.com

On 06/19/2015 07:11 PM, Johannes Weiner wrote:
> On Fri, Jun 19, 2015 at 06:34:18PM +0200, Sebastian Andrzej Siewior wrote:
>> Clark stumbled over a VM_BUG_ON() in -RT which was then was removed by
>> Johannes in commit f371763a79d ("mm: memcontrol: fix false-positive
>> VM_BUG_ON() on -rt"). The comment before that patch was a tiny bit
>> better than it is now. While the patch claimed to fix a false-postive on
>> -RT this was not the case. None of the -RT folks ACKed it and it was not a
>> false positive report. That was a *real* problem.
> 
> The real problem is that irqs_disabled() on -rt is returning false
> negatives.  Having it return false within a spin_lock_irq() section is
> broken.

As I explained it in
	http://www.spinics.net/lists/linux-rt-users/msg13499.html
it is not.

>> This patch updates the comment that is improper because it refers to
>> "disabled preemption" as a consequence of that lock being taken. A
>> spin_lock() disables preemption, true, but in this case the code relies on
>> the fact that the lock _also_ disables interrupts once it is acquired. And
>> this is the important detail (which was checked the VM_BUG_ON()) which needs
>> to be pointed out. This is the hint one needs while looking at the code. It
>> was explained by Johannes on the list that the per-CPU variables are protected
>> by local_irq_save(). The BUG_ON() was helpful. This code has been workarounded
>> in -RT in the meantime. I wouldn't mind running into more of those if the code
>> in question uses *special* kind of locking since now there is no no
>> verification (in terms of lockdep or BUG_ON()).
> 
> I'd be happy to re-instate the VM_BUG_ON that checks for disabled
> interrupts as before, that was the most obvious documentation.

sure thing, patch follows in a jiffy or two.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
