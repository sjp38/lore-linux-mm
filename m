Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8E96B0277
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:25:36 -0500 (EST)
Received: by qkao63 with SMTP id o63so14257833qka.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:25:35 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id j20si2453296qhc.31.2015.11.18.06.25.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 06:25:35 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 18 Nov 2015 07:25:34 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id F11583E40055
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:25:30 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAIEPU7U45285488
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:25:30 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAIEPQYe015139
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:25:30 -0700
Date: Wed, 18 Nov 2015 06:25:45 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 00/22] kthread: Use kthread worker API more widely
Message-ID: <20151118142545.GD5184@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, linux-watchdog@vger.kernel.org, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Maxim Levitsky <maximlevitsky@gmail.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

On Wed, Nov 18, 2015 at 02:25:05PM +0100, Petr Mladek wrote:
> My intention is to make it easier to manipulate and maintain kthreads.
> Especially, I want to replace all the custom main cycles with a
> generic one. Also I want to make the kthreads sleep in a consistent
> state in a common place when there is no work.
> 
> My first attempt was with a brand new API (iterant kthread), see
> http://thread.gmane.org/gmane.linux.kernel.api/11892 . But I was
> directed to improve the existing kthread worker API. This is
> the 3rd iteration of the new direction.
> 
> 
> 1st patch: add support to check if a timer callback is being called
> 
> 2nd..12th patches: improve the existing kthread worker API
> 
> 13th..18th, 20th, 22nd patches: convert several kthreads into
>       the kthread worker API, namely: khugepaged, ring buffer
>       benchmark, hung_task, kmemleak, ipmi, IB/fmr_pool,
>       memstick/r592, intel_powerclamp
>       
> 21st, 23rd patches: do some preparation steps; they usually do
>       some clean up that makes sense even without the conversion.
> 
>   
> Changes against v2:
> 
>   + used worker->lock to synchronize the operations with the work
>     instead of the PENDING bit as suggested by Tejun Heo; it simplified
>     the implementation in several ways
> 
>   + added timer_active(); used it together with del_timer_sync()
>     to cancel the work a less tricky way
> 
>   + removed the controversial conversion of the RCU kthreads

Thank you!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
