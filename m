Message-ID: <428A21FA.3090203@engr.sgi.com>
Date: Tue, 17 May 2005 11:55:22 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration and madvise/mbind
References: <428A1F6F.2020109@engr.sgi.com>
In-Reply-To: <428A1F6F.2020109@engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Hellwig <hch@engr.sgi.com>, Andi Kleen <ak@muc.de>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Ray Bryant wrote:

> 
> However, I've come across a minor issue that has complicated my thinking
> on this:  If one were to use madvise() or mbind() to apply the migration
> policy flags (e. g. the three policies we basically need are:  migrate,
> migrate_non_shared, and migrated_none, used for normal files, libraries,
> and shared binaries, respectively) then when madvise() (let us say)
> is called, it isn't good enough to mark the vma that the address and
> length point to, it's necessary to reach down to a common subobject,
> (such as the file struct, address space struct, or inode) and mark
> that.
> 
> If the vma is all that is marked, then when migrate_pages() is called
> and as a result some other address space than the current one is examined,
> it won't see the flags.
> 
> (Remember that the migrate_pages() system call takes a pid, a count,
> and a list of old and new node so that this process is allowed to
> migrate that process over there, which is what the batch manager needs
> to do.  Running madvise() in the current process's address space doesn't
> help much unless it marks something deeper in the address space hierarchy
> than a vma.)
> 
> This is something quite a bit different than what madvise() or mbind()
> do today.  (They just manipulate vma's AFAIK.)
> 
> Does that observation change y'all's thinking on this in any way?

Achh.... Nevermind... my bad.

If we do the madvise/mbind in each pid (via exec_ve() ld.so) then we can
mark just the vma and that is fine.  I was off on some other tangent....

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
