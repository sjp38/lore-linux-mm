Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66D306B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:51:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so359293614pfy.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:51:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id o86si2010256pfi.217.2016.05.02.08.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:51:34 -0700 (PDT)
Message-ID: <1462204291.11211.20.camel@kernel.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
From: Vishal Verma <vishal@kernel.org>
Date: Mon, 02 May 2016 09:51:31 -0600
In-Reply-To: <5727753F.6090104@plexistor.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	 <5727753F.6090104@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org
Cc: linux-block@vger.kernel.org, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ext4@vger.kernel.org

On Mon, 2016-05-02 at 18:41 +0300, Boaz Harrosh wrote:
> On 04/29/2016 12:16 AM, Vishal Verma wrote:
> > 
> > All IO in a dax filesystem used to go through dax_do_io, which
> > cannot
> > handle media errors, and thus cannot provide a recovery path that
> > can
> > send a write through the driver to clear errors.
> > 
> > Add a new iocb flag for DAX, and set it only for DAX mounts. In the
> > IO
> > path for DAX filesystems, use the same direct_IO path for both DAX
> > and
> > direct_io iocbs, but use the flags to identify when we are in
> > O_DIRECT
> > mode vs non O_DIRECT with DAX, and for O_DIRECT, use the
> > conventional
> > direct_IO path instead of DAX.
> > 
> Really? What are your thinking here?
> 
> What about all the current users of O_DIRECT, you have just made them
> 4 times slower and "less concurrent*" then "buffred io" users. Since
> direct_IO path will queue an IO request and all.
> (And if it is not so slow then why do we need dax_do_io at all?
> [Rhetorical])
> 
> I hate it that you overload the semantics of a known and expected
> O_DIRECT flag, for special pmem quirks. This is an incompatible
> and unrelated overload of the semantics of O_DIRECT.

We overloaded O_DIRECT a long time ago when we made DAX piggyback on
the same path:

static inline bool io_is_direct(struct file *filp)
{
	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
}

Yes O_DIRECT on a DAX mounted file system will now be slower, but -

> 
> > 
> > This allows us a recovery path in the form of opening the file with
> > O_DIRECT and writing to it with the usual O_DIRECT semantics
> > (sector
> > alignment restrictions).
> > 
> I understand that you want a sector aligned IO, right? for the
> clear of errors. But I hate it that you forced all O_DIRECT IO
> to be slow for this.
> Can you not make dax_do_io handle media errors? At least for the
> parts of the IO that are aligned.
> (And your recovery path application above can use only aligned
> A IO to make sure)
> 
> Please look for another solution. Even a special
> IOCTL_DAX_CLEAR_ERROR

A - see all the versions of this series prior to this one, where we try
to do a fallback...

> 
> [*"less concurrent" because of the queuing done in bdev. Note how
> A  pmem is not even multi-queue, and even if it was it will be much
> A  slower then DAX because of the code depth and all the locks and
> task
> A  switches done in the block layer. In DAX the final memcpy is done
> directly
> A  on the user-mode thread]
> 
> Thanks
> Boaz
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
