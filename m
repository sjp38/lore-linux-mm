Date: Wed, 31 Jan 2007 02:31:58 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/9] buffered write deadlock fix
Message-ID: <20070131013157.GA21285@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070130125558.ae9119b0.akpm@osdl.org> <20070130152119.e0a18e58.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070130152119.e0a18e58.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2007 at 03:21:19PM -0800, Andrew Morton wrote:
> On Tue, 30 Jan 2007 12:55:58 -0800
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > y'know, four or five years back I fixed this bug by doing
> > 
> > 	current->locked_page = page;
> > 
> > in the write() code, and then teaching the pagefault code to avoid locking
> > the same page.  Patch below.
> > 
> > But then evil mean Hugh pointed out that the patch is still vulnerable to
> > ab/ba deadlocking so I dropped it.
> 
> And he was right, of course.  Task A holds file a's i_mutex and takes a
> fault against file b's page.  Task B holds file b's i_mutex and takes a
> fault against file a's page.  Drat.
> 
> I wonder if there's a sane way of preventing that.

If you want to go down the path of carrying state around in task_struct,
you can take the mmap_sem and set a flag, then get_user_pages the source
page and lock both source and destination in ascending order, then your
page fault handler checks the flag and skips mmap_sem, and the rest of
your fault path checks both the page locks you're holding.

At which point you arrive at a horrible mess :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
