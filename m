Message-ID: <3A62C5F0.80C0E8B5@sw.com.sg>
Date: Mon, 15 Jan 2001 17:42:08 +0800
Content-Class: urn:content-classes:message
From: "Vlad Bolkhovitine" <vladb@sw.com.sg>
MIME-Version: 1.0
Subject: Re: mmap()/VM problems in 2.4.0
References: <3A5EFB40.6080B6F3@sw.com.sg>
Content-Type: text/plain;
	charset="koi8-r"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is updated info for 2.4.1pre3:

Size is MB, BlkSz is Bytes, Read, Write, and Seeks are MB/sec

with mmap()

 File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
 Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
------- ------ ------- --- ----------- ----------- ----------- -----------
   .     1024   4096    2  1.089 1.24% 0.235 0.45% 1.118 4.11% 0.616 1.41%

without mmap()
   
 File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
 Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
------- ------ ------- --- ----------- ----------- ----------- -----------
   .     1024   4096    2  28.41 41.0% 0.547 1.15% 13.16 16.1% 0.652 1.46%


Mmap() performance dropped dramatically down to almost unusable level. Plus,
system was unusable during test: "vmstat 1" updated results every 1-2 _MINUTES_!

Problem one (impossible to run tiobench without swap) is still here with the
only difference that tiobench gets killed faster (just after start).

Regards,
Vlad

P.S. Sorry for overquoting, I hope it could be helpful for linux-mm subscribers.

Vlad Bolkhovitine wrote:
> 
> After upgrade from 2.4.0-test7 to 2.4.0 while running tiotest v0.3.1 I found two
> following problems.
> 
> 1. Tiotest is compiled for mmap() usage and there is no swap on the system with
> ~200Mb free memory. Tiotest tries to create mmap'ed file with size
> ~memory_size*2 and soon after start gets killed by OOM killer. If I add swap
> space, the kernel uses only a few Mb from it.
> 
> AFAIU, it is because out_of_memory() in oom_kill.c checks for amount swap space
> left, which is always 0 without swap. Apparently, it is not correct for
> "no-swap" systems.
> 
> 2. Second problem is related to mmap() performance.
> 
> I ran "./tiobench.pl --size 1024 --threads 2", which is translated to
> "./tiotest -t 2 -f 512 -r 2000 -b 4096 -d . -T", with tiotest compiled for
> mmap() and for conventional read()/write() usage on 2.4.0-test7 and 2.4.0. These
> are results:
> 
> Size is MB, BlkSz is Bytes, Read, Write, and Seeks are MB/sec
> 
> 2.4.0-test7 with mmap()
> 
> File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
> Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  22.44 14.7% 0.456 0.78% 10.66 22.5% 0.733 1.87%
> 
> 2.4.0 with mmap()
> 
> File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
> Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  12.53 9.02% 0.489 1.16% 10.82 15.3% 0.640 1.14%
> 
> 2.4.0-test7 without mmap()
> 
> File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
> Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  14.20 17.6% 0.502 1.28% 12.85 15.1% 0.643 1.31%
> 
> 2.4.0 without mmap()
> 
> File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
> Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  28.41 42.1% 0.541 1.35% 13.16 16.8% 0.645 1.52%
> 
> You can see, mmap() read performance dropped significantly as well as read() one
> raised. Plus, "interactivity" of 2.4.0 system was much worse during mmap'ed
> test, than using read() (everything was quite smooth here). 2.4.0-test7 was
> badly interactive in both cases.
> 
> I use /dev/hdc on IDE channel 2 for tests and /dev/hda IDE channel 2 for swap.
> hdparam output for both drives:
> 
>  multcount    =  0 (off)
>  I/O support  =  0 (default 16-bit)
>  unmaskirq    =  0 (off)
>  using_dma    =  1 (on)
>  keepsettings =  0 (off)
>  nowerr       =  0 (off)
>  readonly     =  0 (off)
>  readahead    =  8 (on)
> 
> 2.4.0 and 2.4.0-test7 were compiled with one .config via "make oldconfig".
> .config and dmesg you can find in the attachment.
> 
> Any comments?
> 
> Regards,
> Vlad
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
