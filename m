From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906210529.WAA94244@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Sun, 20 Jun 1999 22:29:14 -0700 (PDT)
In-Reply-To: 14186.31507.833263.846717@dukat.scot.redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Okay, lets see if I am being stupid again ...

Imagine a process exitting, executing exit_mmap. exit_mmap
cleans out the vma list from the mm, ie sets mm->mmap = 0.
Then, it invokes vm_ops->unmap, say on a MAP_SHARED file
vma, which starts file io, that puts the process to sleep.

Now, a sys_swapoff comes in ... this will not be able to
retrieve the swap handles from the former process (since
the vma's are invisible), so it may end up deleting the 
device with a warning message about non 0 swap_map count.

The exitting process then invokes a bunch of swap_free()s
via zap_page_range, whereas the swap id might already have
been reassigned.

If there's no protection against this, a possible fix would 
be for exit_mmap not to clean the vma list, rather delete a
vma at a time from the list.

So, what is the call to swap_free doing in filemap_sync_pte?
When will this call ever be executed?

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
