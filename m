From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907281807.LAA14534@google.engr.sgi.com>
Subject: Re: active_mm & SMP & TLB flush: possible bug
Date: Wed, 28 Jul 1999 11:07:30 -0700 (PDT)
In-Reply-To: <379EF7D0.375C78A4@colorfullife.com> from "Manfred Spraul" at Jul 28, 99 02:30:08 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: masp0008@stud.uni-sb.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> BTW, where can I find more details about the active_mm implementation?
> specifically, I'd like to know why active_mm was added to
> "struct task_struct".

That goes for a lot of other changes in 2.3 - unfortunately, there
seems to be no concept of release notes etc, that provide one liner
descriptions of the changes being put into a release. 

In this case at least, the concept of "active_mm" reduces tlb flushes
when switching *to* a kernel thread, since a kernel thread has no 
user level translations, and can use the kernel-level translations
of the previous thread. set_mmu_context updates the task.cr3, which
is checked in __switch_to, and since the cr3 update is skipped, the 
tlb's are not flushed.

> >From my first impression, it's a CPU specific information
> (every CPU has exactly one active_mm, threads which are not running have
> no
> active_mm), so I'd have used a global array[NR_CPUS].

Umm, really? My reading of the code was that all kernel threads and
exitted user threads had no "mm", and had an "active_mm" only while
executing on the cpu. Other user threads with user level translations
always have an "mm" and "active_mm". 

Kanoj

> 
> 
> 	Manfred
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
