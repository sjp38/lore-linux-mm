Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D2A036B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 16:35:58 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 7 Aug 2012 16:35:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F299438C8831
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 16:23:59 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q77KNxBp164174
	for <linux-mm@kvack.org>; Tue, 7 Aug 2012 16:23:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q77KNuFM011284
	for <linux-mm@kvack.org>; Tue, 7 Aug 2012 17:23:58 -0300
Message-ID: <5021795A.5000509@linux.vnet.ibm.com>
Date: Tue, 07 Aug 2012 15:23:54 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 07/27/2012 01:18 PM, Seth Jennings wrote:
> Some benchmarking numbers demonstrating the I/O saving that can be had
> with zcache:
> 
> https://lkml.org/lkml/2012/3/22/383

There was concern that kernel changes external to zcache since v3.3 may
have mitigated the benefit of zcache.  So I re-ran my kernel building
benchmark and confirmed that zcache is still providing I/O and runtime
savings.

Gentoo w/ kernel v3.5 (frontswap only, cleancache disabled)
Quad-core i5-2500 @ 3.3GHz
512MB DDR3 1600MHz (limited with mem=512m on boot)
Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
majflt are major page faults reported by the time command
pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
the make -jN

Mind the 512MB RAM vs 1GB in my previous results.  This just reduces
the number of threads required to create memory pressure and removes some
of the context switching noise from the results.

I'm also using a single HDD instead of the RAID0 in my previous results.

Each run started with with:
swapoff -a
swapon -a
sync
echo 3 > /proc/sys/vm/drop_caches

I/O (in pages):
	normal				zcache				change
N	pswpin	pswpout	majflt	I/O sum	pswpin	pswpout	majflt	I/O sum	%I/O
4	0	2	2116	2118	0	0	2125	2125	0%
8	0	575	2244	2819	4	4	2219	2227	21%
12	2543	4038	3226	9807	1748	2519	3871	8138	17%
16	23926	47278	9426	80630	8252	15598	9372	33222	59%
20	50307	127797	15039	193143	20224	40634	17975	78833	59%

Runtime (in seconds):
N	normal	zcache	%change
4	126	127	-1%
8	124	124	0%
12	131	133	-2%
16	189	156	17%
20	261	235	10%

%CPU utilization (out of 400% on 4 cpus)
N	normal	zcache	%change
4	254	253	0%
8	261	263	-1%
12	250	248	1%
16	173	211	-22%
20	124	140	-13%

There is a sweet spot at 16 threads, where zcache is improving runtime by
17% and reducing I/O by 59% (185MB) using 22% more CPU.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
