Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19D746B005C
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 17:10:33 -0500 (EST)
Date: Thu, 12 Feb 2009 14:10:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: What can OpenVZ do?
Message-Id: <20090212141014.2cd3d54d.akpm@linux-foundation.org>
In-Reply-To: <1234475483.30155.194.camel@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, mingo@elte.hu, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Feb 2009 13:51:23 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2009-02-12 at 11:42 -0800, Andrew Morton wrote:
> > On Thu, 12 Feb 2009 13:30:35 -0600
> > Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
> > > 
> > > > > - In bullet-point form, what features are missing, and should be added?
> > > > 
> > > >  * support for more architectures than i386
> > > >  * file descriptors:
> > > >   * sockets (network, AF_UNIX, etc...)
> > > >   * devices files
> > > >   * shmfs, hugetlbfs
> > > >   * epoll
> > > >   * unlinked files
> > > 
> > > >  * Filesystem state
> > > >   * contents of files
> > > >   * mount tree for individual processes
> > > >  * flock
> > > >  * threads and sessions
> > > >  * CPU and NUMA affinity
> > > >  * sys_remap_file_pages()
> > > 
> > > I think the real questions is: where are the dragons hiding? Some of
> > > these are known to be hard. And some of them are critical checkpointing
> > > typical applications. If you have plans or theories for implementing all
> > > of the above, then great. But this list doesn't really give any sense of
> > > whether we should be scared of what lurks behind those doors.
> > 
> > How close has OpenVZ come to implementing all of this?  I think the
> > implementatation is fairly complete?
> 
> I also believe it is "fairly complete".  At least able to be used
> practically.
> 
> > If so, perhaps that can be used as a guide.  Will the planned feature
> > have a similar design?  If not, how will it differ?  To what extent can
> > we use that implementation as a tool for understanding what this new
> > implementation will look like?
> 
> Yes, we can certainly use it as a guide.  However, there are some
> barriers to being able to do that:
> 
> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
>  628 files changed, 59597 insertions(+), 2927 deletions(-)
> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
>   84887  290855 2308745
> 
> Unfortunately, the git tree doesn't have that great of a history.  It
> appears that the forward-ports are just applications of huge single
> patches which then get committed into git.  This tree has also
> historically contained a bunch of stuff not directly related to
> checkpoint/restart like resource management.
> 
> We'd be idiots not to take a hard look at what has been done in OpenVZ.
> But, for the time being, we have absolutely no shortage of things that
> we know are important and know have to be done.  Our largest problem is
> not finding things to do, but is our large out-of-tree patch that is
> growing by the day. :(
> 

Well we have a chicken-and-eggish thing.  The patchset will keep
growing until we understand how much of this:

> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
>  628 files changed, 59597 insertions(+), 2927 deletions(-)

we will be committed to if we were to merge the current patchset.


Now, we've gone in blind before - most notably on the
containers/cgroups/namespaces stuff.  That hail mary pass worked out
acceptably, I think.  Maybe we got lucky.  I thought that
net-namespaces in particular would never get there, but it did.

That was a very large and quite long-term-important user-visible
feature.

checkpoint/restart/migration is also a long-term-...-feature.  But if
at all possible I do think that we should go into it with our eyes a
little less shut.

Interestingly, there was also prior-art for
containers/cgroups/namespaces within OpenVZ.  But we decided up-front
(I think) that the eventual implementation would have little in common
with preceding implementations.


Oh, and I'd disagree with your new Subject:.  It's pretty easy to find
out what OpenVZ can do.  The more important question here is "how much
of a mess did it make when it did it?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
