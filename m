Date: Wed, 17 Sep 2003 15:44:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How best to bypass the page cache from within a kernel module?
Message-ID: <20030917224453.GM14079@holomorphy.com>
References: <20030917204047.GI14079@holomorphy.com> <Pine.LNX.4.44L0.0309171721510.642-100000@ida.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0309171721510.642-100000@ida.rowland.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2003, William Lee Irwin III wrote:
>> Well, you can get one from the slab allocator, though I expect there will
>> be a followup question here...

On Wed, Sep 17, 2003 at 05:30:50PM -0400, Alan Stern wrote:
> Yes :-)  The slab allocator will give me a nice piece of memory, but I 
> will still need to turn that into a valid mm_struct.  I can't call 
> alloc_mm() and friends because they're not EXPORTed.

Well, alloc_mm() doesn't really do much, so it should be easily
preppable along the same lines if it absolutely has to be a module. In
truth, the mm slab should be using a ctor (the vma slab too).


On Wed, 17 Sep 2003, William Lee Irwin III wrote:
>> Hmm. Sounds like you want to grab a user address space and do userspace
>> stuff inside there. Maybe avoid do_execve() etc. and call sys_*() for
>> everything else outright? The question itself probably wants sys_mmap()
>> or some such, or handle_mm_fault() depending on what you have in mind
>> for allocation.

On Wed, Sep 17, 2003 at 05:30:50PM -0400, Alan Stern wrote:
> sys_mmap() or something along those lines would be good.  But I can't call
> it directly because 2.6 doesn't EXPORT the sys_xxx functions.  Also, I'm
> not clear on whether mmap() lets you create an anonymous mapping -- one
> backed by swap space rather than a file -- that's what I would want to do.

That's a pain. It's probably easier to just compile the driver in, then.


On Wed, 17 Sep 2003, William Lee Irwin III wrote:
>> invalidate_inode_pages().

On Wed, Sep 17, 2003 at 05:30:50PM -0400, Alan Stern wrote:
> Great!  I'll search through the kernel code for it.

Should be in mm/filemap.c


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
