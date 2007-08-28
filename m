Date: Tue, 28 Aug 2007 19:01:44 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070828180144.GA32585@infradead.org>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827181056.GA30176@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Nelson <dcn@sgi.com>
Cc: Al Viro <viro@ftp.linux.org.uk>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 01:10:56PM -0500, Dean Nelson wrote:
> > Does it?  Well, then open the file in question and start doing close(dup(fd))
> > in a loop.  Won't take long for an oops...
> 
> Actually it won't oops. And that's because when the file is opened,
> xpmem_open() creates a structure for that thread group, and when
> xpmem_flush() is called on the close() it first looks for that structure
> and if it finds it then it does what it needs to do (which includes the
> put_task_struct() call) and then finishes off by destroying the structure.
> So for subsequent closes xpmem_flush() returns without calling
> put_task_struct().

Your refcounting is totally broken.  fds can be passed around in the same
process group (which btw is not something driver should look at because
there are variants of different kinds of process groups depending on clone
flags), and your driver is going boom in most of the case.

We don't export the routines to acquire reference to task structs for
a reason, and this piece of junk called xpmem is not going to change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
