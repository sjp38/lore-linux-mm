Message-ID: <40CFBB75.1010702@yahoo.com.au>
Date: Wed, 16 Jun 2004 13:16:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
References: <20040608142918.GA7311@traveler.cistron.net> <40CAA904.8080305@yahoo.com.au> <20040614140642.GE13422@traveler.cistron.net> <40CE66EE.8090903@yahoo.com.au> <20040615143159.GQ19271@traveler.cistron.net>
In-Reply-To: <20040615143159.GQ19271@traveler.cistron.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miquel van Smoorenburg wrote:
> According to Nick Piggin:
> 
>>Miquel van Smoorenburg wrote:
>>
>>>
>>>The patch below indeed fixes this problem. Now most of the mmap'ed files
>>>are actually kept in memory and RSS is around 600 MB again:
>>
>>OK good. Cc'ing Andrew.
> 
> 
> I've built a small test app that creates the same I/O pattern and ran it
> on 2.6.6, 2.6.7-rc3 and 2.6.7-rc3+patch and running that confirms it,
> though not as dramatically as the real-life application.
> 

Can you send the test app over?
Andrew, do you have any ideas about how to fix this so far?

> 
> 
> Now something else that is weird, but might be unrelated and I have
> not found a way to reproduce it on a different machine yet, so feel
> free to ignore it, I'm just mentioning it in case someone reckognizes
> this.
> 
> The news server process uses /dev/hd[cdg]1 directly for storage
> (Cyclic News File System). There's about 12 MB/sec incoming
> being stored on those 3 (SATA) disks. Look at the vmstat output:
> 
> # vmstat 2
> procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
>  4  0  22664   5216 277332 496644   28    0  8143    36 9785  2162 12 43 28 16
>  1  3  22660 231252  71808 488580   16    0  5947 33856 8868  1633  9 60 11 20
>  2  2  22660 273972  40988 489508    0    0  8895 21144 8875  1931 10 43 21 27
>  3  0  22660 236412  73620 491148    0    0 10774 10551 9877  1937 10 44 24 22
>  1  1  22660 185112 104112 492616    0    0  9677 12354 10216  1863 10 44 28 19
>  2  0  22660 148700 138388 494108    0    0 10227 13919 9976  1925 11 44 24 21
>  0  2  22660 123432 162032 495012    0    0  6244 15418 10065  1793 11 46 28 16
>  3  0  22660  93096 190452 496292    8    0  6548 10293 9860  1975 11 43 31 15
>  2  0  22660  51688 218628 497424    0    0  6405    52 10575  2063 13 48 27 12
>  3  1  22660  19012 245632 499032    8    0  8108 12400 10136  1892 11 44 24 21
>  2  1  22660 249192  42956 490932    0    0  8231 33005 9109  1343 10 60 13 18
>  0  1  22660 240396  53764 491956    0    0 10082 18625 9504  1740 10 47 24 19
>  2  2  22660 205632  86108 493408    0    0  8305 12368 8941  1775  8 33 32 26
>  0  2  22660 164672 119156 494972    0    0  6867    62 9695  1894 11 40 31 18
>  1  3  22660 137924 144964 496568    0    0  7099 16440 10388  1878 11 47 26 17
>  1  1  22660 101604 176936 498052    0    0  9166 12332 10237  1694 12 44 28 16
>  2  1  22660  67816 205376 499176    8    0  6169  6158 9906  1897 11 44 31 15
>  1  1  22660  28004 236520 500652   10    0  7418  6202 10289  1744 12 44 30 14
>  2  1  22660   7484 259156 492544   12    0  7494 18540 10218  1757 11 49 21 19
>  1  4  22660  61664 228360 494004   72    0  6131 14412 9611  2437 10 46 20 23
>  3  1  22660  76976 242652 498884   36    0  6927 16558 7560  2219 18 42 13 27
>  0  1  22660  62352 267840 501140   14    0  7358 10424 8273  2601 11 32 33 23
>  1  1  22660   6880 301056 502528    4    0 11045  2304 10177  2137 12 42 26 20
>  0  4  22660 280848  40856 494196    0    0  6583 45092 9379  1505  9 61 13
> 
> See how "cache" remains stable, but free/buffers memory is oscillating?
> That shouldn't happen, right ? 
> 

If it is doing IO to large regions of mapped memory, the page reclaim
can start getting a bit chunky. Not much you can do about it, but it
shouldn't do any harm.

> I tried to reproduce it on another 2.6.7-rc3 system with
> while :; do dd if=/dev/zero of=/dev/sda8 bs=1M count=10; sleep 1; done
> and while I did see it oscillating once or twice after that it
> remained stable (buffers high / free memory low) and I can't seem
> to be able to reproduce it again.
> 

Probably because it isn't doing mmapped IO.

> Yesterday I ported my rawfs module over to 2.6. It's a minimal filesystem that
> shows a blockdevice as a single large file. I'm letting the newsserver access
> that instead of the blockdevice directly so all access goes through the
> pagecache instead of the buffer cache and that runs much more smoothly, though
> it's harder to tune 'swappiness' with it - it seems to be much more "all
> or nothing" in that case. Anyway that's what I'm using now.
> 

In 2.6, everything basically should go through the same path I think,
so it really shouldn't make much difference.

The fact that swappiness stops having any effect sounds like the server
switched from doing mapped IO to read/write. Maybe I'm crazy... could
you verify?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
