Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CCD686B00D9
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 22:20:33 -0400 (EDT)
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <20101006123753.GA17674@localhost>
References: <20101005185725.088808842@linux.com>
	 <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
	 <20101006123753.GA17674@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Oct 2010 10:21:12 +0800
Message-ID: <1286936472.31597.50.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-10-06 at 20:37 +0800, Wu, Fengguang wrote:
> [add CC to Alex: he is now in charge of kernel performance tests]
> 

I got the code from
git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git unified
on branch "origin/unified" and do a patch base on 36-rc7 kernel. Then I
tested the patch on our 2P/4P core2 machines and 2P NHM, 2P WSM
machines. Most of benchmark have no clear improvement or regression. The
testing benchmarks is listed here.
http://kernel-perf.sourceforge.net/about_tests.php 


But the following results worth to care: 
1, netperf loopback testing has a little improvement.
2, hackbench process testing has about 10% regression on both Core2
machine
3, fio testing has about 10~20% regression on mmap rand read testing. on
our raw mode JBOD that attached on NHM and WSM machine. The JBOD use
We use "numactl --interleave all " to do fio testing. one of testing
file as below:
=============
[global]
direct=0
ioengine=mmap
size=8G
bs=4k
numjobs=1
loops=5
runtime=600
group_reporting
invalidate=0
directory=/mnt/stp/fiodata
file_service_type=random:36

[job_sdb1_sub0]
startdelay=0
rw=randread
filename=data0/f1:data0/f2:data0/f3:data0/f4:data0/f5:data0/f6:data0/f7:data0/f8

[job_sdb1_sub1]
startdelay=0
rw=randread
filename=data0/f2:data0/f3:data0/f4:data0/f5:data0/f6:data0/f7:data0/f8:data0/f1

[job_sdb1_sub2]
startdelay=0
rw=randread
filename=data0/f3:data0/f4:data0/f5:data0/f6:data0/f7:data0/f8:data0/f1:data0/f2

[job_sdb1_sub3]
startdelay=0
rw=randread
filename=data0/f4:data0/f5:data0/f6:data0/f7:data0/f8:data0/f1:data0/f2:data0/f3

[job_sdb1_sub4]
startdelay=0
rw=randread
filename=data0/f5:data0/f6:data0/f7:data0/f8:data0/f1:data0/f2:data0/f3:data0/f4

[job_sdb1_sub5]
startdelay=0
rw=randread
filename=data0/f6:data0/f7:data0/f8:data0/f1:data0/f2:data0/f3:data0/f4:data0/f5

[job_sdb1_sub6]
startdelay=0
rw=randread
filename=data0/f7:data0/f8:data0/f1:data0/f2:data0/f3:data0/f4:data0/f5:data0/f6

[job_sdb1_sub7]
startdelay=0
rw=randread
filename=data0/f8:data0/f1:data0/f2:data0/f3:data0/f4:data0/f5:data0/f6:data0/f7

[job_sdb2_sub0]
startdelay=0
rw=randread
filename=data1/f1:data1/f2:data1/f3:data1/f4:data1/f5:data1/f6:data1/f7:data1/f8

[job_sdb2_sub1]
startdelay=0
rw=randread
filename=data1/f2:data1/f3:data1/f4:data1/f5:data1/f6:data1/f7:data1/f8:data1/f1

[job_sdb2_sub2]
startdelay=0
rw=randread
filename=data1/f3:data1/f4:data1/f5:data1/f6:data1/f7:data1/f8:data1/f1:data1/f2

[job_sdb2_sub3]
startdelay=0
rw=randread
filename=data1/f4:data1/f5:data1/f6:data1/f7:data1/f8:data1/f1:data1/f2:data1/f3

[job_sdb2_sub4]
startdelay=0
rw=randread
filename=data1/f5:data1/f6:data1/f7:data1/f8:data1/f1:data1/f2:data1/f3:data1/f4

[job_sdb2_sub5]
startdelay=0
rw=randread
filename=data1/f6:data1/f7:data1/f8:data1/f1:data1/f2:data1/f3:data1/f4:data1/f5

[job_sdb2_sub6]
startdelay=0
rw=randread
filename=data1/f7:data1/f8:data1/f1:data1/f2:data1/f3:data1/f4:data1/f5:data1/f6

[job_sdb2_sub7]
startdelay=0
rw=randread
filename=data1/f8:data1/f1:data1/f2:data1/f3:data1/f4:data1/f5:data1/f6:data1/f7

[job_sdc1_sub0]
startdelay=0
rw=randread
filename=data2/f1:data2/f2:data2/f3:data2/f4:data2/f5:data2/f6:data2/f7:data2/f8

[job_sdc1_sub1]
startdelay=0
rw=randread
filename=data2/f2:data2/f3:data2/f4:data2/f5:data2/f6:data2/f7:data2/f8:data2/f1

[job_sdc1_sub2]
startdelay=0
rw=randread
filename=data2/f3:data2/f4:data2/f5:data2/f6:data2/f7:data2/f8:data2/f1:data2/f2

[job_sdc1_sub3]
startdelay=0
rw=randread
filename=data2/f4:data2/f5:data2/f6:data2/f7:data2/f8:data2/f1:data2/f2:data2/f3

[job_sdc1_sub4]
startdelay=0
rw=randread
filename=data2/f5:data2/f6:data2/f7:data2/f8:data2/f1:data2/f2:data2/f3:data2/f4

[job_sdc1_sub5]
startdelay=0
rw=randread
filename=data2/f6:data2/f7:data2/f8:data2/f1:data2/f2:data2/f3:data2/f4:data2/f5

[job_sdc1_sub6]
startdelay=0
rw=randread
filename=data2/f7:data2/f8:data2/f1:data2/f2:data2/f3:data2/f4:data2/f5:data2/f6

[job_sdc1_sub7]
startdelay=0
rw=randread
filename=data2/f8:data2/f1:data2/f2:data2/f3:data2/f4:data2/f5:data2/f6:data2/f7

[job_sdc2_sub0]
startdelay=0
rw=randread
filename=data3/f1:data3/f2:data3/f3:data3/f4:data3/f5:data3/f6:data3/f7:data3/f8

[job_sdc2_sub1]
startdelay=0
rw=randread
filename=data3/f2:data3/f3:data3/f4:data3/f5:data3/f6:data3/f7:data3/f8:data3/f1

[job_sdc2_sub2]
startdelay=0
rw=randread
filename=data3/f3:data3/f4:data3/f5:data3/f6:data3/f7:data3/f8:data3/f1:data3/f2

[job_sdc2_sub3]
startdelay=0
rw=randread
filename=data3/f4:data3/f5:data3/f6:data3/f7:data3/f8:data3/f1:data3/f2:data3/f3

[job_sdc2_sub4]
startdelay=0
rw=randread
filename=data3/f5:data3/f6:data3/f7:data3/f8:data3/f1:data3/f2:data3/f3:data3/f4

[job_sdc2_sub5]
startdelay=0
rw=randread
filename=data3/f6:data3/f7:data3/f8:data3/f1:data3/f2:data3/f3:data3/f4:data3/f5

[job_sdc2_sub6]
startdelay=0
rw=randread
filename=data3/f7:data3/f8:data3/f1:data3/f2:data3/f3:data3/f4:data3/f5:data3/f6

[job_sdc2_sub7]
startdelay=0
rw=randread
filename=data3/f8:data3/f1:data3/f2:data3/f3:data3/f4:data3/f5:data3/f6:data3/f7

[job_sdd1_sub0]
startdelay=0
rw=randread
filename=data4/f1:data4/f2:data4/f3:data4/f4:data4/f5:data4/f6:data4/f7:data4/f8

[job_sdd1_sub1]
startdelay=0
rw=randread
filename=data4/f2:data4/f3:data4/f4:data4/f5:data4/f6:data4/f7:data4/f8:data4/f1

[job_sdd1_sub2]
startdelay=0
rw=randread
filename=data4/f3:data4/f4:data4/f5:data4/f6:data4/f7:data4/f8:data4/f1:data4/f2

[job_sdd1_sub3]
startdelay=0
rw=randread
filename=data4/f4:data4/f5:data4/f6:data4/f7:data4/f8:data4/f1:data4/f2:data4/f3

[job_sdd1_sub4]
startdelay=0
rw=randread
filename=data4/f5:data4/f6:data4/f7:data4/f8:data4/f1:data4/f2:data4/f3:data4/f4

[job_sdd1_sub5]
startdelay=0
rw=randread
filename=data4/f6:data4/f7:data4/f8:data4/f1:data4/f2:data4/f3:data4/f4:data4/f5

[job_sdd1_sub6]
startdelay=0
rw=randread
filename=data4/f7:data4/f8:data4/f1:data4/f2:data4/f3:data4/f4:data4/f5:data4/f6

[job_sdd1_sub7]
startdelay=0
rw=randread
filename=data4/f8:data4/f1:data4/f2:data4/f3:data4/f4:data4/f5:data4/f6:data4/f7

[job_sdd2_sub0]
startdelay=0
rw=randread
filename=data5/f1:data5/f2:data5/f3:data5/f4:data5/f5:data5/f6:data5/f7:data5/f8

[job_sdd2_sub1]
startdelay=0
rw=randread
filename=data5/f2:data5/f3:data5/f4:data5/f5:data5/f6:data5/f7:data5/f8:data5/f1

[job_sdd2_sub2]
startdelay=0
rw=randread
filename=data5/f3:data5/f4:data5/f5:data5/f6:data5/f7:data5/f8:data5/f1:data5/f2

[job_sdd2_sub3]
startdelay=0
rw=randread
filename=data5/f4:data5/f5:data5/f6:data5/f7:data5/f8:data5/f1:data5/f2:data5/f3

[job_sdd2_sub4]
startdelay=0
rw=randread
filename=data5/f5:data5/f6:data5/f7:data5/f8:data5/f1:data5/f2:data5/f3:data5/f4

[job_sdd2_sub5]
startdelay=0
rw=randread
filename=data5/f6:data5/f7:data5/f8:data5/f1:data5/f2:data5/f3:data5/f4:data5/f5

[job_sdd2_sub6]
startdelay=0
rw=randread
filename=data5/f7:data5/f8:data5/f1:data5/f2:data5/f3:data5/f4:data5/f5:data5/f6

[job_sdd2_sub7]
startdelay=0
rw=randread
filename=data5/f8:data5/f1:data5/f2:data5/f3:data5/f4:data5/f5:data5/f6:data5/f7

[job_sde1_sub0]
startdelay=0
rw=randread
filename=data6/f1:data6/f2:data6/f3:data6/f4:data6/f5:data6/f6:data6/f7:data6/f8

[job_sde1_sub1]
startdelay=0
rw=randread
filename=data6/f2:data6/f3:data6/f4:data6/f5:data6/f6:data6/f7:data6/f8:data6/f1

[job_sde1_sub2]
startdelay=0
rw=randread
filename=data6/f3:data6/f4:data6/f5:data6/f6:data6/f7:data6/f8:data6/f1:data6/f2

[job_sde1_sub3]
startdelay=0
rw=randread
filename=data6/f4:data6/f5:data6/f6:data6/f7:data6/f8:data6/f1:data6/f2:data6/f3

[job_sde1_sub4]
startdelay=0
rw=randread
filename=data6/f5:data6/f6:data6/f7:data6/f8:data6/f1:data6/f2:data6/f3:data6/f4

[job_sde1_sub5]
startdelay=0
rw=randread
filename=data6/f6:data6/f7:data6/f8:data6/f1:data6/f2:data6/f3:data6/f4:data6/f5

[job_sde1_sub6]
startdelay=0
rw=randread
filename=data6/f7:data6/f8:data6/f1:data6/f2:data6/f3:data6/f4:data6/f5:data6/f6

[job_sde1_sub7]
startdelay=0
rw=randread
filename=data6/f8:data6/f1:data6/f2:data6/f3:data6/f4:data6/f5:data6/f6:data6/f7

[job_sde2_sub0]
startdelay=0
rw=randread
filename=data7/f1:data7/f2:data7/f3:data7/f4:data7/f5:data7/f6:data7/f7:data7/f8

[job_sde2_sub1]
startdelay=0
rw=randread
filename=data7/f2:data7/f3:data7/f4:data7/f5:data7/f6:data7/f7:data7/f8:data7/f1

[job_sde2_sub2]
startdelay=0
rw=randread
filename=data7/f3:data7/f4:data7/f5:data7/f6:data7/f7:data7/f8:data7/f1:data7/f2

[job_sde2_sub3]
startdelay=0
rw=randread
filename=data7/f4:data7/f5:data7/f6:data7/f7:data7/f8:data7/f1:data7/f2:data7/f3

[job_sde2_sub4]
startdelay=0
rw=randread
filename=data7/f5:data7/f6:data7/f7:data7/f8:data7/f1:data7/f2:data7/f3:data7/f4

[job_sde2_sub5]
startdelay=0
rw=randread
filename=data7/f6:data7/f7:data7/f8:data7/f1:data7/f2:data7/f3:data7/f4:data7/f5

[job_sde2_sub6]
startdelay=0
rw=randread
filename=data7/f7:data7/f8:data7/f1:data7/f2:data7/f3:data7/f4:data7/f5:data7/f6

[job_sde2_sub7]
startdelay=0
rw=randread
filename=data7/f8:data7/f1:data7/f2:data7/f3:data7/f4:data7/f5:data7/f6:data7/f7

[job_sdf1_sub0]
startdelay=0
rw=randread
filename=data8/f1:data8/f2:data8/f3:data8/f4:data8/f5:data8/f6:data8/f7:data8/f8

[job_sdf1_sub1]
startdelay=0
rw=randread
filename=data8/f2:data8/f3:data8/f4:data8/f5:data8/f6:data8/f7:data8/f8:data8/f1

[job_sdf1_sub2]
startdelay=0
rw=randread
filename=data8/f3:data8/f4:data8/f5:data8/f6:data8/f7:data8/f8:data8/f1:data8/f2

[job_sdf1_sub3]
startdelay=0
rw=randread
filename=data8/f4:data8/f5:data8/f6:data8/f7:data8/f8:data8/f1:data8/f2:data8/f3

[job_sdf1_sub4]
startdelay=0
rw=randread
filename=data8/f5:data8/f6:data8/f7:data8/f8:data8/f1:data8/f2:data8/f3:data8/f4

[job_sdf1_sub5]
startdelay=0
rw=randread
filename=data8/f6:data8/f7:data8/f8:data8/f1:data8/f2:data8/f3:data8/f4:data8/f5

[job_sdf1_sub6]
startdelay=0
rw=randread
filename=data8/f7:data8/f8:data8/f1:data8/f2:data8/f3:data8/f4:data8/f5:data8/f6

[job_sdf1_sub7]
startdelay=0
rw=randread
filename=data8/f8:data8/f1:data8/f2:data8/f3:data8/f4:data8/f5:data8/f6:data8/f7

[job_sdf2_sub0]
startdelay=0
rw=randread
filename=data9/f1:data9/f2:data9/f3:data9/f4:data9/f5:data9/f6:data9/f7:data9/f8

[job_sdf2_sub1]
startdelay=0
rw=randread
filename=data9/f2:data9/f3:data9/f4:data9/f5:data9/f6:data9/f7:data9/f8:data9/f1

[job_sdf2_sub2]
startdelay=0
rw=randread
filename=data9/f3:data9/f4:data9/f5:data9/f6:data9/f7:data9/f8:data9/f1:data9/f2

[job_sdf2_sub3]
startdelay=0
rw=randread
filename=data9/f4:data9/f5:data9/f6:data9/f7:data9/f8:data9/f1:data9/f2:data9/f3

[job_sdf2_sub4]
startdelay=0
rw=randread
filename=data9/f5:data9/f6:data9/f7:data9/f8:data9/f1:data9/f2:data9/f3:data9/f4

[job_sdf2_sub5]
startdelay=0
rw=randread
filename=data9/f6:data9/f7:data9/f8:data9/f1:data9/f2:data9/f3:data9/f4:data9/f5

[job_sdf2_sub6]
startdelay=0
rw=randread
filename=data9/f7:data9/f8:data9/f1:data9/f2:data9/f3:data9/f4:data9/f5:data9/f6

[job_sdf2_sub7]
startdelay=0
rw=randread
filename=data9/f8:data9/f1:data9/f2:data9/f3:data9/f4:data9/f5:data9/f6:data9/f7

[job_sdg1_sub0]
startdelay=0
rw=randread
filename=data10/f1:data10/f2:data10/f3:data10/f4:data10/f5:data10/f6:data10/f7:data10/f8

[job_sdg1_sub1]
startdelay=0
rw=randread
filename=data10/f2:data10/f3:data10/f4:data10/f5:data10/f6:data10/f7:data10/f8:data10/f1

[job_sdg1_sub2]
startdelay=0
rw=randread
filename=data10/f3:data10/f4:data10/f5:data10/f6:data10/f7:data10/f8:data10/f1:data10/f2

[job_sdg1_sub3]
startdelay=0
rw=randread
filename=data10/f4:data10/f5:data10/f6:data10/f7:data10/f8:data10/f1:data10/f2:data10/f3

[job_sdg1_sub4]
startdelay=0
rw=randread
filename=data10/f5:data10/f6:data10/f7:data10/f8:data10/f1:data10/f2:data10/f3:data10/f4

[job_sdg1_sub5]
startdelay=0
rw=randread
filename=data10/f6:data10/f7:data10/f8:data10/f1:data10/f2:data10/f3:data10/f4:data10/f5

[job_sdg1_sub6]
startdelay=0
rw=randread
filename=data10/f7:data10/f8:data10/f1:data10/f2:data10/f3:data10/f4:data10/f5:data10/f6

[job_sdg1_sub7]
startdelay=0
rw=randread
filename=data10/f8:data10/f1:data10/f2:data10/f3:data10/f4:data10/f5:data10/f6:data10/f7

[job_sdg2_sub0]
startdelay=0
rw=randread
filename=data11/f1:data11/f2:data11/f3:data11/f4:data11/f5:data11/f6:data11/f7:data11/f8

[job_sdg2_sub1]
startdelay=0
rw=randread
filename=data11/f2:data11/f3:data11/f4:data11/f5:data11/f6:data11/f7:data11/f8:data11/f1

[job_sdg2_sub2]
startdelay=0
rw=randread
filename=data11/f3:data11/f4:data11/f5:data11/f6:data11/f7:data11/f8:data11/f1:data11/f2

[job_sdg2_sub3]
startdelay=0
rw=randread
filename=data11/f4:data11/f5:data11/f6:data11/f7:data11/f8:data11/f1:data11/f2:data11/f3

[job_sdg2_sub4]
startdelay=0
rw=randread
filename=data11/f5:data11/f6:data11/f7:data11/f8:data11/f1:data11/f2:data11/f3:data11/f4

[job_sdg2_sub5]
startdelay=0
rw=randread
filename=data11/f6:data11/f7:data11/f8:data11/f1:data11/f2:data11/f3:data11/f4:data11/f5

[job_sdg2_sub6]
startdelay=0
rw=randread
filename=data11/f7:data11/f8:data11/f1:data11/f2:data11/f3:data11/f4:data11/f5:data11/f6

[job_sdg2_sub7]
startdelay=0
rw=randread
filename=data11/f8:data11/f1:data11/f2:data11/f3:data11/f4:data11/f5:data11/f6:data11/f7

[job_sdh1_sub0]
startdelay=0
rw=randread
filename=data12/f1:data12/f2:data12/f3:data12/f4:data12/f5:data12/f6:data12/f7:data12/f8

[job_sdh1_sub1]
startdelay=0
rw=randread
filename=data12/f2:data12/f3:data12/f4:data12/f5:data12/f6:data12/f7:data12/f8:data12/f1

[job_sdh1_sub2]
startdelay=0
rw=randread
filename=data12/f3:data12/f4:data12/f5:data12/f6:data12/f7:data12/f8:data12/f1:data12/f2

[job_sdh1_sub3]
startdelay=0
rw=randread
filename=data12/f4:data12/f5:data12/f6:data12/f7:data12/f8:data12/f1:data12/f2:data12/f3

[job_sdh1_sub4]
startdelay=0
rw=randread
filename=data12/f5:data12/f6:data12/f7:data12/f8:data12/f1:data12/f2:data12/f3:data12/f4

[job_sdh1_sub5]
startdelay=0
rw=randread
filename=data12/f6:data12/f7:data12/f8:data12/f1:data12/f2:data12/f3:data12/f4:data12/f5

[job_sdh1_sub6]
startdelay=0
rw=randread
filename=data12/f7:data12/f8:data12/f1:data12/f2:data12/f3:data12/f4:data12/f5:data12/f6

[job_sdh1_sub7]
startdelay=0
rw=randread
filename=data12/f8:data12/f1:data12/f2:data12/f3:data12/f4:data12/f5:data12/f6:data12/f7

[job_sdh2_sub0]
startdelay=0
rw=randread
filename=data13/f1:data13/f2:data13/f3:data13/f4:data13/f5:data13/f6:data13/f7:data13/f8

[job_sdh2_sub1]
startdelay=0
rw=randread
filename=data13/f2:data13/f3:data13/f4:data13/f5:data13/f6:data13/f7:data13/f8:data13/f1

[job_sdh2_sub2]
startdelay=0
rw=randread
filename=data13/f3:data13/f4:data13/f5:data13/f6:data13/f7:data13/f8:data13/f1:data13/f2

[job_sdh2_sub3]
startdelay=0
rw=randread
filename=data13/f4:data13/f5:data13/f6:data13/f7:data13/f8:data13/f1:data13/f2:data13/f3

[job_sdh2_sub4]
startdelay=0
rw=randread
filename=data13/f5:data13/f6:data13/f7:data13/f8:data13/f1:data13/f2:data13/f3:data13/f4

[job_sdh2_sub5]
startdelay=0
rw=randread
filename=data13/f6:data13/f7:data13/f8:data13/f1:data13/f2:data13/f3:data13/f4:data13/f5

[job_sdh2_sub6]
startdelay=0
rw=randread
filename=data13/f7:data13/f8:data13/f1:data13/f2:data13/f3:data13/f4:data13/f5:data13/f6

[job_sdh2_sub7]
startdelay=0
rw=randread
filename=data13/f8:data13/f1:data13/f2:data13/f3:data13/f4:data13/f5:data13/f6:data13/f7

[job_sdi1_sub0]
startdelay=0
rw=randread
filename=data14/f1:data14/f2:data14/f3:data14/f4:data14/f5:data14/f6:data14/f7:data14/f8

[job_sdi1_sub1]
startdelay=0
rw=randread
filename=data14/f2:data14/f3:data14/f4:data14/f5:data14/f6:data14/f7:data14/f8:data14/f1

[job_sdi1_sub2]
startdelay=0
rw=randread
filename=data14/f3:data14/f4:data14/f5:data14/f6:data14/f7:data14/f8:data14/f1:data14/f2

[job_sdi1_sub3]
startdelay=0
rw=randread
filename=data14/f4:data14/f5:data14/f6:data14/f7:data14/f8:data14/f1:data14/f2:data14/f3

[job_sdi1_sub4]
startdelay=0
rw=randread
filename=data14/f5:data14/f6:data14/f7:data14/f8:data14/f1:data14/f2:data14/f3:data14/f4

[job_sdi1_sub5]
startdelay=0
rw=randread
filename=data14/f6:data14/f7:data14/f8:data14/f1:data14/f2:data14/f3:data14/f4:data14/f5

[job_sdi1_sub6]
startdelay=0
rw=randread
filename=data14/f7:data14/f8:data14/f1:data14/f2:data14/f3:data14/f4:data14/f5:data14/f6

[job_sdi1_sub7]
startdelay=0
rw=randread
filename=data14/f8:data14/f1:data14/f2:data14/f3:data14/f4:data14/f5:data14/f6:data14/f7

[job_sdi2_sub0]
startdelay=0
rw=randread
filename=data15/f1:data15/f2:data15/f3:data15/f4:data15/f5:data15/f6:data15/f7:data15/f8

[job_sdi2_sub1]
startdelay=0
rw=randread
filename=data15/f2:data15/f3:data15/f4:data15/f5:data15/f6:data15/f7:data15/f8:data15/f1

[job_sdi2_sub2]
startdelay=0
rw=randread
filename=data15/f3:data15/f4:data15/f5:data15/f6:data15/f7:data15/f8:data15/f1:data15/f2

[job_sdi2_sub3]
startdelay=0
rw=randread
filename=data15/f4:data15/f5:data15/f6:data15/f7:data15/f8:data15/f1:data15/f2:data15/f3

[job_sdi2_sub4]
startdelay=0
rw=randread
filename=data15/f5:data15/f6:data15/f7:data15/f8:data15/f1:data15/f2:data15/f3:data15/f4

[job_sdi2_sub5]
startdelay=0
rw=randread
filename=data15/f6:data15/f7:data15/f8:data15/f1:data15/f2:data15/f3:data15/f4:data15/f5

[job_sdi2_sub6]
startdelay=0
rw=randread
filename=data15/f7:data15/f8:data15/f1:data15/f2:data15/f3:data15/f4:data15/f5:data15/f6

[job_sdi2_sub7]
startdelay=0
rw=randread
filename=data15/f8:data15/f1:data15/f2:data15/f3:data15/f4:data15/f5:data15/f6:data15/f7

[job_sdj1_sub0]
startdelay=0
rw=randread
filename=data16/f1:data16/f2:data16/f3:data16/f4:data16/f5:data16/f6:data16/f7:data16/f8

[job_sdj1_sub1]
startdelay=0
rw=randread
filename=data16/f2:data16/f3:data16/f4:data16/f5:data16/f6:data16/f7:data16/f8:data16/f1

[job_sdj1_sub2]
startdelay=0
rw=randread
filename=data16/f3:data16/f4:data16/f5:data16/f6:data16/f7:data16/f8:data16/f1:data16/f2

[job_sdj1_sub3]
startdelay=0
rw=randread
filename=data16/f4:data16/f5:data16/f6:data16/f7:data16/f8:data16/f1:data16/f2:data16/f3

[job_sdj1_sub4]
startdelay=0
rw=randread
filename=data16/f5:data16/f6:data16/f7:data16/f8:data16/f1:data16/f2:data16/f3:data16/f4

[job_sdj1_sub5]
startdelay=0
rw=randread
filename=data16/f6:data16/f7:data16/f8:data16/f1:data16/f2:data16/f3:data16/f4:data16/f5

[job_sdj1_sub6]
startdelay=0
rw=randread
filename=data16/f7:data16/f8:data16/f1:data16/f2:data16/f3:data16/f4:data16/f5:data16/f6

[job_sdj1_sub7]
startdelay=0
rw=randread
filename=data16/f8:data16/f1:data16/f2:data16/f3:data16/f4:data16/f5:data16/f6:data16/f7

[job_sdj2_sub0]
startdelay=0
rw=randread
filename=data17/f1:data17/f2:data17/f3:data17/f4:data17/f5:data17/f6:data17/f7:data17/f8

[job_sdj2_sub1]
startdelay=0
rw=randread
filename=data17/f2:data17/f3:data17/f4:data17/f5:data17/f6:data17/f7:data17/f8:data17/f1

[job_sdj2_sub2]
startdelay=0
rw=randread
filename=data17/f3:data17/f4:data17/f5:data17/f6:data17/f7:data17/f8:data17/f1:data17/f2

[job_sdj2_sub3]
startdelay=0
rw=randread
filename=data17/f4:data17/f5:data17/f6:data17/f7:data17/f8:data17/f1:data17/f2:data17/f3

[job_sdj2_sub4]
startdelay=0
rw=randread
filename=data17/f5:data17/f6:data17/f7:data17/f8:data17/f1:data17/f2:data17/f3:data17/f4

[job_sdj2_sub5]
startdelay=0
rw=randread
filename=data17/f6:data17/f7:data17/f8:data17/f1:data17/f2:data17/f3:data17/f4:data17/f5

[job_sdj2_sub6]
startdelay=0
rw=randread
filename=data17/f7:data17/f8:data17/f1:data17/f2:data17/f3:data17/f4:data17/f5:data17/f6

[job_sdj2_sub7]
startdelay=0
rw=randread
filename=data17/f8:data17/f1:data17/f2:data17/f3:data17/f4:data17/f5:data17/f6:data17/f7

[job_sdk1_sub0]
startdelay=0
rw=randread
filename=data18/f1:data18/f2:data18/f3:data18/f4:data18/f5:data18/f6:data18/f7:data18/f8

[job_sdk1_sub1]
startdelay=0
rw=randread
filename=data18/f2:data18/f3:data18/f4:data18/f5:data18/f6:data18/f7:data18/f8:data18/f1

[job_sdk1_sub2]
startdelay=0
rw=randread
filename=data18/f3:data18/f4:data18/f5:data18/f6:data18/f7:data18/f8:data18/f1:data18/f2

[job_sdk1_sub3]
startdelay=0
rw=randread
filename=data18/f4:data18/f5:data18/f6:data18/f7:data18/f8:data18/f1:data18/f2:data18/f3

[job_sdk1_sub4]
startdelay=0
rw=randread
filename=data18/f5:data18/f6:data18/f7:data18/f8:data18/f1:data18/f2:data18/f3:data18/f4

[job_sdk1_sub5]
startdelay=0
rw=randread
filename=data18/f6:data18/f7:data18/f8:data18/f1:data18/f2:data18/f3:data18/f4:data18/f5

[job_sdk1_sub6]
startdelay=0
rw=randread
filename=data18/f7:data18/f8:data18/f1:data18/f2:data18/f3:data18/f4:data18/f5:data18/f6

[job_sdk1_sub7]
startdelay=0
rw=randread
filename=data18/f8:data18/f1:data18/f2:data18/f3:data18/f4:data18/f5:data18/f6:data18/f7

[job_sdk2_sub0]
startdelay=0
rw=randread
filename=data19/f1:data19/f2:data19/f3:data19/f4:data19/f5:data19/f6:data19/f7:data19/f8

[job_sdk2_sub1]
startdelay=0
rw=randread
filename=data19/f2:data19/f3:data19/f4:data19/f5:data19/f6:data19/f7:data19/f8:data19/f1

[job_sdk2_sub2]
startdelay=0
rw=randread
filename=data19/f3:data19/f4:data19/f5:data19/f6:data19/f7:data19/f8:data19/f1:data19/f2

[job_sdk2_sub3]
startdelay=0
rw=randread
filename=data19/f4:data19/f5:data19/f6:data19/f7:data19/f8:data19/f1:data19/f2:data19/f3

[job_sdk2_sub4]
startdelay=0
rw=randread
filename=data19/f5:data19/f6:data19/f7:data19/f8:data19/f1:data19/f2:data19/f3:data19/f4

[job_sdk2_sub5]
startdelay=0
rw=randread
filename=data19/f6:data19/f7:data19/f8:data19/f1:data19/f2:data19/f3:data19/f4:data19/f5

[job_sdk2_sub6]
startdelay=0
rw=randread
filename=data19/f7:data19/f8:data19/f1:data19/f2:data19/f3:data19/f4:data19/f5:data19/f6

[job_sdk2_sub7]
startdelay=0
rw=randread
filename=data19/f8:data19/f1:data19/f2:data19/f3:data19/f4:data19/f5:data19/f6:data19/f7

[job_sdl1_sub0]
startdelay=0
rw=randread
filename=data20/f1:data20/f2:data20/f3:data20/f4:data20/f5:data20/f6:data20/f7:data20/f8

[job_sdl1_sub1]
startdelay=0
rw=randread
filename=data20/f2:data20/f3:data20/f4:data20/f5:data20/f6:data20/f7:data20/f8:data20/f1

[job_sdl1_sub2]
startdelay=0
rw=randread
filename=data20/f3:data20/f4:data20/f5:data20/f6:data20/f7:data20/f8:data20/f1:data20/f2

[job_sdl1_sub3]
startdelay=0
rw=randread
filename=data20/f4:data20/f5:data20/f6:data20/f7:data20/f8:data20/f1:data20/f2:data20/f3

[job_sdl1_sub4]
startdelay=0
rw=randread
filename=data20/f5:data20/f6:data20/f7:data20/f8:data20/f1:data20/f2:data20/f3:data20/f4

[job_sdl1_sub5]
startdelay=0
rw=randread
filename=data20/f6:data20/f7:data20/f8:data20/f1:data20/f2:data20/f3:data20/f4:data20/f5

[job_sdl1_sub6]
startdelay=0
rw=randread
filename=data20/f7:data20/f8:data20/f1:data20/f2:data20/f3:data20/f4:data20/f5:data20/f6

[job_sdl1_sub7]
startdelay=0
rw=randread
filename=data20/f8:data20/f1:data20/f2:data20/f3:data20/f4:data20/f5:data20/f6:data20/f7

[job_sdl2_sub0]
startdelay=0
rw=randread
filename=data21/f1:data21/f2:data21/f3:data21/f4:data21/f5:data21/f6:data21/f7:data21/f8

[job_sdl2_sub1]
startdelay=0
rw=randread
filename=data21/f2:data21/f3:data21/f4:data21/f5:data21/f6:data21/f7:data21/f8:data21/f1

[job_sdl2_sub2]
startdelay=0
rw=randread
filename=data21/f3:data21/f4:data21/f5:data21/f6:data21/f7:data21/f8:data21/f1:data21/f2

[job_sdl2_sub3]
startdelay=0
rw=randread
filename=data21/f4:data21/f5:data21/f6:data21/f7:data21/f8:data21/f1:data21/f2:data21/f3

[job_sdl2_sub4]
startdelay=0
rw=randread
filename=data21/f5:data21/f6:data21/f7:data21/f8:data21/f1:data21/f2:data21/f3:data21/f4

[job_sdl2_sub5]
startdelay=0
rw=randread
filename=data21/f6:data21/f7:data21/f8:data21/f1:data21/f2:data21/f3:data21/f4:data21/f5

[job_sdl2_sub6]
startdelay=0
rw=randread
filename=data21/f7:data21/f8:data21/f1:data21/f2:data21/f3:data21/f4:data21/f5:data21/f6

[job_sdl2_sub7]
startdelay=0
rw=randread
filename=data21/f8:data21/f1:data21/f2:data21/f3:data21/f4:data21/f5:data21/f6:data21/f7

[job_sdm1_sub0]
startdelay=0
rw=randread
filename=data22/f1:data22/f2:data22/f3:data22/f4:data22/f5:data22/f6:data22/f7:data22/f8

[job_sdm1_sub1]
startdelay=0
rw=randread
filename=data22/f2:data22/f3:data22/f4:data22/f5:data22/f6:data22/f7:data22/f8:data22/f1

[job_sdm1_sub2]
startdelay=0
rw=randread
filename=data22/f3:data22/f4:data22/f5:data22/f6:data22/f7:data22/f8:data22/f1:data22/f2

[job_sdm1_sub3]
startdelay=0
rw=randread
filename=data22/f4:data22/f5:data22/f6:data22/f7:data22/f8:data22/f1:data22/f2:data22/f3

[job_sdm1_sub4]
startdelay=0
rw=randread
filename=data22/f5:data22/f6:data22/f7:data22/f8:data22/f1:data22/f2:data22/f3:data22/f4

[job_sdm1_sub5]
startdelay=0
rw=randread
filename=data22/f6:data22/f7:data22/f8:data22/f1:data22/f2:data22/f3:data22/f4:data22/f5

[job_sdm1_sub6]
startdelay=0
rw=randread
filename=data22/f7:data22/f8:data22/f1:data22/f2:data22/f3:data22/f4:data22/f5:data22/f6

[job_sdm1_sub7]
startdelay=0
rw=randread
filename=data22/f8:data22/f1:data22/f2:data22/f3:data22/f4:data22/f5:data22/f6:data22/f7

[job_sdm2_sub0]
startdelay=0
rw=randread
filename=data23/f1:data23/f2:data23/f3:data23/f4:data23/f5:data23/f6:data23/f7:data23/f8

[job_sdm2_sub1]
startdelay=0
rw=randread
filename=data23/f2:data23/f3:data23/f4:data23/f5:data23/f6:data23/f7:data23/f8:data23/f1

[job_sdm2_sub2]
startdelay=0
rw=randread
filename=data23/f3:data23/f4:data23/f5:data23/f6:data23/f7:data23/f8:data23/f1:data23/f2

[job_sdm2_sub3]
startdelay=0
rw=randread
filename=data23/f4:data23/f5:data23/f6:data23/f7:data23/f8:data23/f1:data23/f2:data23/f3

[job_sdm2_sub4]
startdelay=0
rw=randread
filename=data23/f5:data23/f6:data23/f7:data23/f8:data23/f1:data23/f2:data23/f3:data23/f4

[job_sdm2_sub5]
startdelay=0
rw=randread
filename=data23/f6:data23/f7:data23/f8:data23/f1:data23/f2:data23/f3:data23/f4:data23/f5

[job_sdm2_sub6]
startdelay=0
rw=randread
filename=data23/f7:data23/f8:data23/f1:data23/f2:data23/f3:data23/f4:data23/f5:data23/f6

[job_sdm2_sub7]
startdelay=0
rw=randread
filename=data23/f8:data23/f1:data23/f2:data23/f3:data23/f4:data23/f5:data23/f6:data23/f7


BTW, I save several time kernel panic in fio testing:
===================
> Pid: 776, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1 X8DTN/X8DTN
> > RIP: 0010:[<ffffffff810cc21c>]  [<ffffffff810cc21c>] slab_alloc
> > +0x562/0x6f2
> > RSP: 0000:ffff88023dbebbc0  EFLAGS: 00010002
> > RAX: 0000000000000000 RBX: ffff88023fc02600 RCX: 0000000000000000
> > RDX: ffff88023e4746a0 RSI: 0000000000000046 RDI: ffffffff81d8f294
> > RBP: 0000000000000000 R08: 0000000000000012 R09: 0000000000000006
> > R10: 0000000000000000 R11: 0000000000000000 R12: ffff880002076880
> > R13: 0000000000000000 R14: ffff88023fc012c0 R15: 0000000000000010
> > FS:  0000000000000000(0000) GS:ffff880002060000(0000)
> > knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000000 CR3: 0000000375d3c000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process kswapd0 (pid: 776, threadinfo ffff88023dbea000, task
> > ffff88023e4746a0)
> > Stack:
> >  0000000000000000 000000d000000e00 ffff88000000003c 0000000000000282
> > <0> ffff88023e4746a0 000080d03e4746a0 ffff880002076888 0000000000000286
> > <0> ffff88023e4746a0 0000005a3dbebfd8 ffff88023e474cb8 ffff88023fc012d0
> > Call Trace:
> >  [<ffffffff810cd97c>] ? shared_caches+0x2e/0xd6
> >  [<ffffffff810cd4f7>] ? __kmalloc+0xb4/0x108
> >  [<ffffffff810cd97c>] ? shared_caches+0x2e/0xd6
> >  [<ffffffff810cda39>] ? expire_alien_caches+0x15/0x8a
> >  [<ffffffff810c984f>] ? __kmem_cache_expire_all+0x27/0x65
> >  [<ffffffff810cd249>] ? kmem_cache_expire_all+0x86/0x9c
> >  [<ffffffff810a61f0>] ? balance_pgdat+0x2eb/0x4dc
> >  [<ffffffff810a6612>] ? kswapd+0x231/0x247
> >  [<ffffffff81055513>] ? autoremove_wake_function+0x0/0x2a
> >  [<ffffffff810a63e1>] ? kswapd+0x0/0x247
> >  [<ffffffff810a63e1>] ? kswapd+0x0/0x247
> >  [<ffffffff810550c0>] ? kthread+0x7a/0x82
> >  [<ffffffff810036d4>] ? kernel_thread_helper+0x4/0x10
> >  [<ffffffff81055046>] ? kthread+0x0/0x82
> >  [<ffffffff810036d0>] ? kernel_thread_helper+0x0/0x10
> > 
> > 
kswapd0: page allocation failure. order:0, mode:0xd0
Pid: 714, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1
Call Trace:
[<ffffffff8109fcf4>] ? __alloc_pages_nodemask+0x63f/0x6c7
[<ffffffff8100328e>] ? apic_timer_interrupt+0xe/0x20
[<ffffffff810cc6f7>] ? new_slab+0xac/0x277
[<ffffffff810cce1e>] ? slab_alloc+0x55c/0x6e8
[<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
[<ffffffff810ce110>] ? __kmalloc+0xb0/0xff
[<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
[<ffffffff810ce649>] ? expire_alien_caches+0x16/0x8d
[<ffffffff810cde25>] ? kmem_cache_expire_all+0xf6/0x14d
[<ffffffff810a6aaf>] ? kswapd+0x5c2/0x7ea
[<ffffffff810556aa>] ? autoremove_wake_function+0x0/0x2e
[<ffffffff810a64ed>] ? kswapd+0x0/0x7ea
[<ffffffff81055269>] ? kthread+0x7e/0x86
[<ffffffff810036d4>] ? kernel_thread_helper+0x4/0x10
[<ffffffff810551eb>] ? kthread+0x0/0x86
[<ffffffff810036d0>] ? kernel_thread_helper+0x0/0x10
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
CPU    8: hi:    0, btch:   1 usd:   0
CPU    9: hi:    0, btch:   1 usd:   0
CPU   10: hi:    0, btch:   1 usd:   0
CPU   11: hi:    0, btch:   1 usd:   0
CPU   12: hi:    0, btch:   1 usd:   0
CPU   13: hi:    0, btch:   1 usd:   0
CPU   14: hi:    0, btch:   1 usd:   0
CPU   15: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
CPU    8: hi:  186, btch:  31 usd:   0
CPU    9: hi:  186, btch:  31 usd:   0
CPU   10: hi:  186, btch:  31 usd:   0
CPU   11: hi:  186, btch:  31 usd:   0
CPU   12: hi:  186, btch:  31 usd:   0
CPU   13: hi:  186, btch:  31 usd:   0
CPU   14: hi:  186, btch:  31 usd:   0
CPU   15: hi:  186, btch:  31 usd:   0
Node 1 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
CPU    8: hi:  186, btch:  31 usd:   0
CPU    9: hi:  186, btch:  31 usd:   0
CPU   10: hi:  186, btch:  31 usd:   0
CPU   11: hi:  186, btch:  31 usd:   0
CPU   12: hi:  186, btch:  31 usd:   0
CPU   13: hi:  186, btch:  31 usd:   0
CPU   14: hi:  186, btch:  31 usd:   0
CPU   15: hi:  186, btch:  31 usd:   0
active_anon:864 inactive_anon:1237 isolated_anon:0
active_file:178 inactive_file:60 isolated_file:32
unevictable:0 dirty:0 writeback:0 unstable:0
free:9 slab_reclaimable:2410 slab_unreclaimable:1513417
mapped:1 shmem:64 pagetables:346 bounce:0
Node 0 DMA free:0kB min:24kB low:28kB high:36kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:15700kB mlocked:0kB
dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:192kB
slab_unreclaimable:15636kB kernel_stack:0kB pagetables:0kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 3003 3003 3003
Node 0 DMA32 free:0kB min:4940kB low:6172kB high:7408kB
active_anon:604kB inactive_anon:3292kB active_file:0kB
inactive_file:128kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:3075164kB mlocked:0kB dirty:0kB writeback:0kB
mapped:4kB shmem:152kB slab_reclaimable:5840kB
slab_unreclaimable:2963060kB kernel_stack:1016kB pagetables:656kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 1 Normal free:24kB min:4984kB low:6228kB high:7476kB
active_anon:2852kB inactive_anon:1656kB active_file:712kB
inactive_file:112kB unevictable:0kB isolated(anon):0kB
isolated(file):128kB present:3102720kB mlocked:0kB dirty:0kB
writeback:0kB mapped:0kB shmem:104kB slab_reclaimable:3608kB
slab_unreclaimable:3074972kB kernel_stack:312kB pagetables:728kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1272
all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 0kB
Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 0kB
Node 1 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 0kB
305 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
1570800 pages RAM
42204 pages reserved
509 pages shared
1527199 pages non-shared

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff810cce27>] slab_alloc+0x565/0x6e8
PGD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/block/sdm/stat
CPU 2 
Modules linked in: igb ixgbe mdio

Pid: 714, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1 X8DTN/X8DTN
RIP: 0010:[<ffffffff810cce27>]  [<ffffffff810cce27>] slab_alloc
+0x565/0x6e8
RSP: 0018:ffff8800bd377c00  EFLAGS: 00010002
RAX: 0000000000000000 RBX: ffff8800bd2f0408 RCX: 0000000000020000
RDX: ffff8800be328000 RSI: ffff8801030ff000 RDI: 000000000000005a
RBP: ffff8800bd2f0400 R08: 0000000000000012 R09: 0000000000000004
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff8800bec012d0 R14: 0000000000000010 R15: ffff8800bec02600
FS:  0000000000000000(0000) GS:ffff880002080000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001c53000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kswapd0 (pid: 714, threadinfo ffff8800bd376000, task
ffff8800be328000)
Stack:
ffff8800be328000 ffff8800be328618 ffff8800be328000 ffff8800bd377fd8
<0> 0000000000000000 ffffffff810ce58b ffff880000000000 000000d0810a57a3
<0> 0000000000000001 000080d002097a88 ffff8800bec012d0 ffff880002096888
Call Trace:
[<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
[<ffffffff810ce110>] ? __kmalloc+0xb0/0xff
[<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
[<ffffffff810ce649>] ? expire_alien_caches+0x16/0x8d
[<ffffffff810cde25>] ? kmem_cache_expire_all+0xf6/0x14d
[<ffffffff810a6aaf>] ? kswapd+0x5c2/0x7ea
[<ffffffff810556aa>] ? autoremove_wake_function+0x0/0x2e
[<ffffffff810a64ed>] ? kswapd+0x0/0x7ea
[<ffffffff81055269>] ? kthread+0x7e/0x86
[<ffffffff810036d4>] ? kernel_thread_helper+0x4/0x10
[<ffffffff810551eb>] ? kthread+0x0/0x86
[<ffffffff810036d0>] ? kernel_thread_helper+0x0/0x10
Code: 74 24 4c 41 83 e6 10 e9 46 01 00 00 45 85 f6 74 01 fb 8b 54 24 30
8b 74 24 4c 4c 89 ff e8 2d f8 ff ff 45 85 f6 49 89 c4 74 01 fa <49> 8b
04 24 65 48 8b 14 25 18 d4 00 00 48 c1 e8 3a 89 44 24 30 
RIP  [<ffffffff810cce27>] slab_alloc+0x565/0x6e8
RSP <ffff8800bd377c00>
CR2: 0000000000000000
---[ end trace dd9ddd336d3f686a ]---


Another panic: 
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.36-rc7-unified #1
Call Trace:
<IRQ>  [<ffffffff816139c0>] ? panic+0x92/0x198
[<ffffffff8161701f>] ? oops_end+0x9f/0xac
[<ffffffff81021da5>] ? no_context+0x1f2/0x201
[<ffffffff8103c05d>] ? __call_console_drivers+0x64/0x75
[<ffffffff81021f60>] ? __bad_area_nosemaphore+0x1ac/0x1d0
[<ffffffff81618f1e>] ? do_page_fault+0x1cb/0x3c0
[<ffffffff81613b06>] ? printk+0x40/0x45
[<ffffffff812d2f32>] ? show_mem+0x13a/0x17c
[<ffffffff8109fcf9>] ? __alloc_pages_nodemask+0x644/0x6c7
[<ffffffff8161651f>] ? page_fault+0x1f/0x30
[<ffffffff810cce27>] ? slab_alloc+0x565/0x6e8
[<ffffffff81520390>] ? sk_prot_alloc+0x29/0xe1
[<ffffffff8153de4b>] ? sch_direct_xmit+0x80/0x182
[<ffffffff810ce7bb>] ? kmem_cache_alloc+0x21/0x75
[<ffffffff81520390>] ? sk_prot_alloc+0x29/0xe1
[<ffffffff815204cb>] ? sk_clone+0x16/0x246
[<ffffffff8154f06b>] ? inet_csk_clone+0xf/0x7f
[<ffffffff81562e12>] ? tcp_create_openreq_child+0x23/0x476
[<ffffffff815618e1>] ? tcp_v4_syn_recv_sock+0x4e/0x18e
[<ffffffff81562c92>] ? tcp_check_req+0x21e/0x37b
[<ffffffff81561035>] ? tcp_v4_do_rcv+0xf7/0x22f
[<ffffffff815615b8>] ? tcp_v4_rcv+0x44b/0x726
[<ffffffff815b2cf9>] ? packet_rcv+0x2ea/0x2fd
[<ffffffff815473bb>] ? ip_local_deliver+0xd6/0x161
[<ffffffff815472bf>] ? ip_rcv+0x487/0x4ad
[<ffffffff8152aac2>] ? netif_receive_skb+0x67/0x6d
[<ffffffff8143cba0>] ? e100_poll+0x208/0x534
[<ffffffff8152ac29>] ? net_rx_action+0x72/0x1a3
[<ffffffff810587ff>] ? hrtimer_get_next_event+0x8b/0xa2
[<ffffffff8104192d>] ? __do_softirq+0xdb/0x19e
[<ffffffff810037cc>] ? call_softirq+0x1c/0x28
[<ffffffff81004bdd>] ? do_softirq+0x31/0x63
[<ffffffff810417b9>] ? irq_exit+0x36/0x78
[<ffffffff810042dd>] ? do_IRQ+0xa7/0xbd
[<ffffffff81616313>] ? ret_from_intr+0x0/0xa
<EOI>  [<ffffffff81336c02>] ? acpi_idle_enter_c1+0x8c/0xf5
[<ffffffff81336bca>] ? acpi_idle_enter_c1+0x54/0xf5
[<ffffffff815012ce>] ? cpuidle_idle_call+0xa5/0x10b
[<ffffffff81001cf9>] ? cpu_idle+0x5c/0xc9
[<ffffffff81cf2c72>] ? start_kernel+0x355/0x361
[<ffffffff81d071f5>] ? __reserve_early+0xa4/0xba
[<ffffffff81cf2388>] ? x86_64_start_kernel+0xe8/0xee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
