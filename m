Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD5B6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 14:18:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a12so6566464qka.7
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:18:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s51sor1094198qtk.42.2017.10.13.11.18.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 11:18:56 -0700 (PDT)
Date: Fri, 13 Oct 2017 14:18:55 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v6 1/4] cramfs: direct memory access support
In-Reply-To: <20171013175208.GI21978@ZenIV.linux.org.uk>
Message-ID: <nycvar.YSQ.7.76.1710131356360.1652@knanqh.ubzr>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org> <20171012061613.28705-2-nicolas.pitre@linaro.org> <20171013172934.GG21978@ZenIV.linux.org.uk> <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr> <20171013175208.GI21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Fri, 13 Oct 2017, Al Viro wrote:

> On Fri, Oct 13, 2017 at 01:39:13PM -0400, Nicolas Pitre wrote:
> > On Fri, 13 Oct 2017, Al Viro wrote:
> > 
> > > On Thu, Oct 12, 2017 at 02:16:10AM -0400, Nicolas Pitre wrote:
> > > 
> > > >  static void cramfs_kill_sb(struct super_block *sb)
> > > >  {
> > > >  	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> > > >  
> > > > -	kill_block_super(sb);
> > > > +	if (IS_ENABLED(CCONFIG_CRAMFS_MTD)) {
> > > > +		if (sbi->mtd_point_size)
> > > > +			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> > > > +		if (sb->s_mtd)
> > > > +			kill_mtd_super(sb);
> > > 
> > > ...
> > > 
> > > > +	mtd_unpoint(sb->s_mtd, 0, PAGE_SIZE);
> > > > +	err = mtd_point(sb->s_mtd, 0, sbi->size, &sbi->mtd_point_size,
> > > > +			&sbi->linear_virt_addr, &sbi->linear_phys_addr);
> > > > +	if (err || sbi->mtd_point_size != sbi->size) {
> > > 
> > > What happens if that mtd_point() fails?  Note that ->kill_sb() will be
> > > called anyway and ->mtd_point_size is going to be non-zero here...
> > 
> > mtd_point() always clears sbi->mtd_point_size first thing upon entry 
> > even before it has a chance to fail. So it it fails then 
> > sbi->mtd_point_size will be zero and ->kill_sb() will skip the unpoint 
> > call.
> 
> OK...  I wonder if it should simply define stubs for kill_mtd_super(),
> mtd_unpoint() and kill_block_super() in !CONFIG_MTD and !CONFIG_BLOCK
> cases.  mount_mtd() and mount_bdev() as well - e.g.  mount_bdev()
> returning ERR_PTR(-ENODEV) and kill_block_super() being simply BUG()
> in !CONFIG_BLOCK case.  Then cramfs_kill_sb() would be
> 	if (sb->s_mtd) {
> 		if (sbi->mtd_point_size)
> 			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> 		kill_mtd_super(sb);
> 	} else {
> 		kill_block_super(sb);
> 	}
> 	kfree(sbi);

What I really like about IS_ENABLED() usage is the immediate build 
coverage without having to run all config combinations. The compiler 
will discard unneeded code and avoid pesky unused variable warnings that 
require ugly #ifdefs otherwise.

> Wait.  Looking at that code... what happens if you hit this failure
> exit:
>         sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
>         if (!sbi)
>                 return -ENOMEM;
> 
> Current cramfs_kill_sb() will do kill_block_super() and kfree(NULL), which
> works nicely, but you are dereferencing that sucker, not just passing it
> to kfree().  IOW, that if (sbi->....) ought to be if (sbi && sbi->...)

Right, good catch.
Fixed in my tree now.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
