Received: by nf-out-0910.google.com with SMTP id h3so1058893nfh
        for <linux-mm@kvack.org>; Mon, 12 Nov 2007 20:27:35 -0800 (PST)
Message-ID: <2c0942db0711122027m5b11502cveded5705c0bc4f64@mail.gmail.com>
Date: Mon, 12 Nov 2007 20:27:34 -0800
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
In-Reply-To: <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
	 <200711130059.34346.ak@suse.de>
	 <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
	 <200711130149.54852.ak@suse.de>
	 <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <ak@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Nov 12, 2007 7:42 PM, Christoph Lameter <clameter@sgi.com> wrote:
> Ok here is the patch to remove DISCONTIG and FLATMEM
>
> x86_64: Make sparsemem/vmemmap the default memory model
>
> Use sparsemem as the only memory model for UP, SMP and NUMA.
> Measurements indicate that DISCONTIGMEM has a higher overhead
> than sparsemem. And FLATMEMs benefits are minimal. So I think its
> best to simply standardize on sparsemem.
>
> Results of page allocator tests (test can be had via git from slab git
> tree branch tests)
>
> Measurements in cycle counts. 1000 allocations were performed and then the
> average cycle count was calculated.
>
> Order   FlatMem Discontig       SparseMem
> 0         639     665             641
> 1         567     647             593
> 2         679     774             692
> 3         763     967             781
> 4         961    1501             962
> 5        1356    2344            1392
> 6        2224    3982            2336
> 7        4869    7225            5074
> 8       12500   14048           12732
> 9       27926   28223           28165
> 10      58578   58714           58682

Discontig obviously needs to die. However, FlatMem is consistently
faster, averaging about 2.1% better overall for your numbers above. Is
the page allocator not, erm, a fast path, where that matters?

Order	Flat	Sparse	% diff
0	639	641	0.3
1	567	593	4.4
2	679	692	1.9
3	763	781	2.3
4	961	962	0.1
5	1356	1392	2.6
6	2224	2336	4.8
7	4869	5074	4.0
8	12500	12732	1.8
9	27926	28165	0.8
10	58578	58682	0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
