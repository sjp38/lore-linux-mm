Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5A18B6B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:04:44 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so2290629wes.7
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 05:04:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si1068518wiz.24.2014.04.09.05.04.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 05:04:42 -0700 (PDT)
Date: Wed, 9 Apr 2014 14:04:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140409120437.GA7715@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

  I've noticed one more thing here:

On Sun 23-03-14 15:08:32, Matthew Wilcox wrote:
....
> +ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
> +		const struct iovec *iov, loff_t offset, unsigned nr_segs,
> +		get_block_t get_block, dio_iodone_t end_io, int flags)
> +{
...
> +	retval = dax_io(rw, inode, iov, offset, end, get_block, &bh);
> +
> +	if ((flags & DIO_LOCKING) && (rw == READ))
> +		mutex_unlock(&inode->i_mutex);
> +
> +	inode_dio_done(inode);
> +
> +	if ((retval > 0) && end_io)
> +		end_io(iocb, offset, retval, bh.b_private);
  In direct IO code, we first call end_io() callback and do
inode_dio_done() only after that. Since filesystems use i_dio_count for
protecting against different races, calling end_io() after inode_dio_done()
can open all sorts of subtle races.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
