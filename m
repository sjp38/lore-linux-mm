Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B5A316B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 15:12:58 -0400 (EDT)
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock
 acquisition
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <51C894C3.4040407@hurleysoftware.com>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
	 <1371858700.22432.5.camel@schen9-DESK>
	 <51C558E2.1040108@hurleysoftware.com>
	 <1372017836.1797.14.camel@buesod1.americas.hpqcorp.net>
	 <1372093876.22432.34.camel@schen9-DESK>
	 <51C894C3.4040407@hurleysoftware.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 Jun 2013 12:13:00 -0700
Message-ID: <1372101180.22432.58.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Mon, 2013-06-24 at 14:49 -0400, Peter Hurley wrote:
> On 06/24/2013 01:11 PM, Tim Chen wrote:
> > On Sun, 2013-06-23 at 13:03 -0700, Davidlohr Bueso wrote:
> >> On Sat, 2013-06-22 at 03:57 -0400, Peter Hurley wrote:
> >>> On 06/21/2013 07:51 PM, Tim Chen wrote:
> >>>>
> >>>> +static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
> >>>> +{
> >>>> +	int retval = true;
> >>>> +
> >>>> +	/* Spin only if active writer running */
> >>>> +	if (!sem->owner)
> >>>> +		return false;
> >>>> +
> >>>> +	rcu_read_lock();
> >>>> +	if (sem->owner)
> >>>> +		retval = sem->owner->on_cpu;
> >>>                            ^^^^^^^^^^^^^^^^^^
> >>>
> >>> Why is this a safe dereference? Could not another cpu have just
> >>> dropped the sem (and thus set sem->owner to NULL and oops)?
> >>>
> >
> > The rcu read lock should protect against sem->owner being NULL.
> 
> It doesn't.
> 
> Here's the comment from mutex_spin_on_owner():
> 
>    /*
>     * Look out! "owner" is an entirely speculative pointer
>     * access and not reliable.
>     */
> 

In mutex_spin_on_owner, after rcu_read_lock, the owner_running()
function de-references the owner pointer.  The rcu_read_lock prevents
owner from getting freed. The comment's intention is to warn that
owner->on_cpu may not be reliable.

I'm using similar logic in rw-sem.

Tim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
