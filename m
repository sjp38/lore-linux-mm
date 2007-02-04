Date: Sun, 4 Feb 2007 01:44:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070204014445.88e6c8c7.akpm@linux-foundation.org>
In-Reply-To: <20070204063833.23659.55105.sendpatchset@linux.site>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
	<20070204063833.23659.55105.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun,  4 Feb 2007 09:51:07 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:

> 2.  If we find the destination page is non uptodate, unlock it (this could be
>     made slightly more optimal), then find and pin the source page with
>     get_user_pages. Relock the destination page and continue with the copy.
>     However, instead of a usercopy (which might take a fault), copy the data
>     via the kernel address space.

argh.  We just can't go adding all this gunk into the write() path. 

mmap_sem, a full pte-walk, taking of pte-page locks, etc.  For every page. 
Even single-process write() will suffer, let along multithreaded stuff,
where mmap_sem contention may be the bigger problem.

I was going to do some quick measurements of this, but the code oopses
on power4 (http://userweb.kernel.org/~akpm/s5000402.jpg)

There's a build error in filemap_xip.c btw.



We need to think different.

What happened to the idea of doing an atomic copy into the non-uptodate
page and handling it somehow?



Another option might be to effectively pin the whole mm during the copy:

	down_read(&current->mm->unpaging_lock);
	get_user(addr);		/* Fault the page in */
	...
	copy_from_user()
	up_read(&current->mm->unpaging_lock);

then, anyone who wants to unmap pages from this mm requires
write_lock(unpaging_lock).  So we know the results of that get_user()
cannot be undone.

Or perhaps something like this can be done on a per-vma basis.  Just
something to tell the VM "hey, you're not allowed to unmap this page right
now"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
