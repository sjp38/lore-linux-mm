Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id C6240ADCEC
	for <linux-mm@kvack.org>; Sat,  3 Jun 2000 10:54:28 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: vm patch #2 plus
Date: Sat, 3 Jun 2000 10:49:33 -0400
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060310542800.00858@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

after conversing with Rik on kernelnewbies he figured out what was wrong with 
#2.  Then he released he was suposted to be learning another (human) language.
In any case.  This diff applied on top of #2 seems to work well.

---------------------------------------------------------------
--- vmscan.c.orig	Sat Jun  3 09:33:01 2000
+++ vmscan.c	Sat Jun  3 09:37:14 2000
@@ -467,9 +467,10 @@
 			 */
 			count -= shrink_dcache_memory(priority, gfp_mask);
 			count -= shrink_icache_memory(priority, gfp_mask);
-			if (count <= 0)
+			if (count <= 0) {
 				ret = 1;
 				goto done;
+                        } 
 			while (shm_swap(priority, gfp_mask)) {
 				ret = 1;
 				if (!--count)
@@ -487,7 +488,7 @@
 		 * The amount we page out is the amount of pages we're
 		 * short freeing.
 		 */
-		swap_count = count;
+		swap_count += count;
 		while (swap_out(priority, gfp_mask))
 			if (--swap_count < 0)
 				break;
------------------------------------------------------------------

Please wait for Rik to make it offical...

Here are some vmstats with this applied:

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 2  0  0   7320   3212   1412  13988   0   3     5     1  164   775  44  11  45
 8  0  1  11344   3076    504  12764   3  57    11    20  190   964  43  22  35
 4  0  0  11352   6488   1008  17084  17 147   150    37  224  1062  47  14  39
 4  0  0  11352   7260   1136  16260   3  95    11    25  181   920  44   8  48
 2  0  0  17332   5732    840  21380  17  21    79     6  217   898  61  11  28
 3  0  0  17332   4744    948  22312   0   0    16     1  272   788  45   8  47
 1  0  0  17332   4600    968  22620   0   0     5     0  200   669  40   7  53
 4  0  0  17308   2824   1476  23460   2   4    52     5  262  1141  46   8  46
 3  0  0  17380   2600   1604  23344   1 396    30    99  211  1155  53   9  38
 1  0  0  17308   4376   1556  18380   6   0    10     2  155   889  47   8  44
 2  0  0  17308   8036   1580  18536   1   0     3     0  159   888  46   6  48
 3  0  0  17308   7660   1628  18856   0   0     5     4  159   744  43   7  50
 7  0  0  17308   4272   1688  21348  28   0    43     0  192  1229  57   7  36

System remains responsive, mp3s do not jump, all in all nice perf here.

Luck,

Ed Tomlinson <tomlins@cam.org>
http://www.cam.org/~tomlins/njpipes.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
