Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 72DC16B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:50:14 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so7546349pad.30
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:50:14 -0700 (PDT)
Date: Wed, 18 Sep 2013 01:50:05 +0100 (BST)
From: Mark Hills <mark@xwax.org>
Subject: Re: ps lockups, cgroup memory reclaim
In-Reply-To: <20130917162807.GF3278@cmpxchg.org>
Message-ID: <1309180141270.29932@wes.ijneb.com>
References: <1309171621250.11844@wes.ijneb.com> <20130917162807.GF3278@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

On Tue, 17 Sep 2013, Johannes Weiner wrote:

> On Tue, Sep 17, 2013 at 04:50:42PM +0100, Mark Hills wrote:
> > I'm investigating intermitten kernel lockups in an HPC environment, with 
> > the RedHat kernel.
> > 
> > The symptoms are seen as lockups of multiple ps commands, with one 
> > consuming full CPU:
> > 
> >   # ps aux | grep ps
> >   root     19557 68.9  0.0 108100   908 ?        D    Sep16 1045:37 ps --ppid 1 -o args=
> >   root     19871  0.0  0.0 108100   908 ?        D    Sep16   0:00 ps --ppid 1 -o args=
> > 
> > SIGKILL on the busy one causes the other ps processes to run to completion 
> > (TERM has no effect).
> 
> Any chance you can get to the stack of the non-busy blocked tasks?
> 
> It would be /proc/19871/stack in this case.

I had to return the machine above to the cluster, but next time I'll log 
this information.
 
> > In this case I was able to run my own ps to see the process list, but not 
> > always.
> > 
> > perf shows the locality of the spinning, roughly:
> > 
> >   proc_pid_cmdline
> >   get_user_pages
> >   handle_mm_fault
> >   mem_cgroup_try_charge_swapin
> >   mem_cgroup_reclaim
> > 
> > There are two entry points, the codepaths taken are better shown by the 
> > attached profile of CPU time.
> 
> Looks like it's spinning like crazy in shrink_mem_cgroup_zone().
> Maybe an LRU counter underflow, maybe endlessly looping on the
> should_continue_reclaim() compaction condition.  But I don't see an
> obvious connection to why killing the busy task wakes up the blocked
> one.

Maybe it's as simple as the lock taken at quite a high level; perhaps even 
a lock when reading values for /proc.

But no need for me to guess, we'll find out next time from the /proc 
information.
 
> So yeah, it would be helpful to know what that task is waiting for.
> 
> > We've had this behaviour since switching to Scientific Linux 6 (based on 
> > RHEL6, like CentOS) at kernel 2.6.32-279.9.1.el6.x86_64.
> > 
> > The example above is kernel 2.6.32-358.el6.x86_64.
> 
> Can you test with the debug build?  That should trap LRU counter
> underflows at least.

Ah, excellent -- I did not realise there was a kernel-debug package.

I'll see if I can isolate this with more detail from that kernel 
(including the stack trace of each task that is hung)

> If you have the possibility to recompile the distribution kernel I can 
> provide you with debug patches.

Absolutely, I can deploy a patched kernels but not cluster-wide. Let's 
hope I can get enough coverage to catch the bug.

Hopefully I'll have more information soon.

Thanks

-- 
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
