Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1GJuPxT018663
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 13:56:25 -0600
Date: Wed, 16 Feb 2005 13:56:09 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: manual page migration -- issue list
Message-ID: <20050216195609.GA13528@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050216015622.GB28354@lnx-holt.americas.sgi.com> <20050215202214.4b833bf3.pj@sgi.com> <20050216092011.GA6616@lnx-holt.americas.sgi.com> <20050216022009.7afb2e6d.pj@sgi.com> <20050216113047.GA8388@lnx-holt.americas.sgi.com> <20050216074550.313b1300.pj@sgi.com> <20050216160823.GA10620@lnx-holt.americas.sgi.com> <20050216112335.6d0cf44a.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050216112335.6d0cf44a.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Robin Holt <holt@sgi.com>, raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

On Wed, Feb 16, 2005 at 11:23:35AM -0800, Paul Jackson wrote:
> Robin wrote:
> > Reading /proc/<pid>maps just scans through the vmas and not the
> > address space.
> 
> Yes - you're right.
> 
> So the number of system calls in your example of a few hours ago, using
> your preferred array API, if you include the reads of each tasks
> /proc/<pid>/maps file, is about equal to the number of tasks, right?
> 
> And I take it that the user code you asked Ray about looks at these
> maps files for each of the tasks to be migrated, identifies each
> mapped range of each mapped object (mapped file or whatever) and
> calculates a fairly minimum set of tasks and virtual address ranges
> therein, sufficient to cover all the mapped objects that should
> be migrated, thus minimizing the amount of scanning that needs
> to be done of individual pages.
> 
> And further I take it that you recommend the above described code [to
> find a fairly minimum set of tasks and address ranges to scan that will
> cover any page of interest] be put in user space, not in the kernel (a
> quite reasonable recommendation).

I think user space for a few reasons.  The code in the kernel will be
much easier to digest and ensure it is a bug-free as possible.  If bugs
are found or issues arise in the portions that are in userland, we are
left with a maximum amount of flexibility to correct the issue without
needing kernel code change.  In a different direction, if I am a support
person trying to figure out why an application is performing poorly,
I can try migrating portions of the applications address space to a node
closer to the cpu and hopefully see a performance improvement.

> 
> Why didn't your example have some writable private pages?  Wouldn't such
> pages be commonplace, and wouldn't they have to be migrated for each
> thread, resulting in at least N calls to the new sys_page_migrate()
> system call, for N tasks, rather than the 3 calls in your example?

You are right about everything above.  The calls to migrate the private
regions will be small in comparison to the typical large shared mapping.
The real work horse is going to always be walking the page tables and
that will take time.  I am advocating for a system call which covers the
needs and also remains flexible enough to correct short comings in our
thinking about all the possible permutations of user virtual address
spaces.

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
