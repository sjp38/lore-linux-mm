Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 188846B0261
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:15:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so226935758pfx.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:15:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a96si27718689pli.233.2016.11.28.11.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:15:09 -0800 (PST)
Date: Mon, 28 Nov 2016 12:15:04 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/6] dax: fix build breakage with ext4, dax and !iomap
Message-ID: <20161128191504.GB6637@linux.intel.com>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-2-git-send-email-ross.zwisler@linux.intel.com>
 <20161124090239.GA24138@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161124090239.GA24138@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Nov 24, 2016 at 10:02:39AM +0100, Jan Kara wrote:
> On Wed 23-11-16 11:44:17, Ross Zwisler wrote:
> > With the current Kconfig setup it is possible to have the following:
> > 
> > CONFIG_EXT4_FS=y
> > CONFIG_FS_DAX=y
> > CONFIG_FS_IOMAP=n	# this is in fs/Kconfig & isn't user accessible
> > 
> > With this config we get build failures in ext4_dax_fault() because the
> > iomap functions in fs/dax.c are missing:
> > 
> > fs/built-in.o: In function `ext4_dax_fault':
> > file.c:(.text+0x7f3ac): undefined reference to `dax_iomap_fault'
> > file.c:(.text+0x7f404): undefined reference to `dax_iomap_fault'
> > fs/built-in.o: In function `ext4_file_read_iter':
> > file.c:(.text+0x7fc54): undefined reference to `dax_iomap_rw'
> > fs/built-in.o: In function `ext4_file_write_iter':
> > file.c:(.text+0x7fe9a): undefined reference to `dax_iomap_rw'
> > file.c:(.text+0x7feed): undefined reference to `dax_iomap_rw'
> > fs/built-in.o: In function `ext4_block_zero_page_range':
> > inode.c:(.text+0x85c0d): undefined reference to `iomap_zero_range'
> > 
> > Now that the struct buffer_head based DAX fault paths and I/O path have
> > been removed we really depend on iomap support being present for DAX.  Make
> > this explicit by selecting FS_IOMAP if we compile in DAX support.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> I've sent the same patch to Ted yesterday and he will probably queue it on
> top of ext4 iomap patches. If it doesn't happen for some reason, feel free
> to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Cool, looks like Ted has pulled in your patch.

I think we still eventually want this patch because it cleans up our handling
of FS_IOMAP.  With your patch we select it separately in both ext4 & ext2
based on whether we include DAX, and we still have #ifdefs in fs/dax.c for
FS_IOMAP.

I'll pull your most recent patch into my baseline & rework this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
