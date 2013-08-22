Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BE94A6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:42:18 -0400 (EDT)
Date: Thu, 22 Aug 2013 09:42:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 0/5] zram/zsmalloc promotion
Message-ID: <20130822004250.GB4665@bbox>
References: <1377065791-2959-1-git-send-email-minchan@kernel.org>
 <52148730.4000709@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52148730.4000709@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, lliubbo@gmail.com

Hi Bob,

On Wed, Aug 21, 2013 at 05:24:00PM +0800, Bob Liu wrote:
> Hi Minchan,
> 
> On 08/21/2013 02:16 PM, Minchan Kim wrote:
> > It's 7th trial of zram/zsmalloc promotion.
> > I rewrote cover-letter totally based on previous discussion.
> > 
> > The main reason to prevent zram promotion was no review of
> > zsmalloc part while Jens, block maintainer, already acked
> > zram part.
> > 
> > At that time, zsmalloc was used for zram, zcache and zswap so
> > everybody wanted to make it general and at last, Mel reviewed it
> > when zswap was submitted to merge mainline a few month ago.
> > Most of review was related to zswap writeback mechanism which
> > can pageout compressed page in memory into real swap storage
> > in runtime and the conclusion was that zsmalloc isn't good for
> > zswap writeback so zswap borrowed zbud allocator from zcache to
> > replace zsmalloc. The zbud is bad for memory compression ratio(2)
> > but it's very predictable behavior because we can expect a zpage
> > includes just two pages as maximum. Other reviews were not major. 
> > http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
> > 
> > Zcache doesn't use zsmalloc either so zsmalloc's user is only
> > zram now so this patchset moves it into zsmalloc directory.
> > Recently, Bob tried to move zsmalloc under mm directory to unify
> > zram and zswap with adding pseudo block device in zswap(It's
> > very weired to me) but he was simple ignoring zram's block device
> > (a.k.a zram-blk) feature and considered only swap usecase of zram,
> > in turn, it lose zram's good concept.
> > 
> 
> Yes, I didn't notice the feature that zram can be used as a normal block
> device.
> 
> 
> > Mel raised an another issue in v6, "maintainance headache".
> > He claimed zswap and zram has a similar goal that is to compresss
> > swap pages so if we promote zram, maintainance headache happens
> > sometime by diverging implementaion between zswap and zram
> > so that he want to unify zram and zswap. For it, he want zswap
> > to implement pseudo block device like Bob did to emulate zram so
> > zswap can have an advantage of writeback as well as zram's benefit.
> 
> If consider zram as a swap device only, I still think it's better to add
> a pseudo block device to zswap and just disable the writeback of zswap.

Why do you think zswap is better?

> 
> But I have no idea of zram's block device feature.
> 
> > But I wonder frontswap-based zswap's writeback is really good
> > approach for writeback POV. I think that problem isn't only
> > specific for zswap. If we want to configure multiple swap hierarchy
> > with various speed device such as RAM, NVRAM, SSD, eMMC, NAS etc,
> > it would be a general problem. So we should think of more general
> > approach. At a glance, I can see two approach.
> > 
> > First, VM could be aware of heterogeneous swap configuration
> > so it could aim for being able to configure cache hierarchy
> > among swap devices. It may need indirction layer on swap, which
> > was already talked about that way so VM can migrate a block from 
> > A to B easily. It will support various configuration with VM's
> > hints, maybe, in future.
> > http://lkml.indiana.edu/hypermail/linux/kernel/1203.3/03812.html
> > 
> > Second, as more practical solution, we could use device mapper like
> > dm-cache(https://lwn.net/Articles/540996/), which makes it very
> > flexible. Now, it supports various configruation and cache policy
> > (block size, writeback/writethrough, LRU, MFU although MQ is merged
> > now) so it would be good fit for our purpose. Even, it can make zram
> > support writeback. I tested it following as following scenario
> > in KVM 4 CPU, 1G DRAM with background 800M memory hogger, which is
> > allocates random data up to 800M.
> > 
> > 1) zram swap disk 1G, untar kernel.tgz to tmpfs, build -j 4
> >    Fail to untar due to shortage of memory space by tmpfs default size limit
> > 
> > 2) zram swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
> >    OOM happens while building the kernel but it untar successfully
> >    on ext2 based on zram-blk. The reason OOM happend is zram can not find
> >    free pages from main memory to store swap out pages although empty
> >    swap space is still enough.
> > 
> > 3) dm-cache swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
> >    dmcache consists of zram-meta 10M, zram-cache 1G and real swap storage 1G
> >    No OOM happens and successfully building done.
> > 
> > Above tests proves zram can support writeback into real swap storage
> > so that zram-cache can always have a free space. If necessary, we could
> > add new plugin in dm-cache. I see It's really flexible and well-layered
> > architecure so zram-blk's concept is good for us and it has lots of
> > potential to be enhanced by MM/FS/Block developers. 
> > 
> 
> That's an exciting direction!

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
