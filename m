Date: Mon, 27 Aug 2007 14:19:06 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070827191906.GB30176@sgi.com>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com> <20070827181544.GH21089@ftp.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827181544.GH21089@ftp.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 07:15:44PM +0100, Al Viro wrote:
> On Mon, Aug 27, 2007 at 01:10:56PM -0500, Dean Nelson wrote:
> > On Mon, Aug 27, 2007 at 05:13:28PM +0100, Al Viro wrote:
> > > On Mon, Aug 27, 2007 at 10:59:33AM -0500, Dean Nelson wrote:
> > > > This patch exports __put_task_struct as it is needed by XPMEM.
> > > > 
> > > > Signed-off-by: Dean Nelson <dcn@sgi.com>
> > > > 
> > > > ---
> > > > 
> > > > One struct file_operations registered by XPMEM, xpmem_open(), calls
> > > > 'get_task_struct(current->group_leader)' and another, xpmem_flush(), calls
> > > > 'put_task_struct(tg->group_leader)'.
> > > 
> > > Does it?  Well, then open the file in question and start doing close(dup(fd))
> > > in a loop.  Won't take long for an oops...
> > 
> > Actually it won't oops. And that's because when the file is opened,
> > xpmem_open() creates a structure for that thread group, and when
> > xpmem_flush() is called on the close() it first looks for that structure
> > and if it finds it then it does what it needs to do (which includes the
> > put_task_struct() call) and then finishes off by destroying the structure.
> > So for subsequent closes xpmem_flush() returns without calling
> > put_task_struct().
> 
> Then what kind of protection does it get you?  It can be called immediately
> after the call of ->open(), so you can't rely on it being there for any
> operations.  Makes no sense...

No operations can be done once it's closed, only while it's opened.

At fault time we need to be able to fault pages that belong to another
thread group. To call get_user_pages() we need to have the task_struct
and the mm_struct for the other thread group.

At one time we did look up the task_struct by pid, but that brought the
system to its knees due to heavy lock contention.

Do you know of a better way of doing this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
