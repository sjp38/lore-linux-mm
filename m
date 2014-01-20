Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C0C3C6B0036
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:11:29 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so5098791pad.0
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:11:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pi8si2395701pac.1.2014.01.20.11.11.27
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 11:11:28 -0800 (PST)
Subject: Re: [PATCH v7 2/6] MCS Lock: optimizations and extra comments
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140120135803.GF31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
	 <1389917300.3138.12.camel@schen9-DESK>
	 <20140120135803.GF31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 11:11:25 -0800
Message-ID: <1390245085.3138.24.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, 2014-01-20 at 14:58 +0100, Peter Zijlstra wrote:
> On Thu, Jan 16, 2014 at 04:08:20PM -0800, Tim Chen wrote:
> > Remove unnecessary operation and make the cmpxchg(lock, node, NULL) == node
> > check in mcs_spin_unlock() likely() as it is likely that a race did not occur
> > most of the time.
> 
> It might be good to describe why the node->locked=1 is thought
> unnecessary. I concur it is, but upon reading this changelog I was left
> wondering and had to go read the code and run through the logic to
> convince myself.
> 
> Having done so, I'm now wondering if we think so for the same reason --
> although I'm fairly sure we are.
> 
> The argument goes like: everybody only looks at his own ->locked value,
> therefore the only one possibly interested in node->locked is the lock
> owner. However the lock owner doesn't care what's in it, it simply
> assumes its 1 but really doesn't care one way or another.

Yes, it is done for the same reason you mentioned.  I'll update
the comments better to reflect this.

> 
> That said, a possible DEBUG mode might want to actually set it, validate
> that all other linked nodes are 0 and upon unlock verify the same before
> flipping next->locked to 1.

I'll leave a comment to indicate this. If we need a DEBUG mode later,
we can come back to add this easily.

Thanks.

Tim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
