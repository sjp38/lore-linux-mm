Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C83AC6B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 13:11:27 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1CI965M009690
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 11:09:06 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1CIBPvd213480
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 11:11:25 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CIBOeN031181
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 11:11:24 -0700
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090211141434.dfa1d079.akpm@linux-foundation.org>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 10:11:22 -0800
Message-Id: <1234462282.30155.171.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-11 at 14:14 -0800, Andrew Morton wrote:
> On Tue, 10 Feb 2009 09:05:47 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Tue, 2009-01-27 at 12:07 -0500, Oren Laadan wrote:
> > > Checkpoint-restart (c/r): a couple of fixes in preparation for 64bit
> > > architectures, and a couple of fixes for bugss (comments from Serge
> > > Hallyn, Sudakvev Bhattiprolu and Nathan Lynch). Updated and tested
> > > against v2.6.28.
> > > 
> > > Aiming for -mm.
> > 
> > Is there anything that we're waiting on before these can go into -mm?  I
> > think the discussion on the first few patches has died down to almost
> > nothing.  They're pretty reviewed-out.  Do they need a run in -mm?  I
> > don't think linux-next is quite appropriate since they're not _quite_
> > aimed at mainline yet.
> > 
> 
> I raised an issue a few months ago and got inconclusively waffled at. 
> Let us revisit.
> 
> I am concerned that this implementation is a bit of a toy, and that we
> don't know what a sufficiently complete implementation will look like. 
> There is a risk that if we merge the toy we either:
> 
> a) end up having to merge unacceptably-expensive-to-maintain code to
>    make it a non-toy or
> 
> b) decide not to merge the unacceptably-expensive-to-maintain code,
>    leaving us with a toy or
> 
> c) simply cannot work out how to implement the missing functionality.
> 
> 
> So perhaps we can proceed by getting you guys to fill out the following
> paperwork:
> 
> - In bullet-point form, what features are present?

 * i386 arch is supported
 * processes can perform a "self-checkpoint" which means calling 
   sys_checkpoint() on itself as well as "external checkpoint" where
   one task checkpoints another.
 * supported fds:
   * "normal" files on the filesystem
   * both endpoints of a pipe are checkpointed, as are pipe contents
 * each process's memory map is saved
 * the contents of anonymous memory are saved
 * infrastructure for managing objects in the checkpoint which are
   "shared" by multiple users like fds or a SVSV semaphore, for instance
 * multiple processes may be checkpointed during a single sys_checkpoint()

> - In bullet-point form, what features are missing, and should be added?

 * support for more architectures than i386
 * file descriptors:
  * sockets (network, AF_UNIX, etc...)
  * devices files
  * shmfs, hugetlbfs
  * epoll
  * unlinked files
 * Filesystem state
  * contents of files
  * mount tree for individual processes
 * flock
 * threads and sessions
 * CPU and NUMA affinity
 * sys_remap_file_pages()

This is a very minimal list that is surely incomplete and sure to grow.
I think of it like kernel scalability.  Is scalability important?  Do we
want the whole kernel to scale?  Yes, and yes, of course.  *Does* every
single device and feature in the kernel scale?  No way.  Will it ever be
"done"?  No freakin' way!  But, the kernel is scalable on the workloads
that are important to people.

Checkpoint/restart is the same way.  We intend to make core kernel
functionality checkpointable first.  We'll move outwards from there as
we (and our users) deem things important, but we'll certainly never be
done.  

> - Is it possible to briefly sketch out the design of the to-be-added
>   features?

For architecture (and indeed processor variation) we need a look at how
and when its registers are saved on kernel entry as well as things like
32/64-bit processes  and mm_context considerations.  There is x86_64,
s390 and ppc work ongoing.  Those ports have required quite small
changes in the generic code, which is a good sign.

Each fd type will need to be worked on separately.  Device files will
generally have to be one-off.  /dev/null has no internal state at all.
But, work needs done for devices which may have had all kinds of
ioctl()s done on them. 

Unlinked files will need their contents stored in the checkpoint so that
they may be copied over during restart (say to a temporary file),
opened, and unlinked again.  Files on kernel-internal mounts will need
similar treatment (think 'pipe_mnt').

We expect the filesystem *contents* to be taken care of generally by
outside mechanisms like dm or btrfs snapshotting.  

For the filesystem namespace, we'll effectively need to export what we
already have in /proc/$pid/mountinfo.  

I'm going to punt on explaining the networking bits for now because I
think I'd be wasting your time.  There are a couple of other guys around
much more versed in that area.

> For extra marks:
> 
> - Will any of this involve non-trivial serialisation of kernel
>   objects?  If so, that's getting into the
>   unacceptably-expensive-to-maintain space, I suspect.

We have some structures that are certainly tied to the kernel-internal
ones.  However, we are certainly *not* simply writing kernel structures
to userspace.  We could do that with /dev/mem.  We are carefully pulling
out the minimal bits of information from the kernel structures that we
*need* to recreate the function of the structure at restart.  There is a
maintenance burden here but, so far, that burden is almost entirely in
checkpoint/*.c.  We intend to test this functionality thoroughly to
ensure that we don't regress once we have integrated it.

> - Does (or will) this feature also support process migration?  If
>   not, I'd have thought this to be a showstopper.

You mean moving processes between machines?  Yes, it certainly will.
That is one of the primary design goals.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
