Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 943E36B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:54:01 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id bk3so37057803wjc.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:54:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u82si10997148wme.75.2016.11.30.23.54.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 23:54:00 -0800 (PST)
Date: Thu, 1 Dec 2016 08:53:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] dax: fix build breakage with ext4, dax and !iomap
Message-ID: <20161201075356.GA12804@quack2.suse.cz>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-2-git-send-email-ross.zwisler@linux.intel.com>
 <20161124090239.GA24138@quack2.suse.cz>
 <20161128191504.GB6637@linux.intel.com>
 <20161129085303.GA7550@quack2.suse.cz>
 <20161130190431.GA11793@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130190431.GA11793@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed 30-11-16 12:04:31, Ross Zwisler wrote:
> On Tue, Nov 29, 2016 at 09:53:03AM +0100, Jan Kara wrote:
> > On Mon 28-11-16 12:15:04, Ross Zwisler wrote:
> > > On Thu, Nov 24, 2016 at 10:02:39AM +0100, Jan Kara wrote:
> > > > On Wed 23-11-16 11:44:17, Ross Zwisler wrote:
> > > > > With the current Kconfig setup it is possible to have the following:
> > > > > 
> > > > > CONFIG_EXT4_FS=y
> > > > > CONFIG_FS_DAX=y
> > > > > CONFIG_FS_IOMAP=n	# this is in fs/Kconfig & isn't user accessible
> > > > > 
> > > > > With this config we get build failures in ext4_dax_fault() because the
> > > > > iomap functions in fs/dax.c are missing:
> > > > > 
> > > > > fs/built-in.o: In function `ext4_dax_fault':
> > > > > file.c:(.text+0x7f3ac): undefined reference to `dax_iomap_fault'
> > > > > file.c:(.text+0x7f404): undefined reference to `dax_iomap_fault'
> > > > > fs/built-in.o: In function `ext4_file_read_iter':
> > > > > file.c:(.text+0x7fc54): undefined reference to `dax_iomap_rw'
> > > > > fs/built-in.o: In function `ext4_file_write_iter':
> > > > > file.c:(.text+0x7fe9a): undefined reference to `dax_iomap_rw'
> > > > > file.c:(.text+0x7feed): undefined reference to `dax_iomap_rw'
> > > > > fs/built-in.o: In function `ext4_block_zero_page_range':
> > > > > inode.c:(.text+0x85c0d): undefined reference to `iomap_zero_range'
> > > > > 
> > > > > Now that the struct buffer_head based DAX fault paths and I/O path have
> > > > > been removed we really depend on iomap support being present for DAX.  Make
> > > > > this explicit by selecting FS_IOMAP if we compile in DAX support.
> > > > > 
> > > > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > > 
> > > > I've sent the same patch to Ted yesterday and he will probably queue it on
> > > > top of ext4 iomap patches. If it doesn't happen for some reason, feel free
> > > > to add:
> > > > 
> > > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > 
> > > Cool, looks like Ted has pulled in your patch.
> > > 
> > > I think we still eventually want this patch because it cleans up our handling
> > > of FS_IOMAP.  With your patch we select it separately in both ext4 & ext2
> > > based on whether we include DAX, and we still have #ifdefs in fs/dax.c for
> > > FS_IOMAP.
> > 
> > Actually, based on Dave's request I've also sent Ted updated version which
> > did select FS_IOMAP in CONFIG_DAX section. However Ted didn't pull that
> > patch (yet?). Anyway, I don't care whose patch gets merged, I just wanted
> > to notify you of possible conflict.
> 
> Can you please CC me on these patches in the future?  I also don't care whose
> patches end up fixing this, but I want to make sure we end up in a world where
> the "select FS_IOMAP" just happens directly for FS_DAX in fs/Kconfig so that
> I can get rid of the unnecessary #ifdefs in fs/dax.c for CONFIG_FS_IOMAP.

Sure, will do.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
