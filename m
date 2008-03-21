Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2LITmLT020987
	for <linux-mm@kvack.org>; Fri, 21 Mar 2008 14:29:48 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2LITgUM187208
	for <linux-mm@kvack.org>; Fri, 21 Mar 2008 12:29:47 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2LITdAq007090
	for <linux-mm@kvack.org>; Fri, 21 Mar 2008 12:29:42 -0600
Subject: Re: [kvm-devel] [RFC/PATCH 01/15] preparation: provide hook to
	enable pgstes	in	user pagetable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <47E2CAAC.6020903@de.ibm.com>
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>
	 <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
	 <47E29EC6.5050403@goop.org> <1206040405.8232.24.camel@nimitz.home.sr71.net>
	 <47E2CAAC.6020903@de.ibm.com>
Content-Type: text/plain
Date: Fri, 21 Mar 2008 11:29:36 -0700
Message-Id: <1206124176.30471.27.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christian Ehrhardt <EHRHARDT@de.ibm.com>, hollisb@us.ibm.com, arnd@arndb.de, borntrae@linux.vnet.ibm.com, kvm-devel@lists.sourceforge.net, heicars2@linux.vnet.ibm.com, jeroney@us.ibm.com, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, rvdheij@gmail.com, Olaf Schnapper <os@de.ibm.com>, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-20 at 21:35 +0100, Carsten Otte wrote:
> Dave Hansen wrote:
> > Well, and more fundamentally: do we really want dup_mm() able to be
> > called from other code?
> > 
> > Maybe we need a bit more detailed justification why fork() itself isn't
> > good enough.  It looks to me like they basically need an arch-specific
> > argument to fork, telling the new process's page tables to take the
> > fancy new bit.
> > 
> > I'm really curious how this new stuff is going to get used.  Are you
> > basically replacing fork() when creating kvm guests?
> No. The trick is, that we do need bigger page tables when running 
> guests: our page tables are usually 2k, but when running a guest 
> they're 4k to track both guest and host dirty&reference information. 
> This looks like this:
> *----------*
> *2k PTE's  *
> *----------*
> *2k PGSTE  *
> *----------*
> We don't want to waste precious memory for all page tables. We'd like 
> to have one kernel image that runs regular server workload _and_ 
> guests.

That makes a lot of sense.

Is that layout (the shadow and regular stacked together) specified in
hardware somehow, or was it just chosen?

What you've done with dup_mm() is probably the brute-force way that I
would have done it had I just been trying to make a proof of concept or
something.  I'm worried that there are a bunch of corner cases that
haven't been considered.

What if someone else is poking around with ptrace or something similar
and they bump the mm_users:

+       if (tsk->mm->context.pgstes)
+               return 0;
+       if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||
+           tsk->mm != tsk->active_mm || tsk->mm->ioctx_list)
+               return -EINVAL;
-------->HERE
+       tsk->mm->context.pgstes = 1;    /* dirty little tricks .. */
+       mm = dup_mm(tsk);

It'll race, possibly fault in some other pages, and those faults will be
lost during the dup_mm().  I think you need to be able to lock out all
of the users of access_process_vm() before you go and do this.  You also
need to make sure that anyone who has looked at task->mm doesn't go and
get a reference to it and get confused later when it isn't the task->mm
any more.

> Therefore, we need to reallocate the page table after fork() 
> once we know that task is going to be a hypervisor. That's what this 
> code does: reallocate a bigger page table to accomondate the extra 
> information. The task needs to be single-threaded when calling for 
> extended page tables.
> 
> Btw: at fork() time, we cannot tell whether or not the user's going to 
> be a hypervisor. Therefore we cannot do this in fork.

Can you convert the page tables at a later time without doing a
wholesale replacement of the mm?  It should be a bit easier to keep
people off the pagetables than keep their grubby mitts off the mm
itself.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
