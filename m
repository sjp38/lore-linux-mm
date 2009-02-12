Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4E76B0085
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:04:13 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1CN29ux007745
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:02:09 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1CN4Bwc185958
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:04:11 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CN4Ajx025925
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:04:10 -0500
Subject: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090212141014.2cd3d54d.akpm@linux-foundation.org>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 15:04:05 -0800
Message-Id: <1234479845.30155.220.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, mingo@elte.hu, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 14:10 -0800, Andrew Morton wrote:
> On Thu, 12 Feb 2009 13:51:23 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Thu, 2009-02-12 at 11:42 -0800, Andrew Morton wrote:
> > > On Thu, 12 Feb 2009 13:30:35 -0600
> > > Matt Mackall <mpm@selenic.com> wrote:
> > > 
> > > > On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
> > > > 
> > > > > > - In bullet-point form, what features are missing, and should be added?
> > > > > 
> > > > >  * support for more architectures than i386
> > > > >  * file descriptors:
> > > > >   * sockets (network, AF_UNIX, etc...)
> > > > >   * devices files
> > > > >   * shmfs, hugetlbfs
> > > > >   * epoll
> > > > >   * unlinked files
> > > > 
> > > > >  * Filesystem state
> > > > >   * contents of files
> > > > >   * mount tree for individual processes
> > > > >  * flock
> > > > >  * threads and sessions
> > > > >  * CPU and NUMA affinity
> > > > >  * sys_remap_file_pages()
> > > > 
> > > > I think the real questions is: where are the dragons hiding? Some of
> > > > these are known to be hard. And some of them are critical checkpointing
> > > > typical applications. If you have plans or theories for implementing all
> > > > of the above, then great. But this list doesn't really give any sense of
> > > > whether we should be scared of what lurks behind those doors.
> > > 
> > > How close has OpenVZ come to implementing all of this?  I think the
> > > implementatation is fairly complete?
> > 
> > I also believe it is "fairly complete".  At least able to be used
> > practically.
> > 
> > > If so, perhaps that can be used as a guide.  Will the planned feature
> > > have a similar design?  If not, how will it differ?  To what extent can
> > > we use that implementation as a tool for understanding what this new
> > > implementation will look like?
> > 
> > Yes, we can certainly use it as a guide.  However, there are some
> > barriers to being able to do that:
> > 
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
> >  628 files changed, 59597 insertions(+), 2927 deletions(-)
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
> >   84887  290855 2308745
> > 
> > Unfortunately, the git tree doesn't have that great of a history.  It
> > appears that the forward-ports are just applications of huge single
> > patches which then get committed into git.  This tree has also
> > historically contained a bunch of stuff not directly related to
> > checkpoint/restart like resource management.
> > 
> > We'd be idiots not to take a hard look at what has been done in OpenVZ.
> > But, for the time being, we have absolutely no shortage of things that
> > we know are important and know have to be done.  Our largest problem is
> > not finding things to do, but is our large out-of-tree patch that is
> > growing by the day. :(
> > 
> 
> Well we have a chicken-and-eggish thing.  The patchset will keep
> growing until we understand how much of this:
> 
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
> >  628 files changed, 59597 insertions(+), 2927 deletions(-)
> 
> we will be committed to if we were to merge the current patchset.

Here's the measurement that Alexey suggested:

dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... kernel/cpt/ | diffstat 
 Makefile        |   53 +
 cpt_conntrack.c |  365 ++++++++++++
 cpt_context.c   |  257 ++++++++
 cpt_context.h   |  215 +++++++
 cpt_dump.c      | 1250 ++++++++++++++++++++++++++++++++++++++++++
 cpt_dump.h      |   16 
 cpt_epoll.c     |  113 +++
 cpt_exports.c   |   13 
 cpt_files.c     | 1626 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 cpt_files.h     |   71 ++
 cpt_fsmagic.h   |   16 
 cpt_inotify.c   |  144 ++++
 cpt_kernel.c    |  177 ++++++
 cpt_kernel.h    |   99 +++
 cpt_mm.c        |  923 +++++++++++++++++++++++++++++++
 cpt_mm.h        |   35 +
 cpt_net.c       |  614 ++++++++++++++++++++
 cpt_net.h       |    7 
 cpt_obj.c       |  162 +++++
 cpt_obj.h       |   62 ++
 cpt_proc.c      |  595 ++++++++++++++++++++
 cpt_process.c   | 1369 ++++++++++++++++++++++++++++++++++++++++++++++
 cpt_process.h   |   13 
 cpt_socket.c    |  790 ++++++++++++++++++++++++++
 cpt_socket.h    |   33 +
 cpt_socket_in.c |  450 +++++++++++++++
 cpt_syscalls.h  |  101 +++
 cpt_sysvipc.c   |  403 +++++++++++++
 cpt_tty.c       |  215 +++++++
 cpt_ubc.c       |  132 ++++
 cpt_ubc.h       |   23 
 cpt_x8664.S     |   67 ++
 rst_conntrack.c |  283 +++++++++
 rst_context.c   |  323 ++++++++++
 rst_epoll.c     |  169 +++++
 rst_files.c     | 1648 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rst_inotify.c   |  196 ++++++
 rst_mm.c        | 1151 +++++++++++++++++++++++++++++++++++++++
 rst_net.c       |  741 +++++++++++++++++++++++++
 rst_proc.c      |  580 +++++++++++++++++++
 rst_process.c   | 1640 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rst_socket.c    |  918 +++++++++++++++++++++++++++++++
 rst_socket_in.c |  489 ++++++++++++++++
 rst_sysvipc.c   |  633 +++++++++++++++++++++
 rst_tty.c       |  384 +++++++++++++
 rst_ubc.c       |  131 ++++
 rst_undump.c    | 1007 ++++++++++++++++++++++++++++++++++
 47 files changed, 20702 insertions(+)

One important thing that leaves out is the interaction that this code
has with the rest of the kernel.  That's critically important when
considering long-term maintenance, and I'd be curious how the OpenVZ
folks view it. 

> Now, we've gone in blind before - most notably on the
> containers/cgroups/namespaces stuff.  That hail mary pass worked out
> acceptably, I think.  Maybe we got lucky.  I thought that
> net-namespaces in particular would never get there, but it did.
> 
> That was a very large and quite long-term-important user-visible
> feature.
> 
> checkpoint/restart/migration is also a long-term-...-feature.  But if
> at all possible I do think that we should go into it with our eyes a
> little less shut.

One thing Ingo has asked for that I understand a bit more clearly is a
programmatic statement of what is and is not covered by this current
code.  That's certainly one eye-opening activity which I'll get to
immediately.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
