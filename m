Message-ID: <3F6F44AF.2030807@sgi.com>
Date: Mon, 22 Sep 2003 13:51:27 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: How best to bypass the page cache from within a kernel module?
References: <Pine.LNX.4.44L0.0309171402370.1171-100000@ida.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.0309171402370.1171-100000@ida.rowland.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Stern wrote:
> I'm working on a kernel module driver for Linux 2.6.  One of the things 
> this driver needs to do is perform a VERIFY command; which means checking 
> to make sure that certain disk sectors within a file actually can be read 
> without encountering a bad sector or other hardware error.  Now, I realize 
> that there are already issues involved with convincing the disk drive to 
> read from its media rather than from its cache.  But apart from that, my 
> problem is how to convince Linux to read from the drive rather than from 
> the page cache.
> 
> One suggestion was to use O_DIRECT when opening the file, because that
> does cause reads to go directly to the hardware.  The problem with this is
> that since the direct-I/O routines send file data directly to user
> buffers, they must check that the buffer addresses are valid and belong to
> the user's address space.  But my code runs in a kernel thread so it has
> no current->mm (and in any case I would prefer to use my kernel-space
> buffers rather than user-space memory).  It might be possible to get hold
> of an mm_struct, but it's not necessarily easy as mm_alloc() isn't
> EXPORTed.  Perhaps my thread could keep its original current->mm by
> incrementing current->mm->users before calling daemonize() and setting
> current->mm back to its original value afterward.  Is that legal?  Having
> done so, perhaps I could use some sort of mmap() call to allocate a
> user-space buffer that would be okay for direct-I/O.  What's the best way
> to do that -- what function would I have to call?
> 
> However, all that seems rather roundabout.  An equally acceptable solution 
> would be simply to invalidate all the entries in the page cache referring 
> to my file, so that reads would be forced to go to the drive.  Can anyone 
> tell me how to do that?

Take a look at invalidate_inode_pages()....

> 
> TIA,
> 
> Alan Stern
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
