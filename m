Date: Fri, 13 Jul 2007 03:07:10 +0100
From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] Simplify /proc/<pid|self>/exe symlink code
Message-ID: <20070713020710.GA21668@ftp.linux.org.uk>
References: <1184292012.13479.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184292012.13479.14.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Chris Wright <chrisw@sous-sol.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "Hallyn, Serge" <serue@us.ibm.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 12, 2007 at 07:00:12PM -0700, Matt Helsley wrote:
> This patch avoids holding the mmap semaphore while walking VMAs in response to
> programs which read or follow the /proc/<pid|self>/exe symlink. This also allows
> us to merge mmu and nommu proc_exe_link() functions. The costs are holding the
> task lock, a separate reference to the executable file stored in the task
> struct, and increased code in fork, exec, and exit paths.

I don't think it's a food idea.  Consider a program that deliberately
creates an executable anon memory, copies the binary there, jumps there
and unmaps the original.   In the current tree you'll get nothing
pinning the binary; with your patch it will remained busy.

It's not a common situation, of course, but there are legitimate uses
for such technics...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
