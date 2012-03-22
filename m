Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 25B216B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:44:22 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 22 Mar 2012 15:44:21 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2430019D8052
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:44:07 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2MLhRYj142154
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:43:47 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2MLhNPu007212
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:43:26 -0600
Message-ID: <4F6B9CF3.7000803@linux.vnet.ibm.com>
Date: Thu, 22 Mar 2012 16:43:15 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zcache preliminary benchmark results
References: <cb50b439-1e5f-443e-9369-4f7c989d3565@default>
In-Reply-To: <cb50b439-1e5f-443e-9369-4f7c989d3565@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Bottomley <James.Bottomley@HansenPartnership.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, Akshay Karle <akshay.a.karle@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>

On 03/21/2012 06:30 PM, Dan Magenheimer wrote:
> Last November, in an LKML thread I would rather forget*, James
> Bottomley and others asked for some benchmarking to be done for
> zcache (among other things).  For various reasons, that benchmarking
> is just now getting underway and more will be done, but it might be
> useful to publish some interesting preliminary results now.

I'd also like to post some zcache performance numbers that suggest
that zcache makes an even more impressive change to the amount
of total I/O when the system is under light to moderate memory
pressure.

Test machine:
Gentoo w/ kernel v3.3 + frontswap (cleancache disabled)
Quad-core i5-2500 @ 3.3GHz
1GB DDR3 1600MHz (limited with mem=1024m on boot)
Filesystem and swap on 2x80G RAID0
majflt are major page faults reported by "time"
pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
the make -jN

Each run started with with swapoff/on and
echo 3 > /proc/sys/vm/drop_caches

I/O									
	normal				zcache				change
N	pswpin	pswpout	majflt	I/O sum	pswpin	pswpout	majflt	I/O sum	%I/O
8	0	133	1781	1914	0	0	1835	1835	4%
12	10	1140	1871	3021	0	5	1886	1891	37%
16	675	1978	2330	4983	21	63	3771	3855	23%
20	3420	6197	3421	13038	265	786	5218	6269	52%
24	28358	51884	8865	89107	3944	6227	36048	46219	48%
28	44132	62182	11931	118245	6094	11362	74323	91779	22%
32	94163	125086	22526	241775	22534	32803	179164	234501	3%
									
Runtime									
N	normal	zcache	%change						
8	284	280	1%						
12	283	281	1%						
16	281	280	0%						
20	289	310	-7%						
24	322	311	3%						
28	347	325	6%						
32	437	378	14%						
									
%CPU utilization (out of 400% on 4 cpus)
N	normal	zcache	%change						
8	245	245	0%						
12	249	251	-1%						
16	252	252	0%						
20	247	255	-3%						
24	221	230	-4%						
28	204	219	-7%						
32	162	187	-15%						

Some of my runtime curve N vs %change doesn't match up with
Dan's probably due to differing swap device speeds and I think
my .config had less to build so the runtime magnitudes are less.

Runtime %change will be effected by the swap device speed. But
the I/O reductions are less related to swap device speed and, IMHO,
really show the value of zcache.

Environments with shared storage could particularly like this.
You could enable swap on your machines and frontswap+zcache
would give you an early warning system for memory pressure.
If frontswap starts picking up pages, the admin can get a
warning and zcache will mitigate the swap I/O impacting the
SAN while something is done to relieve the memory pressure.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
