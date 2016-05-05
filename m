Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDB946B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 10:24:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so117328016pac.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 07:24:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id pv8si11675584pac.134.2016.05.05.07.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 07:24:34 -0700 (PDT)
Date: Thu, 5 May 2016 07:24:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Message-ID: <20160505142433.GA4557@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
 <5727753F.6090104@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5727753F.6090104@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Mon, May 02, 2016 at 06:41:51PM +0300, Boaz Harrosh wrote:
> > All IO in a dax filesystem used to go through dax_do_io, which cannot
> > handle media errors, and thus cannot provide a recovery path that can
> > send a write through the driver to clear errors.
> > 
> > Add a new iocb flag for DAX, and set it only for DAX mounts. In the IO
> > path for DAX filesystems, use the same direct_IO path for both DAX and
> > direct_io iocbs, but use the flags to identify when we are in O_DIRECT
> > mode vs non O_DIRECT with DAX, and for O_DIRECT, use the conventional
> > direct_IO path instead of DAX.
> > 
> 
> Really? What are your thinking here?
> 
> What about all the current users of O_DIRECT, you have just made them
> 4 times slower and "less concurrent*" then "buffred io" users. Since
> direct_IO path will queue an IO request and all.
> (And if it is not so slow then why do we need dax_do_io at all? [Rhetorical])
> 
> I hate it that you overload the semantics of a known and expected
> O_DIRECT flag, for special pmem quirks. This is an incompatible
> and unrelated overload of the semantics of O_DIRECT.

Agreed - makig O_DIRECT less direct than not having it is plain stupid,
and I somehow missed this initially.

This whole DAX story turns into a major nightmare, and I fear all our
hodge podge tweaks to the semantics aren't helping it.

It seems like we simply need an explicit O_DAX for the read/write
bypass if can't sort out the semantics (error, writer synchronization)
just as we need a special flag for MMAP..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
