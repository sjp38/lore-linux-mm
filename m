Content-Type: text/plain;
  charset="iso-8859-1"
From: Rene Herman <rene.herman@keyaccess.nl>
Subject: VM trouble, both 2.4 and 2.5
Date: Fri, 15 Nov 2002 23:21:32 +0100
MIME-Version: 1.0
Message-Id: <02111521422000.00195@7ixe4>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@digeo.com>, Con Kolivas <contest@kolivas.net>
List-ID: <linux-mm.kvack.org>

Hi Andrew, all ...

All of 2.4.19, 2.4.19-rmap14b, 2.5.47 and 2.5.47-mm3 would appear to have a 
problem reclaiming memory. On all of these kernels a "dd" with a large 
blocksize "misplaces memory" here:

rene@7ixe4:~$ cat /proc/sys/vm/overcommit_memory
0

rene@7ixe4:~$ cat /proc/meminfo
MemTotal:       776156 kB
MemFree:        667416 kB
MemShared:           0 kB
Buffers:          7088 kB
Cached:          61564 kB
SwapCached:          0 kB
Active:          41652 kB
Inactive:        46584 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       776156 kB
LowFree:        667416 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:             104 kB
Writeback:           0 kB
Mapped:          34224 kB
Slab:             6068 kB
Committed_AS:    34864 kB
PageTables:        668 kB
ReverseMaps:     31359

rene@7ixe4:~$ dd if=/dev/zero of=/tmp/zero bs=512M count=1
1+0 records in
1+0 records out

rene@7ixe4:~$ dd if=/dev/zero of=/tmp/zero bs=512M count=1
dd: memory exhausted

rene@7ixe4:~$ cat /proc/meminfo
MemTotal:       776156 kB
MemFree:        412112 kB
MemShared:           0 kB
Buffers:          7668 kB
Cached:          61564 kB
SwapCached:          0 kB
Active:          42168 kB
Inactive:       296572 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       776156 kB
LowFree:        412112 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:             440 kB
Writeback:           0 kB
Mapped:          34228 kB
Slab:            10932 kB
Committed_AS:    34868 kB
PageTables:        668 kB
ReverseMaps:     31360

The first dd above ate some 250M (that number varies wildly, I have also seen 
it eat 400M and more, and sometimes significantly less, making the second dd 
still succeed but in that case the third or fourth dies) that /proc/meminfo 
only accounts under Inactive and then the second "dd" fails to allocate its 
buffer (bs=512M large) and exits with "memory exhausted". You can continue 
this process, choosing a smaller bs= each time (< MemFree), until allmost all 
memory is under "Inactive" and every non-tiny allocation fails.

Note: the above is without any swap enabled to show the problem more clearly, 
but it also happens with swap.

The real fun bit is that you can now get your memory back (putting it back in 
"Cached" where I guess it should have been in the first place?) by doing 
something like "ls -lR /". Upon hearing that, Rik van Riel noted that that 
probably meant that setting overcommit_memory=1 would be a work around for 
the problem and indeed it is. If you after having "run out" of memory in this 
way set overcommit_memory=1 and repeat the "dd"s, now giving a bs= that's 
slightly *larger* than MemFree each time, you can move everything back from 
Inactive to Cached in the same way as with the "ls -lR /".

dd allocates a buffer with size bs= (ie, large) to read/write from. Without 
overcommit, the system fails the allocation because it believes not enough 
memory is available (everything is under "Inactive"). With overcommit 
enabled, I assume the buffer is faulted in one or a few pages at a time. The 
"ls -lR" probably does many small allocations so it seems that those small 
allocations are what fix things up again.

I asked around (on IRC) if others were also seeing this behaviour and they 
were not. I assume though that they had overcommit enabled, which then masks 
the problem, since I can reproduce this completely consistently, as said on 
all of 2.4.19, 2.4.19-rmap14b, 2.5.47 and 2.5.47-mm3. To rule out GCC issues 
(my normal compiler is gcc-3.2) I also tried it with a gcc-2.95.3 compiled 
2.4.19. They all behave as described above.

Maybe significant (?): does *not* happen with of=/dev/null. Does happen both 
with ext2 and ext3 on /tmp.

Any and all comments much appreciated. And if anyone wants me to test out 
something else or more, please say so...

Rene.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
