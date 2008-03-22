Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2MHv7MH099104
	for <linux-mm@kvack.org>; Sat, 22 Mar 2008 17:57:07 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2MHv67K2023636
	for <linux-mm@kvack.org>; Sat, 22 Mar 2008 18:57:06 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2MHv5IE017859
	for <linux-mm@kvack.org>; Sat, 22 Mar 2008 18:57:06 +0100
Date: Sat, 22 Mar 2008 18:57:05 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [kvm-devel] [RFC/PATCH 01/15] preparation: provide hook to
	enable pgstes in user pagetable
Message-ID: <20080322175705.GD6367@osiris.boeblingen.de.ibm.com>
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com> <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com> <47E29EC6.5050403@goop.org> <1206040405.8232.24.camel@nimitz.home.sr71.net> <47E2CAAC.6020903@de.ibm.com> <1206124176.30471.27.camel@nimitz.home.sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1206124176.30471.27.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: carsteno@de.ibm.com, Jeremy Fitzhardinge <jeremy@goop.org>, Christian Ehrhardt <EHRHARDT@de.ibm.com>, hollisb@us.ibm.com, arnd@arndb.de, kvm-devel@lists.sourceforge.net, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, jeroney@us.ibm.com, borntrae@linux.vnet.ibm.com, virtualization@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Avi Kivity <avi@qumranet.com>, rvdheij@gmail.com, Olaf Schnapper <os@de.ibm.com>, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

> What you've done with dup_mm() is probably the brute-force way that I
> would have done it had I just been trying to make a proof of concept or
> something.  I'm worried that there are a bunch of corner cases that
> haven't been considered.
> 
> What if someone else is poking around with ptrace or something similar
> and they bump the mm_users:
> 
> +       if (tsk->mm->context.pgstes)
> +               return 0;
> +       if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||
> +           tsk->mm != tsk->active_mm || tsk->mm->ioctx_list)
> +               return -EINVAL;
> -------->HERE
> +       tsk->mm->context.pgstes = 1;    /* dirty little tricks .. */
> +       mm = dup_mm(tsk);
> 
> It'll race, possibly fault in some other pages, and those faults will be
> lost during the dup_mm().  I think you need to be able to lock out all
> of the users of access_process_vm() before you go and do this.  You also
> need to make sure that anyone who has looked at task->mm doesn't go and
> get a reference to it and get confused later when it isn't the task->mm
> any more.
> 
> > Therefore, we need to reallocate the page table after fork() 
> > once we know that task is going to be a hypervisor. That's what this 
> > code does: reallocate a bigger page table to accomondate the extra 
> > information. The task needs to be single-threaded when calling for 
> > extended page tables.
> > 
> > Btw: at fork() time, we cannot tell whether or not the user's going to 
> > be a hypervisor. Therefore we cannot do this in fork.
> 
> Can you convert the page tables at a later time without doing a
> wholesale replacement of the mm?  It should be a bit easier to keep
> people off the pagetables than keep their grubby mitts off the mm
> itself.

Yes, as far as I can see you're right. And whatever we do in arch code,
after all it's just a work around to avoid a new clone flag.
If something like clone() with CLONE_KVM would be useful for more
architectures than just s390 then maybe we should try to get a flag.

Oh... there are just two unused clone flag bits left. Looks like the
namespace changes ate up a lot of them lately.

Well, we could still play dirty tricks like setting a bit in current
via whatever mechanism which indicates child-wants-extended-page-tables
and then just fork and be happy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
