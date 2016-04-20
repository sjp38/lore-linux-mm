Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 842946B029A
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:59:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so108783998pfe.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 13:59:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h18si8545614pfd.5.2016.04.20.13.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 13:59:28 -0700 (PDT)
Date: Wed, 20 Apr 2016 13:59:23 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160420205923.GA24797@infradead.org>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-nvdimm@ml01.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, linux-block@vger.kernel.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Apr 15, 2016 at 12:11:36PM -0400, Jeff Moyer wrote:
> > +	if (IS_DAX(inode)) {
> > +		ret = dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
> >  				NULL, DIO_SKIP_DIO_COUNT);
> > +		if (ret == -EIO && (iov_iter_rw(iter) == WRITE))
> > +			ret_saved = ret;
> > +		else
> > +			return ret;
> > +	}
> > +
> > +	ret = __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
> >  				    blkdev_get_block, NULL, NULL,
> >  				    DIO_SKIP_DIO_COUNT);
> > +	if (ret < 0 && ret_saved)
> > +		return ret_saved;
> > +
> 
> Hmm, did you just break async DIO?  I think you did!  :)
> __blockdev_direct_IO can return -EIOCBQUEUED, and you've now turned that
> into -EIO.  Really, I don't see a reason to save that first -EIO.  The
> same applies to all instances in this patch.

Yes, there is no point in saving the earlier error - just return the
second error all the time.

E.g.

	ret = dax_io();
	if (dax_need_dio_retry(ret))
		ret = direct_IO();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
