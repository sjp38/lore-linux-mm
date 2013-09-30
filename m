Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 09C696B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 12:37:10 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so5871960pde.38
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:37:10 -0700 (PDT)
Message-ID: <5249A8A4.9060400@hp.com>
Date: Mon, 30 Sep 2013 12:36:52 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>  <1380147049.3467.67.camel@schen9-DESK>  <20130927152953.GA4464@linux.vnet.ibm.com>  <1380310733.3467.118.camel@schen9-DESK>  <20130927203858.GB9093@linux.vnet.ibm.com>  <1380322005.3467.186.camel@schen9-DESK>  <20130927230137.GE9093@linux.vnet.ibm.com>  <CAGQ1y=7YbB_BouYZVJwAZ9crkSMLVCxg8hoqcO_7sXHRrZ90_A@mail.gmail.com>  <20130928021947.GF9093@linux.vnet.ibm.com>  <CAGQ1y=5RnRsWdOe5CX6WYEJ2vUCFtHpj+PNC85NuEDH4bMdb0w@mail.gmail.com>  <52499E13.8050109@hp.com> <1380557440.14213.6.camel@j-VirtualBox>
In-Reply-To: <1380557440.14213.6.camel@j-VirtualBox>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 09/30/2013 12:10 PM, Jason Low wrote:
> On Mon, 2013-09-30 at 11:51 -0400, Waiman Long wrote:
>> On 09/28/2013 12:34 AM, Jason Low wrote:
>>>> Also, below is what the mcs_spin_lock() and mcs_spin_unlock()
>>>> functions would look like after applying the proposed changes.
>>>>
>>>> static noinline
>>>> void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
>>>> {
>>>>           struct mcs_spin_node *prev;
>>>>
>>>>           /* Init node */
>>>>           node->locked = 0;
>>>>           node->next   = NULL;
>>>>
>>>>           prev = xchg(lock, node);
>>>>           if (likely(prev == NULL)) {
>>>>                   /* Lock acquired. No need to set node->locked since it
>>>> won't be used */
>>>>                   return;
>>>>           }
>>>>           ACCESS_ONCE(prev->next) = node;
>>>>           /* Wait until the lock holder passes the lock down */
>>>>           while (!ACCESS_ONCE(node->locked))
>>>>                   arch_mutex_cpu_relax();
>>>>           smp_mb();
>> I wonder if a memory barrier is really needed here.
> If the compiler can reorder the while (!ACCESS_ONCE(node->locked)) check
> so that the check occurs after an instruction in the critical section,
> then the barrier may be necessary.
>

In that case, just a barrier() call should be enough.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
