Subject: PATCH: Work in progress cleaning shrink_mmap
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 15 May 2000 05:04:30 +0200
Message-ID: <yttu2g0zf7l.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks

   I have been trying to make it work in my machine the function
shrink_mmap, this version appears to work a bit better that vanilla
(pre9-1) one.  It fails like the vanilla, but it needs more time to
fail.

   I was using the mmap002 test, it freezes the machine always.  This
patch makes it delay the freeze.

   My findings to the moment:        
We end failing in an OOM error, no way to get memory.
As I told you the other day, increasing the SWAP_COUNT and the
FREE_COUNT improves the situation.
In the cleanup I have minimised the number of operations that we
do with the lru_list.  I only put things and the end, and I only
remove/insert pages that change position.

When I am running the tests, I am running in other window
"vmstat 1".  From time to time I get delay (about 3/4 seconds)
for the output of vmstat.  The output of that row doesn't make
any sense at all, one example of output is:

 1  0  1   3716   1596    124  90068   0   0  1599  2248  298   110   1  25  75
 0  1  0   3716   1700    116  89984   0   0  1864  2240  301   118   2  27  71
 0  1  0   3844   1492    348  85340 420 144  1560 88321 6593  4800   0   9  91
                                                   ^^^^^
 1  0  0   3832   1800    296  84140 132   0  3107     0  185   168  14   9  77
 1  0  0   3832    976    224  75888   0   0   796     0  122    78  67  24  10
   procs                      memory    swap          io     system         cpu 
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id

88321 blocks out in one second is a bit high for my IDE disk.

Now the machine appears to reduce the page_cache a bit, when all the
memory is allocated, the page cache begins to reduce (a bit).

Well, that have been my findings to the moment.  Any comments about
the patch of my findings are welcome.

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
