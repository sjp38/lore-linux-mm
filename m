From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906211646.JAA42546@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Mon, 21 Jun 1999 09:46:19 -0700 (PDT)
In-Reply-To: <14190.8514.488478.168281@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 21, 99 12:25:54 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Sun, 20 Jun 1999 22:29:14 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > Imagine a process exitting, executing exit_mmap. exit_mmap
> > cleans out the vma list from the mm, ie sets mm->mmap = 0.
> > Then, it invokes vm_ops->unmap, say on a MAP_SHARED file
> > vma, which starts file io, that puts the process to sleep.
> 
> > Now, a sys_swapoff comes in ... this will not be able to
> > retrieve the swap handles from the former process (since
> > the vma's are invisible), so it may end up deleting the 
> > device with a warning message about non 0 swap_map count.
> 
> > The exitting process then invokes a bunch of swap_free()s
> > via zap_page_range, whereas the swap id might already have
> > been reassigned.
> 
> Agreed.
> 
> > If there's no protection against this, a possible fix would 
> > be for exit_mmap not to clean the vma list, rather delete a
> > vma at a time from the list.
> 
> Looking at this, we have other problems: the forced swapin caused by
> sys_swapoff() doesn't down() the mmap semaphore.  That is very bad
> indeed.  We need to fix it.  If we fix it, then we can fix exit_mmap()
> at the same time by taking the mmap semaphore while we do the
> unmap/close operations.
> 
> --Stephen
> 

I don't agree with you about swapoff needing the mmap_sem. In my
thinking, mmap_sem is needed to preserve the vma list, *if* you 
go to sleep while scanning the list. Updates to the vma fields/
chain are protected by kernel_lock and mmap_sem. If you are scanning
the vma list, and are guaranteed not to sleep, why would you need
to grab mmap_sem, if you already have the kernel_lock, like 
swapoff does?

Yes, but I agree we can play it safe and grab the lock ... that
might make it easier to synchronize with exit_mmap. Let me think
about this and post a possible patch.

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
