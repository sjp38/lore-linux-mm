Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4DCAB6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:36:39 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 15 Aug 2012 10:36:37 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C3795C90928
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:24:50 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7FEOnH1084070
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:24:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7FEOmew029733
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 11:24:48 -0300
Message-ID: <502BB125.7030607@linux.vnet.ibm.com>
Date: Wed, 15 Aug 2012 09:24:37 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <5021795A.5000509@linux.vnet.ibm.com> <5024067F.3010602@linux.vnet.ibm.com> <2e9ccb4f-1339-4c26-88dd-ea294b022127@default> <50254F69.2000409@linux.vnet.ibm.com> <20120815093828.GB2865@phenom.dumpdata.com>
In-Reply-To: <20120815093828.GB2865@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

On 08/15/2012 04:38 AM, Konrad Rzeszutek Wilk wrote:
> On Fri, Aug 10, 2012 at 01:14:01PM -0500, Seth Jennings wrote:
>> On 08/09/2012 03:20 PM, Dan Magenheimer wrote
>>> I also wonder if you have anything else unusual in your
>>> test setup, such as a fast swap disk (mine is a partition
>>> on the same rotating disk as source and target of the kernel build,
>>> the default install for a RHEL6 system)?
>>
>> I'm using a normal SATA HDD with two partitions, one for
>> swap and the other an ext3 filesystem with the kernel source.
>>
>>> Or have you disabled cleancache?
>>
>> Yes, I _did_ disable cleancache.  I could see where having
>> cleancache enabled could explain the difference in results.
> 
> Why did you disable the cleancache? Having both (cleancache
> to compress fs data) and frontswap (to compress swap data) is the
> goal - while you turned one of its sources off.

I excluded cleancache to reduce interference/noise from the
benchmarking results. For this particular workload,
cleancache doesn't make a lot of sense since it will steal
pages that could otherwise be used for storing frontswap
pages to prevent swapin/swapout I/O.

In a test run with both enabled, I found that it didn't make
much difference under moderate to extreme memory pressure.
Both resulted in about 55% I/O reduction.  However, on light
memory pressure with 8 and 12 threads, it lowered the I/O
reduction ability of zcache to roughly 0 compared to ~20%
I/O reduction without cleancache.

In short, cleancache only had the power to harm in this
case, so I didn't enable it.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
