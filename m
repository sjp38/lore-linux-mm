Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0546B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:34:44 -0400 (EDT)
Date: Tue, 7 Sep 2010 15:34:29 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: block cache replacement strategy?
Message-ID: <20100907133429.GB3430@sig21.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

during some simple disk read throughput testing I observed
caching behaviour that doesn't seem right.  The machine
has 2G of RAM and AMD Athlon 4850e, x86_64 kernel but 32bit
userspace, Linux 2.6.35.4.  It seems that contents of the
block cache are not evicted to make room for other blocks.
(Or something like that, I have no real clue about this.)

Since this is a rather artificial test I'm not too worried,
but it looks strange to me so I thought I better report it.


zzz:~# echo 3 >/proc/sys/vm/drop_caches 
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.9454 s, 75.2 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.92799 s, 1.1 GB/s

OK, seems like the blocks are cached. But:

zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.8375 s, 75.8 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.8429 s, 75.7 MB/s

Even if I let 15min pass and repeat the dd command
several times, I cannot see any caching effects, it
stays at ~75 MB/s.

zzz:~# cat /proc/meminfo 
MemTotal:        1793272 kB
MemFree:           15216 kB
Buffers:         1378820 kB
Cached:            20080 kB
SwapCached:            0 kB
Active:           792720 kB
Inactive:         758832 kB
Active(anon):      91716 kB
Inactive(anon):    64652 kB
Active(file):     701004 kB
Inactive(file):   694180 kB

But then:

zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 5.23983 s, 200 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.908284 s, 1.2 GB/s

zzz:~# cat /proc/meminfo 
MemTotal:        1793272 kB
MemFree:           16168 kB
Buffers:         1377308 kB
Cached:            20660 kB
SwapCached:            0 kB
Active:          1140384 kB
Inactive:         410236 kB
Active(anon):      91716 kB
Inactive(anon):    64652 kB
Active(file):    1048668 kB
Inactive(file):   345584 kB


And finally:

zzz:~# echo 3 >/proc/sys/vm/drop_caches
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.948 s, 75.2 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000 skip=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.985031 s, 1.1 GB/s


Now these blocks get cached but then the others don't:

zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.9394 s, 75.2 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.9403 s, 75.2 MB/s


Best Regards,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
