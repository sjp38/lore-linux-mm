From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004090020.RAA19783@google.engr.sgi.com>
Subject: Re: zap_page_range(): TLB flush race
Date: Sat, 8 Apr 2000 17:20:29 -0700 (PDT)
In-Reply-To: <200004082344.QAA02536@pizda.ninka.net> from "David S. Miller" at Apr 08, 2000 04:44:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: manfreds@colorfullife.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
>    > filemap_sync() calls flush_tlb_page() for each page, but IMHO this is a
>    > really bad idea, the performance will suck with multi-threaded apps on
>    > SMP.
> 
>    The best you can do probably is a flush_tlb_range?
> 
> People, look at the callers of filemap_sync, it does range tlb/cache
> flushes so the flushes in filemap_sync_pte() are in fact spurious.
> 
> Later,
> David S. Miller
> davem@redhat.com
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

Hehehe ... now I am just arguing for the sake of arguing :-)

Let me give an example. I write a program with 2 threads, C1 and
C2, which mmap a file MAP_SHARED, and both write to it, with the 
understanding that when they unmap it, all their previous writes will
be synced to disk. Okay, so C1 goes ahead and unmaps it, C2 thinks
"let me write to a page. If I don't get a signal indicating illegal
access, that means the write will show up on disk later. If I do 
get a signal, I know the file has been unmapped, hence the write
will never make it to disk, so I need to take some recovery action".

Okay, so is this a good program? (May be not, they should probably
have synchronized the unmapping between themselves, but C2's 
assumptions are not wrong).

If this is indeed a good program, you want to freeze C2's access
to the pages as soon as the unmap starts. We don't have a freeze
operation, the best next we can do is to flush the tlb as close 
as possible to clearing the pte, which makes it really difficult
for C2 to drag in a tlb entry and continue writes that will not 
be synced to disk.

So, though the filemap_sync_pte()s are theoretically unneeded, 
they might actually be reducing a race ...

While on this topic, shouldn't filemap_unmap() invoke

filemap_sync(vma, start, len, MS_ASYNC|MS_INVALIDATE);

rather than 

filemap_sync(vma, start, len, MS_ASYNC);

Not that the MS_ASYNC part makes much difference ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
