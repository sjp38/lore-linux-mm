Date: Wed, 17 Sep 2003 13:40:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How best to bypass the page cache from within a kernel module?
Message-ID: <20030917204047.GI14079@holomorphy.com>
References: <20030917195044.GH14079@holomorphy.com> <Pine.LNX.4.44L0.0309171617560.1646-100000@ida.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0309171617560.1646-100000@ida.rowland.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> I really want this to work through the filesystem.  99% of what my driver 
> does involves normal reads and writes.  And there are very good reasons 
> for having it run as a kernel thread rather than a user process.  It's 
> just that this one piece, which is a very minor part of the driver, needs 
> to avoid the page cache.
> So to reiterate my original questions:

Doesn't sound much most drivers after all that, but there's some weird
stuff out there.


On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> 1. What's the proper way for a kernel thread running in a module to get
> hold of an mm_struct or to keep the one it had before calling daemonize()?

Well, you can get one from the slab allocator, though I expect there will
be a followup question here...


On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> 2. What's the proper way for a kernel thread to allocate a region of 
> userspace memory?

Hmm. Sounds like you want to grab a user address space and do userspace
stuff inside there. Maybe avoid do_execve() etc. and call sys_*() for
everything else outright? The question itself probably wants sys_mmap()
or some such, or handle_mm_fault() depending on what you have in mind
for allocation.


On Wed, Sep 17, 2003 at 04:33:08PM -0400, Alan Stern wrote:
> 3. What's the proper way to invalidate all entries in the page cache
> that refer to a particular file?

invalidate_inode_pages().


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
