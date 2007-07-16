Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6GJVHQh001905
	for <linux-mm@kvack.org>; Mon, 16 Jul 2007 15:31:17 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6GJVHBd407474
	for <linux-mm@kvack.org>; Mon, 16 Jul 2007 15:31:17 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6GJVGGn029058
	for <linux-mm@kvack.org>; Mon, 16 Jul 2007 15:31:17 -0400
Subject: Re: [PATCH] Simplify /proc/<pid|self>/exe symlink code
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20070713020710.GA21668@ftp.linux.org.uk>
References: <1184292012.13479.14.camel@localhost.localdomain>
	 <20070713020710.GA21668@ftp.linux.org.uk>
Content-Type: text/plain
Date: Mon, 16 Jul 2007 12:31:14 -0700
Message-Id: <1184614274.4877.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Andrew Morton <akpm@osdl.org>, Chris Wright <chrisw@sous-sol.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "Hallyn, Serge" <serue@us.ibm.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-13 at 03:07 +0100, Al Viro wrote:
> On Thu, Jul 12, 2007 at 07:00:12PM -0700, Matt Helsley wrote:
> > This patch avoids holding the mmap semaphore while walking VMAs in response to
> > programs which read or follow the /proc/<pid|self>/exe symlink. This also allows
> > us to merge mmu and nommu proc_exe_link() functions. The costs are holding the
> > task lock, a separate reference to the executable file stored in the task
> > struct, and increased code in fork, exec, and exit paths.
> 
> I don't think it's a food idea.  Consider a program that deliberately
> creates an executable anon memory, copies the binary there, jumps there
> and unmaps the original.   In the current tree you'll get nothing
> pinning the binary; with your patch it will remained busy.

	Yes, it will prevent the filesystem with the executable file from being
unmounted. Do you have an example where the original filesystem urgently
needs to be unmounted while this unusual executable is running? Or is
umount -l sufficient here?

> It's not a common situation, of course, but there are legitimate uses
> for such technics...

	Yes, I'm aware of at least one example where this technique has
legitimate uses: libhugetlbfs. I'm interested in testing others you may
be able to recommend as well.

	Furthermore, in your example the VMA walk would make /proc/self/exe a
symlink to the file that backs the next executable VMA: libc, libdl,
etc. That seems rather odd to me. In contrast, with my
patch /proc/self/exe would always be a symlink to the original
executable.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
