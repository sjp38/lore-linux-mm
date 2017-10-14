Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD2016B027C
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 22:25:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a12so7923550qka.7
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 19:25:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 18sor1561047qks.155.2017.10.13.19.25.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 19:25:20 -0700 (PDT)
Date: Fri, 13 Oct 2017 22:25:18 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v6 1/4] cramfs: direct memory access support
In-Reply-To: <20171014003151.GK21978@ZenIV.linux.org.uk>
Message-ID: <nycvar.YSQ.7.76.1710132204420.1750@knanqh.ubzr>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org> <20171012061613.28705-2-nicolas.pitre@linaro.org> <20171013172934.GG21978@ZenIV.linux.org.uk> <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr> <20171013175208.GI21978@ZenIV.linux.org.uk>
 <nycvar.YSQ.7.76.1710131532291.1750@knanqh.ubzr> <20171014003151.GK21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Sat, 14 Oct 2017, Al Viro wrote:

> On Fri, Oct 13, 2017 at 04:09:23PM -0400, Nicolas Pitre wrote:
> > On Fri, 13 Oct 2017, Al Viro wrote:
> > 
> > > OK...  I wonder if it should simply define stubs for kill_mtd_super(),
> > > mtd_unpoint() and kill_block_super() in !CONFIG_MTD and !CONFIG_BLOCK
> > > cases.  mount_mtd() and mount_bdev() as well - e.g.  mount_bdev()
> > > returning ERR_PTR(-ENODEV) and kill_block_super() being simply BUG()
> > > in !CONFIG_BLOCK case.  Then cramfs_kill_sb() would be
> > > 	if (sb->s_mtd) {
> > > 		if (sbi->mtd_point_size)
> > > 			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> > > 		kill_mtd_super(sb);
> > > 	} else {
> > > 		kill_block_super(sb);
> > > 	}
> > > 	kfree(sbi);
> > 
> > Well... Stubs have to be named differently or they conflict with 
> > existing declarations. At that point that makes for more lines of code 
> > compared to the current patch and the naming indirection makes it less 
> > obvious when reading the code. Alternatively I could add those stubs in 
> > the corresponding header files and #ifdef the existing declarations 
> > away. That might look somewhat less cluttered in the main code but it 
> > also hides what is actually going on and left me unconvinced. And I'm 
> > not sure this is worth it in the end given this is not a common 
> > occurrence in the kernel either.
> 
> What I mean is this (completely untested) for CONFIG_BLOCK side of things,
> with something similar for CONFIG_MTD one:
> 
> Provide definitions of mount_bdev/kill_block_super() in case !CONFIG_BLOCK

Yes, that's what I thought you meant, which corresponds to the second 
part of my comment above. And as I said I'm not convinced this hiding of 
kernel config effects is better for understanding what is actually going 
on locally, and my own preference is how things are right now.

But if you confirm you really want things that other way then I'll 
oblige and repost.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
