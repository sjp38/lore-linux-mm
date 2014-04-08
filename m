Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id D27DC6B0037
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:10:31 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so1110820iec.5
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:10:31 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ij6si3964643igb.29.2014.04.08.09.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 09:10:27 -0700 (PDT)
Date: Tue, 8 Apr 2014 18:10:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: sched: long running interrupts breaking spinlocks
Message-ID: <20140408161023.GP10526@twins.programming.kicks-ass.net>
References: <53441540.7070102@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53441540.7070102@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Apr 08, 2014 at 11:26:56AM -0400, Sasha Levin wrote:
> Hi all,
> 
> (all the below happened inside mm/ code, so while I don't suspect
> it's a mm/ issue you folks got cc'ed anyways!)
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following:
> 
> [ 4071.166362] BUG: spinlock lockup suspected on CPU#19, trinity-c19/17092

That's a heuristic in the spinlock code; triggering it with big machines
(19 cpus is far bigger than anything at the time that code was written)
and virt (yay for lock owner preemption; another thing we didn't have
back when) is trivial.

I'd not worry too much about this.

So DEBUG_SPINLOCKS turns spin_lock() into something like:

  for (i = 0; i < loops; i++)
  	if (spin_trylock())
		return;

  /* complain */

And you simply ran out of loops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
