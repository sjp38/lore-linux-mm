Message-Id: <20070418201248.468050288@chello.nl>
Date: Wed, 18 Apr 2007 22:12:48 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/6] concurrent pagecache
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: npiggin@suse.de, akpm@linux-foundation.org, clameter@sgi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

The latest version of the concurrent pagecache work; it goes on top of Nick's
latest lockless pagecache patches.

The biggest change from the previous version is the addition of optimistic
locking. This avoids taking the upper level locks where possible, and
significantly reduces cache-line bouncing and lock contention. Scalability
is now determined by density and number of the elements in the tree.

Radix tree benchmarks on 2 cpus; 2 threads performing modifying operations on 
the same tree. The first series uses separate sequential ranges of the tree.
The second interleaves the same range.

The sequental has minimal shared cache-lines, the interleaved maximal
(in one test one can even see the threads drift apart due to cache-line
bouncing so that they don't share the exact same leaf anymore)

-----

start: 0 end: 800000 intv: 1
start: 800000 end: 1000000 intv: 1

CONFIG_RADIX_TREE_CONCURRENT=n

[ffff81007d7f60c0] insert 0 done in 15286 ms
[ffff810076f16040] insert 0 done in 16250 ms
[ffff81007d7f60c0] tag 0 done in 14401 ms
[ffff810076f16040] tag 0 done in 15420 ms
[ffff81007d7f60c0] untag 0 done in 17868 ms
[ffff810076f16040] untag 0 done in 18251 ms
[ffff81007d7f60c0] tag 1 done in 15331 ms
[ffff810076f16040] tag 1 done in 15287 ms
[ffff81007d7f60c0] untag 1 done in 18342 ms
[ffff810076f16040] untag 1 done in 18092 ms
[ffff81007d7f60c0] remove 0 done in 15412 ms
[ffff810076f16040] remove 0 done in 13802 ms

CONFIG_RADIX_TREE_CONCURRENT=y

[ffff8100587e00c0] insert 0 done in 14750 ms
[ffff8100587e1080] insert 0 done in 14834 ms
[ffff8100587e00c0] tag 0 done in 14489 ms
[ffff8100587e1080] tag 0 done in 14567 ms
[ffff8100587e00c0] untag 0 done in 15016 ms
[ffff8100587e1080] untag 0 done in 15066 ms
[ffff8100587e00c0] tag 1 done in 14593 ms
[ffff8100587e1080] tag 1 done in 14674 ms
[ffff8100587e00c0] untag 1 done in 14984 ms
[ffff8100587e1080] untag 1 done in 15043 ms
[ffff8100587e00c0] remove 0 done in 16307 ms
[ffff8100587e1080] remove 0 done in 16193 ms

CONFIG_RADIX_TREE_OPTIMISTIC=y

[ffff81006b36e040] insert 0 done in 3443 ms
[ffff81006b3620c0] insert 0 done in 3449 ms
[ffff81006b3620c0] tag 0 done in 5338 ms
[ffff81006b36e040] tag 0 done in 5375 ms
[ffff81006b3620c0] untag 0 done in 4107 ms
[ffff81006b36e040] untag 0 done in 4151 ms
[ffff81006b3620c0] tag 1 done in 5349 ms
[ffff81006b36e040] tag 1 done in 5376 ms
[ffff81006b3620c0] untag 1 done in 4110 ms
[ffff81006b36e040] untag 1 done in 4137 ms
[ffff81006b3620c0] remove 0 done in 6482 ms
[ffff81006b36e040] remove 0 done in 6494 ms

levels skipped  hits
        0            8785
        1          544094
        2        34312192
        3        65798168
        4              52
        5               0
        6               0
        7               0
        8               0
        9               0
       10               0
       11               0
failed                232

-----

start: 0 end: 1000000 intv: 2
start: 1 end: 1000000 intv: 2

CONFIG_RADIX_TREE_CONCURRENT=n

[ffff8100679b9080] insert 0 done in 16007 ms
[ffff8100764e40c0] insert 0 done in 16004 ms
[ffff8100679b9080] tag 0 done in 14964 ms
[ffff8100764e40c0] tag 0 done in 15007 ms
[ffff8100679b9080] untag 0 done in 17414 ms
[ffff8100764e40c0] untag 0 done in 17564 ms
[ffff8100679b9080] tag 1 done in 14909 ms
[ffff8100764e40c0] tag 1 done in 15076 ms
[ffff8100679b9080] untag 1 done in 17455 ms
[ffff8100764e40c0] untag 1 done in 17628 ms
[ffff8100679b9080] remove 0 done in 14067 ms
[ffff8100764e40c0] remove 0 done in 14358 ms

CONFIG_RADIX_TREE_CONCURRENT=y

[ffff81006becc0c0] insert 0 done in 19483 ms
[ffff81006bec8080] insert 0 done in 19486 ms
[ffff81006bec8080] tag 0 done in 15604 ms
[ffff81006becc0c0] tag 0 done in 15632 ms
[ffff81006bec8080] untag 0 done in 16952 ms
[ffff81006becc0c0] untag 0 done in 16968 ms
[ffff81006bec8080] tag 1 done in 15444 ms
[ffff81006becc0c0] tag 1 done in 15471 ms
[ffff81006bec8080] untag 1 done in 16996 ms
[ffff81006becc0c0] untag 1 done in 17010 ms
[ffff81006bec8080] remove 0 done in 16145 ms
[ffff81006becc0c0] remove 0 done in 16867 ms

CONFIG_RADIX_TREE_OPTIMISTIC=y

[ffff8100606260c0] insert 0 done in 12036 ms
[ffff810067c20040] insert 0 done in 12033 ms
[ffff810067c20040] tag 0 done in 9438 ms
[ffff8100606260c0] tag 0 done in 9438 ms
[ffff8100606260c0] untag 0 done in 4067 ms
[ffff810067c20040] untag 0 done in 4208 ms
[ffff8100606260c0] tag 1 done in 5424 ms
[ffff810067c20040] tag 1 done in 5368 ms
[ffff8100606260c0] untag 1 done in 4072 ms
[ffff810067c20040] untag 1 done in 4195 ms
[ffff8100606260c0] remove 0 done in 6111 ms
[ffff810067c20040] remove 0 done in 6948 ms

levels skipped  hits
        0            9053
        1          556631
        2        34790358
        3        65307226
        4              74
        5               0
        6               0
        7               0
        8               0
        9               0
       10               0
       11               0
failed                250


-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
