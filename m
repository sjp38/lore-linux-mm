Date: Sat, 17 May 2003 17:06:13 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] vm_operation to avoid pagefault/inval race
Message-ID: <20030517170613.A11288@infradead.org>
References: <20030513135326.D2929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030513135326.D2929@us.ibm.com>; from paulmck@us.ibm.com on Tue, May 13, 2003 at 01:53:26PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 01:53:26PM -0700, Paul E. McKenney wrote:
> This patch adds a vm_operations_struct function pointer that allows
> networked and distributed filesystems to avoid a race between a
> pagefault on an mmap and an invalidation request from some other
> node.  The race goes as follows:

The race is real although currenly no in-tree filesystem is affected.
The patch is uglyh as hell, though.  The right fix is to change the
->nopage method to cover what do_no_page is currently, change anonymous
vmas to have vm_ops as well and set ->nopage to do_anonymous_page.

The gets of the current do_no_page become a new helper (__finish_nopage?)
and EXPORT_SYMBOL_GPL()ed.  It would also be nice if you could point to
a filesystem that actually needs this, but if you can get rid of the
do_anonymous_page special casing a patch might even be acceptable without it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
