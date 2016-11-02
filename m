Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DECF36B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 04:32:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o20so1780887lfg.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 01:32:08 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 89si568814lfq.363.2016.11.02.01.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 01:32:07 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id i187so527463lfe.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 01:32:06 -0700 (PDT)
Date: Wed, 2 Nov 2016 11:32:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161102083204.GB13949@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161101163940.GA5459@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Nov 01, 2016 at 05:39:40PM +0100, Jan Kara wrote:
> On Mon 31-10-16 21:10:35, Kirill A. Shutemov wrote:
> > > If I understand the motivation right, it is mostly about being able to mmap
> > > PMD-sized chunks to userspace. So my naive idea would be that we could just
> > > implement it by allocating PMD sized chunks of pages when adding pages to
> > > page cache, we don't even have to read them all unless we come from PMD
> > > fault path.
> > 
> > Well, no. We have one PG_{uptodate,dirty,writeback,mappedtodisk,etc}
> > per-hugepage, one common list of buffer heads...
> > 
> > PG_dirty and PG_uptodate behaviour inhered from anon-THP (where handling
> > it otherwise doesn't make sense) and handling it differently for file-THP
> > is nightmare from maintenance POV.
> 
> But the complexity of two different page sizes for page cache and *each*
> filesystem that wants to support it does not make the maintenance easy
> either.

I think with time we can make small pages just a subcase of huge pages.
And some generalization can be made once more than one filesystem with
backing storage will adopt huge pages.

> So I'm not convinced that using the same rules for anon-THP and
> file-THP is a clear win.

We already have file-THP with the same rules: tmpfs. Backing storage is
what changes the picture.

> And if we have these two options neither of which has negligible
> maintenance cost, I'd also like to see more justification for why it is
> a good idea to have file-THP for normal filesystems. Do you have any
> performance numbers that show it is a win under some realistic workload?

See below. As usual with huge pages, they make sense when you plenty of
memory.

> I'd also note that having PMD-sized pages has some obvious disadvantages as
> well:
>
> 1) I'm not sure buffer head handling code will quite scale to 512 or even
> 2048 buffer_heads on a linked list referenced from a page. It may work but
> I suspect the performance will suck.

Yes, buffer_head list doesn't scale. That's the main reason (along with 4)
why syscall-based IO sucks. We spend a lot of time looking for desired
block.

We need to switch to some other data structure for storing buffer_heads.
Is there a reason why we have list there in first place?
Why not just array?

I will look into it, but this sounds like a separate infrastructure change
project.

> 2) PMD-sized pages result in increased space & memory usage.

Space? Do you mean disk space? Not really: we still don't write beyond
i_size or into holes.

Behaviour wrt to holes may change with mmap()-IO as we have less
granularity, but the same can be seen just between different
architectures: 4k vs. 64k base page size.

> 3) In ext4 we have to estimate how much metadata we may need to modify when
> allocating blocks underlying a page in the worst case (you don't seem to
> update this estimate in your patch set). With 2048 blocks underlying a page,
> each possibly in a different block group, it is a lot of metadata forcing
> us to reserve a large transaction (not sure if you'll be able to even
> reserve such large transaction with the default journal size), which again
> makes things slower.

I didn't saw this on profiles. And xfstests looks fine. I probably need to
run them with 1k blocks once again.

> 4) As you have noted some places like write_begin() still depend on 4k
> pages which creates a strange mix of places that use subpages and that use
> head pages.

Yes, this need to be addressed to restore syscall-IO performance and take
advantage of huge pages.

But again, it's an infrastructure change that would likely affect
interface between VFS and filesystems. It deserves a separate patchset.

> All this would be a non-issue (well, except 2 I guess) if we just didn't
> expose filesystems to the fact that something like file-THP exists.

The numbers below generated with fio. The working set is relatively small,
so it fits into page cache and writing set doesn't hit dirty_ratio.

I think the mmap performance should be enough to justify initial inclusion
of an experimental feature: it useful for workloads that targets mmap()-IO.
It will take time to get feature mature anyway.

Configuration:
 - 2x E5-2697v2, 64G RAM;
 - INTEL SSDSC2CW24;
 - IO request size is 4k;
 - 8 processes, 512MB data set each;

Workload
 read/write	baseline	stddev	huge=always	stddev		change
--------------------------------------------------------------------------------
sync-read
 read		  21439.00	348.14	  20297.33	259.62		 -5.33%
sync-write
 write		   6833.20	147.08	   3630.13	 52.86		-46.88%
sync-readwrite
 read		   4377.17	 17.53	   2366.33	 19.52		-45.94%
 write		   4378.50	 17.83	   2365.80	 19.94		-45.97%
sync-randread
 read		   5491.20	 66.66	  14664.00	288.29		167.05%
sync-randwrite
 write		   6396.13	 98.79	   2035.80	  8.17		-68.17%
sync-randrw
 read		   2927.30	115.81	   1036.08	 34.67		-64.61%
 write		   2926.47	116.45	   1036.11	 34.90		-64.60%
libaio-read
 read		    254.36	 12.49	    258.63	 11.29		  1.68%
libaio-write
 write		   4979.20	122.75	   2904.77	 17.93		-41.66%
libaio-readwrite
 read		   2738.57	142.72	   2045.80	  4.12		-25.30%
 write		   2729.93	141.80	   2039.77	  3.79		-25.28%
libaio-randread
 read		    113.63	  2.98	    210.63	  5.07		 85.37%
libaio-randwrite
 write		   4456.10	 76.21	   1649.63	  7.00		-62.98%
libaio-randrw
 read		     97.85	  8.03	    877.49	 28.27		796.80%
 write		     97.55	  7.99	    874.83	 28.19		796.77%
mmap-read
 read		  20654.67	304.48	  24696.33	1064.07		 19.57%
mmap-write
 write		   8652.33	272.44	  13187.33	499.10		 52.41%
mmap-readwrite
 read		   6620.57	 16.05	   9221.60	399.56		 39.29%
 write		   6623.63	 16.34	   9222.13	399.31		 39.23%
mmap-randread
 read		   6717.23	1360.55	  21939.33	326.38		226.61%
mmap-randwrite
 write		   3204.63	253.66	  12371.00	 61.49		286.03%
mmap-randrw
 read		   2150.50	 78.00	   7682.67	188.59		257.25%
 write		   2149.50	 78.00	   7685.40	188.35		257.54%

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
