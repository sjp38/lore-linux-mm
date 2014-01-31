Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 309746B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 15:24:11 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so4852207pab.17
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:24:10 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id k3si11698067pbb.324.2014.01.31.12.24.08
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 12:24:09 -0800 (PST)
Message-ID: <1391199846.2172.49.camel@dabdike.int.hansenpartnership.com>
Subject: Re: Fwd: CGroups and pthreads
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 31 Jan 2014 12:24:06 -0800
In-Reply-To: <CALaYU_AA8fMLmp_Ng9Mhm0ztcXA0EHCxkU3p68tKs87G48NrOw@mail.gmail.com>
References: 
	<CALaYU_BZ8iuHnAgkss1wO7BK3qULgotYSpmX4nqX=uC+aTnddA@mail.gmail.com>
	 <CALaYU_AA8fMLmp_Ng9Mhm0ztcXA0EHCxkU3p68tKs87G48NrOw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dermot McGahon <dmcgahon@waratek.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org

[cc to cgroups@ added]
On Wed, 2014-01-29 at 17:15 +0000, Dermot McGahon wrote:
> Forwarding a question that was first asked on cgroups mailing list.
> Someone recommended asking here instead.

Right, but you still need to keep cgroups in the cc otherwise the thread
gets fractured

>  We believe that we received
> the correct answer, which is that cgroup memory subsystem charges
> always to the leader of the Process Group rather than to the TID.
> Could someone confirm that is definitely the case (testing does bear
> that out).

Michal Hocko already told you that the memory controller charges per
address space.  Threads within a process all share the same address
space so there's no physical way they can get charged separately.

>  It does make sense to us, since who is to say which thread
> should the process shared memory be accounted to. Unfortunately, in
> our specific scenario, which is a JVM that generally allocated out of
> the heap but occasionally loads native libraries that can allocate
> using malloc() in known threads, we would have that information. But
> we can see that in the general case it may not be that useful to
> account per-thread.

What is it you're trying to do?  Give a per thread memory allocation
limit?  That's not possible with cgroups because the threads share an
address space ... I don't even think it's possible with current glibc
and limits because heap space is shared between the threads as well.
This is a consequence of the fact that the brk system call is per
process not per thread.

> Would appreciate any comments you may have.
> 
> -----------
> 
> Question originally posted to cgroups mailing list:
> 
> Is it possible to apply cgroup memory subsystem controls to threads
> created with pthread_create() / clone or only tasks that have been
> created using fork and exec?

It is only possible to assert separate controls for things which have
different address spaces.  Usually fork/exec gives the new process a new
address space (although it doesn't have to).

> In testing, we seem to be seeing that all allocations are accounted
> for against the PPID / TGID and never the pthread_create()'d TID, even
> though the TID is an LWP and can be seen using top (though RSS is
> aggregate and global of course).
> 
> Attached is a simple test program used to print PID / TID and allocate
> memory from a cloned TID. After setting breakpoints in child and
> parent and setting up a cgroups hierarchy of 'parent' and 'child',
> apply memory.limit_in_bytes and memory.memsw.limit_in_bytes to the
> child cgroup only and adding the PID to the parent group and the TID
> to the child group we see that behaviour.
> 
> Is that expected? I realise that the subsystems are all different but
> what is confusing us slightly is that we have previously used the CPU
> subsystem to set cpu_shares and adding LWP / TID's to individual
> cgroups worked just fine for that
> 
> Am I misconfiguring somehow or is this a known difference between CPU
> and MEMORY subsystems?

Yes, CPU operates within the scheduler and all schedulable entities
(that's threads or processes) can be accounted separately.  memcg
operates on address spaces, so only things with separate address spaces
can be accounted separately.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
