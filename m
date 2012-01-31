Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 097DA6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 17:03:42 -0500 (EST)
Date: Tue, 31 Jan 2012 17:03:33 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131220333.GD4378@redhat.com>
References: <1327996780.21268.42.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327996780.21268.42.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

On Tue, Jan 31, 2012 at 03:59:40PM +0800, Shaohua Li wrote:
> Herbert Poetzl reported a performance regression since 2.6.39. The test
> is a simple dd read, but with big block size. The reason is:
> 
> T1: ra (A, A+128k), (A+128k, A+256k)
> T2: lock_page for page A, submit the 256k
> T3: hit page A+128K, ra (A+256k, A+384). the range isn't submitted
> because of plug and there isn't any lock_page till we hit page A+256k
> because all pages from A to A+256k is in memory
> T4: hit page A+256k, ra (A+384, A+ 512). Because of plug, the range isn't
> submitted again.
> T5: lock_page A+256k, so (A+256k, A+512k) will be submitted. The task is
> waitting for (A+256k, A+512k) finish.
> 
> There is no request to disk in T3 and T4, so readahead pipeline breaks.
> 
> We really don't need block plug for generic_file_aio_read() for buffered
> I/O. The readahead already has plug and has fine grained control when I/O
> should be submitted. Deleting plug for buffered I/O fixes the regression.
> 
> One side effect is plug makes the request size 256k, the size is 128k
> without it. This is because default ra size is 128k and not a reason we
> need plug here.

For me, this patch helps only so much and does not get back all the
performance lost in case of raw disk read. It does improve the throughput
from around 85-90 MB/s to 110-120 MB/s but running the same dd with
iflag=direct, gets me more than 250MB/s.

# echo 3 > /proc/sys/vm/drop_caches 
# dd if=/dev/sdb of=/dev/null bs=1M count=1K
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 9.03305 s, 119 MB/s

echo 3 > /proc/sys/vm/drop_caches 
# dd if=/dev/sdb of=/dev/null bs=1M count=1K iflag=direct
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 4.07426 s, 264 MB/s

I think it is happening because in case of raw read we are submitting
one page at a time to request queue and by the time all the pages
are submitted and one big merged request is formed it wates lot of time.

In case of direct IO, we are getting bigger IOs at request queue so
less cpu overhead, less idling on queue.

I created ext4 filesystem on same SSD and did the buffered read and
that seems to work just fine. Now I am getting bigger requests at
the request queue. (128K, 256 sectors).

[root@chilli common]# echo 3 > /proc/sys/vm/drop_caches 
[root@chilli common]# dd if=zerofile-4G of=/dev/null bs=1M count=1K
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 4.09186 s, 262 MB/s

Anyway, remvoing top level plug in case of buffered reads sounds
reasonable.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
