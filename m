Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id C65BC6B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 00:34:10 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so3343337pbc.35
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 21:34:10 -0700 (PDT)
Received: by mail-bk0-f44.google.com with SMTP id mz10so1269871bkb.31
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 21:34:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130928021947.GF9093@linux.vnet.ibm.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	<1380147049.3467.67.camel@schen9-DESK>
	<20130927152953.GA4464@linux.vnet.ibm.com>
	<1380310733.3467.118.camel@schen9-DESK>
	<20130927203858.GB9093@linux.vnet.ibm.com>
	<1380322005.3467.186.camel@schen9-DESK>
	<20130927230137.GE9093@linux.vnet.ibm.com>
	<CAGQ1y=7YbB_BouYZVJwAZ9crkSMLVCxg8hoqcO_7sXHRrZ90_A@mail.gmail.com>
	<20130928021947.GF9093@linux.vnet.ibm.com>
Date: Fri, 27 Sep 2013 21:34:06 -0700
Message-ID: <CAGQ1y=5RnRsWdOe5CX6WYEJ2vUCFtHpj+PNC85NuEDH4bMdb0w@mail.gmail.com>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Jason Low <jason.low2@hp.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Jason Low <jason.low2@hp.com>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <Waiman.Long@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 7:19 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Sep 27, 2013 at 04:54:06PM -0700, Jason Low wrote:
>> On Fri, Sep 27, 2013 at 4:01 PM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > Yep.  The previous lock holder's smp_wmb() won't keep either the compiler
>> > or the CPU from reordering things for the new lock holder.  They could for
>> > example reorder the critical section to precede the node->locked check,
>> > which would be very bad.
>>
>> Paul, Tim, Longman,
>>
>> How would you like the proposed changes below?
>
> Could you point me at what this applies to?  I can find flaws looking
> at random pieces, given a little luck, but at some point I need to look
> at the whole thing.  ;-)

Sure. Here is a link to the patch we are trying to modify:
https://lkml.org/lkml/2013/9/25/532

Also, below is what the mcs_spin_lock() and mcs_spin_unlock()
functions would look like after applying the proposed changes.

static noinline
void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
{
        struct mcs_spin_node *prev;

        /* Init node */
        node->locked = 0;
        node->next   = NULL;

        prev = xchg(lock, node);
        if (likely(prev == NULL)) {
                /* Lock acquired. No need to set node->locked since it
won't be used */
                return;
        }
        ACCESS_ONCE(prev->next) = node;
        /* Wait until the lock holder passes the lock down */
        while (!ACCESS_ONCE(node->locked))
                arch_mutex_cpu_relax();
        smp_mb();
}

static void mcs_spin_unlock(struct mcs_spin_node **lock, struct
mcs_spin_node *node)
{
        struct mcs_spin_node *next = ACCESS_ONCE(node->next);

        if (likely(!next)) {
                /*
                 * Release the lock by setting it to NULL
                 */
                if (cmpxchg(lock, node, NULL) == node)
                        return;
                /* Wait until the next pointer is set */
                while (!(next = ACCESS_ONCE(node->next)))
                        arch_mutex_cpu_relax();
        }
        smp_wmb();
        ACCESS_ONCE(next->locked) = 1;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
