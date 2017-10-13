Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB5676B025F
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:52:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w105so362076wrc.20
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:52:12 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id o9si1251556wrg.17.2017.10.13.10.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 10:52:11 -0700 (PDT)
Date: Fri, 13 Oct 2017 18:52:08 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 1/4] cramfs: direct memory access support
Message-ID: <20171013175208.GI21978@ZenIV.linux.org.uk>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
 <20171012061613.28705-2-nicolas.pitre@linaro.org>
 <20171013172934.GG21978@ZenIV.linux.org.uk>
 <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Fri, Oct 13, 2017 at 01:39:13PM -0400, Nicolas Pitre wrote:
> On Fri, 13 Oct 2017, Al Viro wrote:
> 
> > On Thu, Oct 12, 2017 at 02:16:10AM -0400, Nicolas Pitre wrote:
> > 
> > >  static void cramfs_kill_sb(struct super_block *sb)
> > >  {
> > >  	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> > >  
> > > -	kill_block_super(sb);
> > > +	if (IS_ENABLED(CCONFIG_CRAMFS_MTD)) {
> > > +		if (sbi->mtd_point_size)
> > > +			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> > > +		if (sb->s_mtd)
> > > +			kill_mtd_super(sb);
> > 
> > ...
> > 
> > > +	mtd_unpoint(sb->s_mtd, 0, PAGE_SIZE);
> > > +	err = mtd_point(sb->s_mtd, 0, sbi->size, &sbi->mtd_point_size,
> > > +			&sbi->linear_virt_addr, &sbi->linear_phys_addr);
> > > +	if (err || sbi->mtd_point_size != sbi->size) {
> > 
> > What happens if that mtd_point() fails?  Note that ->kill_sb() will be
> > called anyway and ->mtd_point_size is going to be non-zero here...
> 
> mtd_point() always clears sbi->mtd_point_size first thing upon entry 
> even before it has a chance to fail. So it it fails then 
> sbi->mtd_point_size will be zero and ->kill_sb() will skip the unpoint 
> call.

OK...  I wonder if it should simply define stubs for kill_mtd_super(),
mtd_unpoint() and kill_block_super() in !CONFIG_MTD and !CONFIG_BLOCK
cases.  mount_mtd() and mount_bdev() as well - e.g.  mount_bdev()
returning ERR_PTR(-ENODEV) and kill_block_super() being simply BUG()
in !CONFIG_BLOCK case.  Then cramfs_kill_sb() would be
	if (sb->s_mtd) {
		if (sbi->mtd_point_size)
			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
		kill_mtd_super(sb);
	} else {
		kill_block_super(sb);
	}
	kfree(sbi);

Wait.  Looking at that code... what happens if you hit this failure
exit:
        sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
        if (!sbi)
                return -ENOMEM;

Current cramfs_kill_sb() will do kill_block_super() and kfree(NULL), which
works nicely, but you are dereferencing that sucker, not just passing it
to kfree().  IOW, that if (sbi->....) ought to be if (sbi && sbi->...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
