Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E98866B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 14:50:51 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 9 Aug 2012 12:50:51 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 530211FF001C
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 18:50:42 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q79IofZC125920
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 12:50:42 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q79IpvOQ022503
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 12:51:57 -0600
Message-ID: <5024067F.3010602@linux.vnet.ibm.com>
Date: Thu, 09 Aug 2012 13:50:39 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <5021795A.5000509@linux.vnet.ibm.com>
In-Reply-To: <5021795A.5000509@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 08/07/2012 03:23 PM, Seth Jennings wrote:
> On 07/27/2012 01:18 PM, Seth Jennings wrote:
>> Some benchmarking numbers demonstrating the I/O saving that can be had
>> with zcache:
>>
>> https://lkml.org/lkml/2012/3/22/383
> 
> There was concern that kernel changes external to zcache since v3.3 may
> have mitigated the benefit of zcache.  So I re-ran my kernel building
> benchmark and confirmed that zcache is still providing I/O and runtime
> savings.

There was a request made to test with even greater memory pressure to
demonstrate that, at some unknown point, zcache doesn't have real
problems.  So I continued out to 32 threads:

N=4..20 is the same data as before except for the pswpin values.
I found a mistake in the way I computed pswpin that changed those
values slightly.  However, this didn't change the overall trend.

I also inverted the %change fields since it is a percent change vs the
normal case.

I/O (in pages)
	normal				zcache				change
N	pswpin	pswpout	majflt	I/O sum	pswpin	pswpout	majflt	I/O sum	%I/O
4	0	2	2116	2118	0	0	2125	2125	0%
8	0	575	2244	2819	0	4	2219	2223	-21%
12	1979	4038	3226	9243	1269	2519	3871	7659	-17%
16	21568	47278	9426	78272	7770	15598	9372	32740	-58%
20	50307	127797	15039	193143	20224	40634	17975	78833	-59%
24	186278	364809	45052	596139	47406	90489	30877	168772	-72%
28	274734	777815	53112	1105661	134981	307346	63480	505807	-54%
32	988530	2002087	168662	3159279	324801	723385	140288	1188474	-62%

Runtime (in seconds)
N	normal	zcache	%change
4	126	127	1%
8	124	124	0%
12	131	133	2%
16	189	156	-17%
20	261	235	-10%
24	513	288	-44%
28	556	434	-22%
32	1463	745	-49%

%CPU utilization (out of 400% on 4 cpus)
N	normal	zcache	%change
4	254	253	0%
8	261	263	1%
12	250	248	-1%
16	173	211	22%
20	124	140	13%
24	64	114	78%
28	59	76	29%
32	23	45	96%

The ~60% I/O savings holds even out to 32 threads, at which point the
non-zcache case has 12GB of I/O and is taking 12x longer to complete.
Additionally, the runtime savings increases significantly beyond 20
threads, even though the absolute runtime is suboptimal due to the
extreme memory pressure.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
