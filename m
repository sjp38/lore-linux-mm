Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 90E9C6B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 03:38:12 -0400 (EDT)
Date: Tue, 25 Jun 2013 09:37:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock
 acquisition
Message-ID: <20130625073739.GX28407@twins.programming.kicks-ass.net>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
 <1371858700.22432.5.camel@schen9-DESK>
 <51C558E2.1040108@hurleysoftware.com>
 <1372017836.1797.14.camel@buesod1.americas.hpqcorp.net>
 <1372093876.22432.34.camel@schen9-DESK>
 <51C894C3.4040407@hurleysoftware.com>
 <1372105065.22432.65.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372105065.22432.65.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Mon, Jun 24, 2013 at 01:17:45PM -0700, Tim Chen wrote:
> On second thought, I agree with you.  I should change this to
> something like
> 
> 	int retval = true;
> 	task_struct *sem_owner;
> 
> 	/* Spin only if active writer running */
> 	if (!sem->owner)
> 		return false;
> 
> 	rcu_read_lock();
> 	sem_owner = sem->owner;

That should be: sem_owner = ACCESS_ONCE(sem->owner); to make sure the
compiler doesn't try and be clever and rereads.

> 	if (sem_owner)
> 		retval = sem_owner->on_cpu;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
