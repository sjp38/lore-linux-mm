Date: Wed, 17 Sep 2003 17:30:50 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: How best to bypass the page cache from within a kernel module?
In-Reply-To: <20030917204047.GI14079@holomorphy.com>
Message-ID: <Pine.LNX.4.44L0.0309171721510.642-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2003, William Lee Irwin III wrote:

> On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> > 1. What's the proper way for a kernel thread running in a module to get
> > hold of an mm_struct or to keep the one it had before calling daemonize()?
> 
> Well, you can get one from the slab allocator, though I expect there will
> be a followup question here...

Yes :-)  The slab allocator will give me a nice piece of memory, but I 
will still need to turn that into a valid mm_struct.  I can't call 
alloc_mm() and friends because they're not EXPORTed.

Would this work: atomically increment current->mm->users and save the 
value of current->mm before calling daemonize(), then re-assign the old 
value back to current->mm afterwards?

> On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> > 2. What's the proper way for a kernel thread to allocate a region of 
> > userspace memory?
> 
> Hmm. Sounds like you want to grab a user address space and do userspace
> stuff inside there. Maybe avoid do_execve() etc. and call sys_*() for
> everything else outright? The question itself probably wants sys_mmap()
> or some such, or handle_mm_fault() depending on what you have in mind
> for allocation.

sys_mmap() or something along those lines would be good.  But I can't call
it directly because 2.6 doesn't EXPORT the sys_xxx functions.  Also, I'm
not clear on whether mmap() lets you create an anonymous mapping -- one
backed by swap space rather than a file -- that's what I would want to do.

> On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> > 3. What's the proper way to invalidate all entries in the page cache
> > that refer to a particular file?
> 
> invalidate_inode_pages().

Great!  I'll search through the kernel code for it.

Alan Stern


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
