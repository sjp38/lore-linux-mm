Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA19643
	for <linux-mm@kvack.org>; Tue, 15 Oct 2002 11:10:03 -0700 (PDT)
Message-ID: <3DAC59F7.18678FA6@digeo.com>
Date: Tue, 15 Oct 2002 11:09:59 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch] mmap-speedup-2.5.42-C3
References: <Pine.LNX.4.44.0210151438440.10496-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, Saurabh Desai <sdesai@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, NPT library mailing list <phil-list@redhat.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> ...
> 
> Saurabh reported a slowdown after the first couple of thousands of
> threads, which i can reproduce as well. The reason for this slowdown is
> the get_unmapped_area() implementation, which tries to achieve the most
> compact virtual memory allocation, by searching for the vma at
> TASK_UNMAPPED_BASE, and then linearly searching for a hole. With thousands
> of linearly allocated vmas this is an increasingly painful thing to do ...

We've had reports of problems with that linear search before - for
a single-threaded application which was mapping a lot of little windows
into a huge file.
 
> ...
> 
> there are various solutions to this problem, none of which solve the
> problem in a 100% sufficient way, so i went for the simplest approach: i
> added code to cache the 'last known hole' address in mm->free_area_cache,
> which is used as a hint to get_unmapped_area().

This will have no effect on current kernel behaviour other than speeding
it up.  Looks good.
 
> ...
> The most generic and still perfectly-compact VM allocation solution would
> be to have a vma tree for the 'inverse virtual memory space', ie. a tree
> of free virtual memory ranges, which could be searched and iterated like
> the space of allocated vmas. I think we could do this by extending vmas,
> but the drawback is larger vmas. This does not save us from having to scan
> vmas linearly still, because the size constraint is still present, but at
> least most of the anon-mmap activities are constant sized. (both malloc()
> and the thread-stack allocator uses mostly fixed sizes.)

Yup.  We'd need to be able to perform a search based on "size of hole"
rather than virtual address.  That really needs a whole new data structure
and supporting search code, I think...  It also may have side effects
to do with fragmentation of the virtual address space.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
