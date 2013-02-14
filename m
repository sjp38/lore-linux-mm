Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 994C16B0007
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 16:52:36 -0500 (EST)
Date: Thu, 14 Feb 2013 13:52:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-Id: <20130214135234.234a93f9.akpm@linux-foundation.org>
In-Reply-To: <20130214213512.GH3438@sgi.com>
References: <20130212213534.GA5052@sgi.com>
	<20130212135726.a40ff76f.akpm@linux-foundation.org>
	<20130213150340.GJ3460@sgi.com>
	<20130213121149.25a0e3bd.akpm@linux-foundation.org>
	<20130213210305.GV3438@sgi.com>
	<20130214130856.13d1b5bb.akpm@linux-foundation.org>
	<20130214213512.GH3438@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de

On Thu, 14 Feb 2013 15:35:12 -0600
Robin Holt <holt@sgi.com> wrote:

> I am open to suggestions.  Can you suggest existing kernel functionality
> that allows one task to map another virtual address space into their
> va space to allow userland-to-userland copies without system calls?
> If there is functionality that has been introduced in the last couple
> years, I could very well have missed it as I have been fairly heads-down
> on other things for some time.

That's conceptually very similar to mm/process_vm_access.c. 
process_vm_readv/writev do kernel-based copying rather than a direct
mmap.

> > To what extent is all this specific to SGI hardware characteristics?
> 
> SGI's hardware allows two things, a vastly larger virtual address space
> and the ability to access memory in other system images on the same numa
> fabric which are beyond the processsors physical addressing capabilities.
> 
> I am fairly sure Cray has taken an older version of XPMEM and stripped
> out a bunch of SGI specific bits and implemented it on their hardware.
> 
> > > The above, of course, is an oversimplification, but should give you and
> > > idea of the big picture design goals.
> > >
> > > Does any of this make sense?  Do you see areas where you think we should
> > > extend regular mm functionality to include these functions?
> > > 
> > > How would you like me to proceed?
> > 
> > I'm obviously on first base here, but overall approach:
> > 
> > - Is the top-level feature useful to general Linux users?  Perhaps
> >   after suitable generalisations (aka dumbing down :))
> 
> I am not sure how useful it is.  I know IBM has tried in the past to
> get a similar feature introduced.  I believe they settled on a ptrace
> extension to do direct user-to-user copies from within the kernel.

process_vm_readv/writev is from Christopher Yeoh@IBM.

> > - Even if the answer to that is "no", should we maintain the feature
> >   in-tree rather than out-of-tree?
> 
> Not sure on the second one, but I believe Linus' objection is security and
> I can certainly understand that.  Right now, SGI's xpmem implementation
> enforces that all jobs in the task need to have the same UID.  There is
> no exception for root or and administrator.

I'd have thought that the security processing of a direct map would be
identical to those in process_vm_readv/writev?

If we were to add a general map-this-into-that facility which is
available to and runs adequately on our typical machines, I assume your
systems would need some SGI-specific augmentation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
