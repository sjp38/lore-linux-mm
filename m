From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14190.8514.488478.168281@dukat.scot.redhat.com>
Date: Mon, 21 Jun 1999 12:25:54 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906210529.WAA94244@google.engr.sgi.com>
References: <199906210529.WAA94244@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 20 Jun 1999 22:29:14 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Imagine a process exitting, executing exit_mmap. exit_mmap
> cleans out the vma list from the mm, ie sets mm->mmap = 0.
> Then, it invokes vm_ops->unmap, say on a MAP_SHARED file
> vma, which starts file io, that puts the process to sleep.

> Now, a sys_swapoff comes in ... this will not be able to
> retrieve the swap handles from the former process (since
> the vma's are invisible), so it may end up deleting the 
> device with a warning message about non 0 swap_map count.

> The exitting process then invokes a bunch of swap_free()s
> via zap_page_range, whereas the swap id might already have
> been reassigned.

Agreed.

> If there's no protection against this, a possible fix would 
> be for exit_mmap not to clean the vma list, rather delete a
> vma at a time from the list.

Looking at this, we have other problems: the forced swapin caused by
sys_swapoff() doesn't down() the mmap semaphore.  That is very bad
indeed.  We need to fix it.  If we fix it, then we can fix exit_mmap()
at the same time by taking the mmap semaphore while we do the
unmap/close operations.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
