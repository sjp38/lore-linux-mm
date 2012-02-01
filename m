Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 33D266B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:13:45 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
References: <1327996780.21268.42.camel@sli10-conroe>
	<20120131220333.GD4378@redhat.com>
	<20120131141301.ba35ffe0.akpm@linux-foundation.org>
	<20120131222217.GE4378@redhat.com> <20120201033653.GA12092@redhat.com>
	<20120201091807.GA7451@infradead.org>
	<20120201201017.GC13246@redhat.com>
Date: Wed, 01 Feb 2012 15:13:32 -0500
In-Reply-To: <20120201201017.GC13246@redhat.com> (Vivek Goyal's message of
	"Wed, 1 Feb 2012 15:10:17 -0500")
Message-ID: <x49y5smpb0z.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

Vivek Goyal <vgoyal@redhat.com> writes:

> On Wed, Feb 01, 2012 at 04:18:07AM -0500, Christoph Hellwig wrote:
>> On Tue, Jan 31, 2012 at 10:36:53PM -0500, Vivek Goyal wrote:
>> > I still see that IO is being submitted one page at a time. The only
>> > real difference seems to be that queue unplug happening at random times
>> > and many a times we are submitting much smaller requests (40 sectors, 48
>> > sectors etc).
>> 
>> This is expected given that the block device node uses
>> block_read_full_page, and not mpage_readpage(s).
>
> What is the difference between block_read_full_page() and
> mpage_readpage(). IOW, why block device does not use mpage_readpage(s)
> interface?
>
> Is enabling mpage_readpages() on block devices is as simple as following
> patch or more is involved? (I suspect it has to be more than this. If it
> was this simple, it would have been done by now).
>
> This patch complies and seems to work. (system does not crash and dd
> seems to be working. I can't verify the contents of the file though).
>
> Applying following patch improved the speed from 110MB/s to more than
> 230MB/s.
>
> # dd if=/dev/sdb of=/dev/null bs=1M count=1K
> 1024+0 records in
> 1024+0 records out
> 1073741824 bytes (1.1 GB) copied, 4.6269 s, 232 MB/s

See:
commit db2dbb12dc47a50c7a4c5678f526014063e486f6
Author: Jeff Moyer <jmoyer@redhat.com>
Date:   Wed Apr 22 14:08:13 2009 +0200

    block: implement blkdev_readpages
    
    Doing a proper block dev ->readpages() speeds up the crazy dump(8)
    approach of using interleaved process IO.
    
    Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

And:

commit 172124e220f1854acc99ee394671781b8b5e2120
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Thu Jun 4 22:34:44 2009 +0200

    Revert "block: implement blkdev_readpages"
    
    This reverts commit db2dbb12dc47a50c7a4c5678f526014063e486f6.
    
    It apparently causes problems with partition table read-ahead
    on archs with large page sizes. Until that problem is diagnosed
    further, just drop the readpages support on block devices.
    
    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

;-)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
