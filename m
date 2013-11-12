Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2C96B00E8
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 10:41:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so6690580pab.21
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 07:41:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id ei3si19934542pbc.290.2013.11.12.07.41.52
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 07:41:53 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id lj1so3707917pab.13
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 07:41:51 -0800 (PST)
Date: Wed, 13 Nov 2013 00:41:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
Message-ID: <20131112154137.GA3330@gmail.com>
References: <20131107070451.GA10645@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131107070451.GA10645@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, riel@redhat.com, hughd@google.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Luigi Semenzato <semenzato@google.com>

On Thu, Nov 07, 2013 at 04:04:51PM +0900, Minchan Kim wrote:
> On Wed, Nov 06, 2013 at 07:05:11PM -0800, Greg KH wrote:
> > On Wed, Nov 06, 2013 at 03:46:19PM -0800, Nitin Gupta wrote:
> >  > I'm getting really tired of them hanging around in here for many years
> > > > now...
> > > >
> > > 
> > > Minchan has tried many times to promote zram out of staging. This was
> > > his most recent attempt:
> > > 
> > > https://lkml.org/lkml/2013/8/21/54
> > > 
> > > There he provided arguments for zram inclusion, how it can help in
> > > situations where zswap can't and why generalizing /dev/ramX would
> > > not be a great idea. So, cannot say why it wasn't picked up
> > > for inclusion at that time.
> > > 
> > > > Should I just remove them if no one is working on getting them merged
> > > > "properly"?
> > > >
> > > 
> > > Please refer the mail thread (link above) and see Minchan's
> > > justifications for zram.
> > > If they don't sound convincing enough then please remove zram+zsmalloc
> > > from staging.
> > 
> > You don't need to be convincing me, you need to be convincing the
> > maintainers of the area of the kernel you are working with.
> > 
> > And since the last time you all tried to get this merged was back in
> > August, I'm feeling that you all have given up, so it needs to be
> > deleted.  I'll go do that for 3.14, and if someone wants to pick it up
> > and merge it properly, they can easily revert it.
> 
> I'm guilty and I have been busy by other stuff. Sorry for that.
> Fortunately, I discussed this issue with Hugh in this Linuxcon for a
> long time(Thanks Hugh!) he felt zram's block device abstraction is
> better design rather than frontswap backend stuff although it's a question
> where we put zsmalloc. I will CC Hugh because many of things is related
> to swap subsystem and his opinion is really important.
> And I discussed it with Rik and he feel positive about zram.
> 
> Last impression Andrw gave me by private mail is he want to merge
> zram's functionality into zswap or vise versa.
> If I misunderstood, please correct me.
> I understand his concern but I guess he didn't have a time to read
> my long description due to a ton of works at that time.
> So, I will try one more time.
> I hope I'd like to listen feedback than *silence* so that we can
> move forward than stall.
> 
> Recently, Bob tried to move zsmalloc under mm directory to unify
> zram and zswap with adding pseudo block device in zswap(It's
> very weired to me. I think it's horrible monster which is lying
> between mm and block in layering POV) but he was ignoring zram's
> block device (a.k.a zram-blk) feature and considered only swap
> usecase of zram, in turn, it lose zram's good concept. 
> I already convered other topics Bob raised in this thread[1]
> and why I think zram is better in the thread.
> 
> Will repeat one more time and hope gray beards penguins grab a
> time in this time and they give a conclusion/direction to me so
> that we don't lose lots of user and functionality.
> 
> ========== &< ===========
> 
> Mel raised an another issue in v6, "maintainance headache".
> He claimed zswap and zram has a similar goal that is to compresss
> swap pages so if we promote zram, maintainance headache happens
> sometime by diverging implementaion between zswap and zram
> so that he want to unify zram and zswap. For it, he want zswap
> to implement pseudo block device like Bob did to emulate zram so
> zswap can have an advantage of writeback as well as zram's benefit.
> But I wonder frontswap-based zswap's writeback is really good
> approach for writeback POV. I think that problem isn't only
> specific for zswap. If we want to configure multiple swap hierarchy
> with various speed device such as RAM, NVRAM, SSD, eMMC, NAS etc,
> it would be a general problem. So we should think of more general
> approach. At a glance, I can see two approach.
> 
> First, VM could be aware of heterogeneous swap configuration
> so it could aim for being able to configure cache hierarchy
> among swap devices. It may need indirction layer on swap, which
> was already talked about that way so VM can migrate a block from
> A to B easily. It will support various configuration with VM's
> hints, maybe, in future.
> http://lkml.indiana.edu/hypermail/linux/kernel/1203.3/03812.html
> 
> Second, as more practical solution, we could use device mapper like
> dm-cache(https://lwn.net/Articles/540996/), which makes it very
> flexible. Now, it supports various configruation and cache policy
> (block size, writeback/writethrough, LRU, MFU although MQ is merged
> now) so it would be good fit for our purpose. Even, it can make zram
> support writeback. I tested it following as following scenario
> in KVM 4 CPU, 1G DRAM with background 800M memory hogger, which is
> allocates random data up to 800M.
> 
> 1) zram swap disk 1G, untar kernel.tgz to tmpfs, build -j 4
>    Fail to untar due to shortage of memory space by tmpfs default size limit
> 
> 2) zram swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
>    OOM happens while building the kernel but it untar successfully
>    on ext2 based on zram-blk. The reason OOM happend is zram can not find
>    free pages from main memory to store swap out pages although empty
>    swap space is still enough.
> 
> 3) dm-cache swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
>    dmcache consists of zram-meta 10M, zram-cache 1G and real swap storage 1G
>    No OOM happens and successfully building done.
> 
> Above tests proves zram can support writeback into real swap storage
> so that zram-cache can always have a free space. If necessary, we could
> add new plugin in dm-cache. I see It's really flexible and well-layered
> architecure so zram-blk's concept is good for us and it has lots of
> potential to be enhanced by MM/FS/Block developers.
> 
> As other disadvantage of zswap writeback, frontswap's semantic is
> synchronous API so zswap should decompress in memory zpage
> right before writeback and even, it writes pages one by one,
> not a batch. If we extend frontswap API, we would enhance it but
> I belive we can do better in device mapper layer which is aware of
> block align, bandwidth, mapping table, asynchronous and lots of hints
> from the block layer. Nonetheless, if we should merge zram's
> functionality to zswap, I think zram should include zswap's
> functionaliy(But I hope it will never happen) because old age zram
> already has lots of real users rather than new young zswap so it's
> more handy to unify them with keeping changelog which is one of
> valuable things getting from staging stay for a long time.
> 
> The reason zram doesn't support writeback until now is just shortage
> of needs. The zram's main customers were embedded people so writeback
> into real swap storage is too bad for interactivity and wear-leveling
> on low falsh devices. But like above, zram has a potential to support
> writeback with other block drivers or more reasonable VM enhance
> so I'd like to claim zram's block concept is really good.
> 
> Another zram-blk's usecase is following as.
> The admin can format /dev/zramX with any FS and mount on it.
> It could help small memory system, too. For exmaple, many embedded
> system don't have swap so although tmpfs can support swapout,
> it's pointless. Then, let's assume temp file growing up until half
> of system memory once in a while. We don't want to write it on flash
> by wear-leveing issue and response problem so we want to keep in-memory.
> But if we use tmpfs, it should evict half of working set to cover them
> when the size reach peak. In the case, zram-blk would be good fit, too.
> 
> I'd like to enhance zram with more features like zsmalloc-compaction,
> , async I/O, parallel decompression and so on but zram developers cannot
> do it now because Greg, staging maintainer, doesn't want to add new feature
> until promotion is done because zram have been in staging for a very long time.
> Acutally, some patches about enhance are pending for a long time.
> 
> [1] https://lkml.org/lkml/2013/8/21/141
> 

Hello Andrew,

I'd like to listen your opinion.

The zram promotion trial started since Aug 2012 and I already have get many
Acked/Reviewed feedback and positive feedback from Rik and Bob in this thread.
(ex, Jens Axboe[1], Konrad Rzeszutek Wilk[2], Nitin Gupta[3], Pekka Enberg[4])
In Linuxcon, Hugh gave positive feedback about zram(Hugh, If I misunderstood,
please correct me!). And there are lots of users already in embedded industry
ex, (most of TV in the world, Chromebook, CyanogenMod, Android Kitkat.)
They are not idiot. Zram is really effective for embedded world.

We spent much time with preventing zram enhance since it have been in staging
and Greg never want to improve without promotion.

Please consider promotion and let us improve it.
I think only remained thing is your decision.


1. https://lkml.org/lkml/2012/9/11/551
2. https://lkml.org/lkml/2012/8/9/636
3. https://lkml.org/lkml/2012/8/8/390
4. https://lkml.org/lkml/2012/9/26/126

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
