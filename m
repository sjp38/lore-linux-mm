Received: from anaconda.ics.ele.tue.nl (anaconda.ics.ele.tue.nl [131.155.40.37])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA32504
	for <linux-mm@kvack.org>; Sun, 3 Jan 1999 02:08:51 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Date: Sat,  2 Jan 1999 23:14:55 -0800 (PST)
From: Raymond Nijssen <rxtn@gte.net>
Subject: work around 1GB heap size limit
Message-ID: <13965.22214.171983.180152@woensel.ics.ele.tue.nl>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Folks,

I was wondering if there exists a general way to work around the maximum heap
size limit of 1 GB on Linux.  (at least on the x86 platforms).

The virtual memory segmentation is as follows:

0xc0000000 - 0xffffffff : kernel memory
min_stack  - 0xc0000000 : user stack                      -- grows downward
max_mmap   - min_stack  : free
0x40000000 - max_mmap   : mapped (mmap, shared mem/libs)  -- grows upward
'brk'      - 0x40000000 : free
`end'      - 'brk'      : heap                            -- grows upward
0x00000000 - 'end'      : text, bss, etc.

where `end' > 0x08000000 typically (fixed at load-time)
and max_stack =  0xc0000000 - 8MB by default. (fixed at load-time)


The limitations of this map are:
1. the effective heap size of about only 0.8 GB.  This is insufficient for
   large processes.  Even on WNT you get effectively about twice that,
   and it is not enough either.  Solaris/SPARC provides 3.75GB user vm.
2. the largest file that can possibly be mapped would be about 1.9 GB.
   (in practice even less due to fragmentation after a while)
3. the initial segmentation already establishes a rigid fragmentation.


The proposal is really whether it would be possible to make the mappable
region start at  max_stack  and to make it grow downward.
This scheme likens the approach used in Solaris/SPARC.  (dunno about 
Solaris/x86).

The proposed segmentation looks like:

0xc0000000 - 0xffffffff : kernel memory
min_stack  - 0xc0000000 : user stack                      -- grows downward
MIN_mmap   - min_stack  : mapped (mmap, shared mem/libs)  -- grows DOWNward
'brk'      - MIN_mmap   : free
`end'      - 'brk'      : heap                            -- grows upward
0x00000000 - 'end'      : text, bss, etc.



The advantages are:

1. the effective maximum heap size would be more than 2.5GB.
2. the effective maximum mappable file size would be more than 2.5GB.
   (obviously heap + mapped cannot exceed  3GB - end - stacksize as
   long as the kernel space is 3GB as usual)
3. reduced probability that a request cannot be satisfied due to fragmentation
   because the freedom to select a vm interval is increased.


After doing some kernel source browsing, it seems to me that these changes
should be relatively easy to make.

The reason why I haven't tried it until now is that with this kind of stuff
there are always quite a few less obvious dependencies.
And of course this may have been tried before.

Comments?

-Raymond

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
