Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 677CB280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:13:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so265775307pgb.14
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:13:43 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i30si2531035pgn.845.2017.08.20.23.13.41
        for <linux-mm@kvack.org>;
        Sun, 20 Aug 2017 23:13:41 -0700 (PDT)
Date: Mon, 21 Aug 2017 15:13:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170821061339.GA2544@bbox>
References: <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
 <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
 <20170814150620.GA12657@bgram>
 <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
 <20170814153059.GA13497@bgram>
 <0c83e7af-10a4-3462-bb4c-4254adcf6f7a@kernel.dk>
 <058b4ae5-c6e9-ff32-6440-fb1e1b85b6fd@kernel.dk>
 <20170816044759.GC24294@blaptop>
 <1046cd1e-35f2-2663-4886-64e6e4f2093c@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1046cd1e-35f2-2663-4886-64e6e4f2093c@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

Hi Jens,

On Wed, Aug 16, 2017 at 09:56:12AM -0600, Jens Axboe wrote:
> On 08/15/2017 10:48 PM, Minchan Kim wrote:
> > Hi Jens,
> > 
> > On Mon, Aug 14, 2017 at 10:17:09AM -0600, Jens Axboe wrote:
> >> On 08/14/2017 09:38 AM, Jens Axboe wrote:
> >>> On 08/14/2017 09:31 AM, Minchan Kim wrote:
> >>>>> Secondly, generally you don't have slow devices and fast devices
> >>>>> intermingled when running workloads. That's the rare case.
> >>>>
> >>>> Not true. zRam is really popular swap for embedded devices where
> >>>> one of low cost product has a really poor slow nand compared to
> >>>> lz4/lzo [de]comression.
> >>>
> >>> I guess that's true for some cases. But as I said earlier, the recycling
> >>> really doesn't care about this at all. They can happily coexist, and not
> >>> step on each others toes.
> >>
> >> Dusted it off, result is here against -rc5:
> >>
> >> http://git.kernel.dk/cgit/linux-block/log/?h=cpu-alloc-cache
> >>
> >> I'd like to split the amount of units we cache and the amount of units
> >> we free, right now they are both CPU_ALLOC_CACHE_SIZE. This means that
> >> once we hit that count, we free all of the, and then store the one we
> >> were asked to free. That always keeps 1 local, but maybe it'd make more
> >> sense to cache just free CPU_ALLOC_CACHE_SIZE/2 (or something like that)
> >> so that we retain more than 1 per cpu in case and app preempts when
> >> sleeping for IO and the new task on that CPU then issues IO as well.
> >> Probably minor.
> >>
> >> Ran a quick test on nullb0 with 32 sync readers. The test was O_DIRECT
> >> on the block device, so I disabled the __blkdev_direct_IO_simple()
> >> bypass. With the above branch, we get ~18.0M IOPS, and without we get
> >> ~14M IOPS. Both ran with iostats disabled, to avoid any interference
> >> from that.
> > 
> > Looks promising.
> > If recycling bio works well enough, I think we don't need to introduce
> > new split in the path for on-stack bio.
> > I will test your version on zram-swap!
> 
> Thanks, let me know how it goes. It's quite possible that we'll need
> a few further tweaks, but at least the basis should be there.

Sorry for my late reply.

I just finished the swap-in testing in with zram-swap which is critical
for the latency.

For the testing, I made a memcc and put $NR_CPU(mine is 12) processes
in there and each processes consumes 1G so total is 12G while my system
has 16GB memory so there was no global reclaim.
Then, echo 1 > /mnt/memcg/group/force.empty to swap all pages out and
then the programs wait my signal to swap in and I trigger the signal
to every processes to swap in every pages and measures elapsed time
for the swapin.

the value is average usec time elapsed swap-in 1G pages for each process
and I repeated it 10times and stddev is very stable.

swapin:
base(with rw_page)      1100806.73(100.00%)
no-rw_page              1146856.95(104.18%)
Jens's pcp              1146910.00(104.19%)
onstack-bio             1114872.18(101.28%)

In my test, there is no difference between dynamic bio allocation
(i.e., no-rwpage) and pcp approch but onstack-bio is much faster
so it's almost same with rw_page.

swapout test is to measure elapsed time for "echo 1 > /mnt/memcg/test_group/force.empty'
so it's sec unit.

swapout:
base(with rw_page)      7.72(100.00%)
no-rw_page              8.36(108.29%)
Jens's pcp              8.31(107.64%)
onstack-bio             8.19(106.09%)

rw_page's swapout is 6% or more than faster than else.

I tried pmbenchmak with no memcg to see the performance in global reclaim.
Also, I executed background IO job which reads data from HDD.
The value is average usec time elapsed for a page access so smaller is
better.

base(with rw_page)              14.42(100.00%)
no-rw_page                      15.66(108.60%)
Jens's pcp                      15.81(109.64%)
onstack-bio                     15.42(106.93%)

It's similar to swapout test in memcg.
6% or more is not trivial so I doubt we can remove rw_page
at this moment. :(

I will look into the detail with perf.
If you have further optimizations or suggestions, Feel free to
say that. I am happy to test it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
