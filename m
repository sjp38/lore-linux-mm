Subject: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
From: Mary Edie Meredith <maryedie@osdl.org>
Reply-To: maryedie@osdl.org
Content-Type: text/plain
Message-Id: <1079130684.2961.134.camel@localhost>
Mime-Version: 1.0
Date: Fri, 12 Mar 2004 14:31:25 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mary Edie Meredith <maryedie@osdl.org>
List-ID: <linux-mm.kvack.org>

For the last few mm kernels, I have discovered a
performance problem in DBT-3 (using PostgreSQL) 
in the "throughput" portion of the test (when the
test is running multiple processes ) on our 8-way
STP systems as compared to 4-way runs and the baseline
kernel results.

Using the default DBT-3 options (ie using LVM, ext2, 
PostgreSQL version 7.4.1) on RH9 for 2.6.4-mm1 (PLM 2745)
[Note that the 4-way number is _better than the 8-way 
number]

2.6.4-mm1
Runid..CPUs.Thruput (bigger is better) 
289860 8    86.5<-----------(profiling data below)
289831 4    112.7
 
Compare to base:  
linux-2.6.4
Runid..CPUs.Thruput 
289421 8    137.2<----------
289383 4    120.73

DBT-3 is a read mostly DSS workload and the throughput 
phase  is where we run multiple query streams (as 
many as we have CPUs).  In this workload, the database 
is stored on a file system and it almost completely 
caches in page cache early on. So there is not a lot 
of physical IO in the throughput portion of the test. 

I also found similar 8way thruput numbers on these 
mm kernels:

Kernel........PLM..Thruput 
2.6.4rc2-mm1  2676  84.56
2.6.4rc1-mm2  2666  85.54
2.6.4rc1-mm1  2664  85.73


Before the 2.6.3-mm4 kernel, the test we are running
now (with LVM and pgsql 7.4.1 was not available) so 
results are not availablewithout running them manually.  
I did run 2.6.1-mm5and it had a thruput result of 124.02 
on an 8way. Still not great but definitely better 
than ~86.0.

I just wanted to report this and I wonder if you already
know why this is happening.


--------------------------------------------------
Profiling data from RUNID 289860 sorted first by 
ticks, second by load:
http://khack.osdl.org/stp/289860/profile/Framework_Close-tick.sort
http://khack.osdl.org/stp/289860/profile/Framework_Close-load.sort
-- 
Mary Edie Meredith 
maryedie@osdl.org
503-626-2455 x42
Open Source Development Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
