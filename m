Subject: Re: mmap()/VM problems in 2.4.0
References: <3A5EFB40.6080B6F3@sw.com.sg> <3A62C5F0.80C0E8B5@sw.com.sg>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 15 Jan 2001 21:31:56 +0100
In-Reply-To: "Vlad Bolkhovitine"'s message of "Mon, 15 Jan 2001 17:42:08 +0800"
Message-ID: <87hf30d0ar.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vlad Bolkhovitine <vladb@sw.com.sg>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Vlad Bolkhovitine" <vladb@sw.com.sg> writes:

> Here is updated info for 2.4.1pre3:
> 
> Size is MB, BlkSz is Bytes, Read, Write, and Seeks are MB/sec
> 
> with mmap()
> 
>  File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
>  Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  1.089 1.24% 0.235 0.45% 1.118 4.11% 0.616 1.41%
> 
> without mmap()
>    
>  File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
>  Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  28.41 41.0% 0.547 1.15% 13.16 16.1% 0.652 1.46%
> 
> 
> Mmap() performance dropped dramatically down to almost unusable level. Plus,
> system was unusable during test: "vmstat 1" updated results every 1-2 _MINUTES_!
> 

You need Marcelo's patch. Please apply and retest.



--- linux.orig/mm/vmscan.c      Mon Jan 15 02:33:15 2001
+++ linux/mm/vmscan.c   Mon Jan 15 02:46:25 2001
@@ -153,7 +153,7 @@

                        if (VALID_PAGE(page) && !PageReserved(page)) {
                                try_to_swap_out(mm, vma, address, pte,
page);
-                               if (--count)
+                               if (!--count)
                                        break;
                        }
                }


-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
