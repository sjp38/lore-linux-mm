Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3366B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:16:21 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3063638pdj.15
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 13:16:20 -0700 (PDT)
Received: by mail-bk0-f50.google.com with SMTP id mz11so1190088bkb.9
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 13:16:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380310733.3467.118.camel@schen9-DESK>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	<1380147049.3467.67.camel@schen9-DESK>
	<20130927152953.GA4464@linux.vnet.ibm.com>
	<1380310733.3467.118.camel@schen9-DESK>
Date: Fri, 27 Sep 2013 13:16:16 -0700
Message-ID: <CAGQ1y=7bvd00iU_0byqmVAe5NoEJ=SwkVbdbcj8+O6=Bh27jzQ@mail.gmail.com>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Jason Low <jason.low2@hp.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Waiman Long <Waiman.Long@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 12:38 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:

> BTW, is the above memory barrier necessary?  It seems like the xchg
> instruction already provided a memory barrier.
>
> Now if we made the changes that Jason suggested:
>
>
>         /* Init node */
> -       node->locked = 0;
>         node->next   = NULL;
>
>         prev = xchg(lock, node);
>         if (likely(prev == NULL)) {
>                 /* Lock acquired */
> -               node->locked = 1;
>                 return;
>         }
> +       node->locked = 0;
>         ACCESS_ONCE(prev->next) = node;
>         smp_wmb();
>
> We are probably still okay as other cpus do not read the value of
> node->locked, which is a local variable.

Similarly, I was wondering if we should also move smp_wmb() so that it
is before the ACCESS_ONCE(prev->next) = node and after the
node->locked = 0. Would we want to guarantee that the node->locked
gets set before it is added to the linked list where a previous thread
calling mcs_spin_unlock() would potentially modify node->locked?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
