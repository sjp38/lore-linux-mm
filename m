From: Michal Ostrowski <mostrows@styx.uwaterloo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14645.55430.196015.898700@styx.uwaterloo.ca>
Date: Wed, 31 May 2000 23:29:10 -0400 (EDT)
Subject: Poor I/O Performance (10x slower than 2.2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I've noticed some horrible I/O performance in recent 2.3 kernels.  My
first guess was that this was related to the various VM problems that
have been running rampant recently, but now I'm not so sure.  Even
though I've been reading reports that VM performance has been
improving, I've seen no noticeable impact on my test results.

My test program performs a series of reads at random offests into a 1
GB sized file (on an ext2 fs).  There are 1000 reads in total, and
each read operations reads some pre-determined number of blocks.  The
application uses 1,4 or 10 kernel threads to perform this task.  The
threads all quit once the total number of reads between all of them
reaches 1000 and the time to run the application is reported.

I've run this application on several combinations of kernels and
hardware.  The hardware was a Celeron 500 or Dual PIII 550's with
7200RPM U2W SCSI drives (aic7880/aic7890 controllers) and 256 MB RAM.

The kernels I've used have varied from 2.3.99-pre1 to 2.4.0-test1-ac7,
however the kernel version used seems to have little impact on the
overall results.

The numbers I find really troublesome are the ones where I've got 10
threads and 32 blocks per read.  What makes this case troublesome is
that I've seen a 2.2.14 kernel (on the dual processor box) run the
test with the same parameters in 34 seconds (as opposed to 340).
Regardless of how unrealistic my test application is, I don't think
that such a change in running time between 2.2.14 and 2.3.99-pre9 is
intentional.

My concern is that the running times increase so dramatically as the
number of blocks read per read operations increases, and that
increasing the number of threads has such a dramatically negative
impact.



		Celeron 500    Dual PIII 550
		test1-ac7      2.3.99-pre9

Threads Blocks	Time To Complete 1000 Reads (seconds)
	per		
	Read

1	4	7.6	       18.2  
1	8	9.9	       21.6
1	16	21.0	       28.5
1	32	22.0	       32.3

4	4	8.2	       17.3
4	8	9.1	       19.7
4	16	15.2	       21.1
4	32	20.2	       28.5

10	4       6.4	       7.6
10	8       6.9	       9.4
10	12      9.0
10	13      96.9
10	16      114	       223
10	32      290	       345 *


* 2.2.14 runs this test in 34 seconds.


Michal Ostrowski
mostrows@styx.uwaterloo.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
