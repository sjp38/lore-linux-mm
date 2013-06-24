Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 81D196B0031
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 17:30:44 -0400 (EDT)
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock
 acquisition
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <51C8B0AA.4070204@hurleysoftware.com>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
	 <1371858700.22432.5.camel@schen9-DESK>
	 <51C558E2.1040108@hurleysoftware.com>
	 <1372017836.1797.14.camel@buesod1.americas.hpqcorp.net>
	 <1372093876.22432.34.camel@schen9-DESK>
	 <51C894C3.4040407@hurleysoftware.com>
	 <1372105065.22432.65.camel@schen9-DESK>
	 <51C8B0AA.4070204@hurleysoftware.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 Jun 2013 14:30:38 -0700
Message-ID: <1372109438.22432.75.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Mon, 2013-06-24 at 16:48 -0400, Peter Hurley wrote:

> 
> Also, I haven't given a lot of thought to if preemption must be disabled
> before calling rwsem_can_spin_on_owner(). If so, wouldn't you just drop
> rwsem_can_spin_on_owner() (because the conditions tested in the loop are
> equivalent)?
> 

Not totally equivalent.  If we drop the call to rwsem_can_spin_on_owner,
we will spin when readers are holding the lock (owner is null).  
Right now we only allow writers to spin when other writers are 
holding the lock by adding the rwsem_can_spin_on_owner check.  
Letting spinning on readers held lock is tricky as
we could have a reader that sleeps and if we don't detect the case.  We
could spin for too long.

Thanks.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
