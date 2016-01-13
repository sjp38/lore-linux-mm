Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 47015828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:07:35 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l65so284239948wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:07:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si566279wjx.223.2016.01.13.01.07.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 01:07:34 -0800 (PST)
Date: Wed, 13 Jan 2016 10:07:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 1/9] dax: fix NULL pointer dereference in __dax_dbg()
Message-ID: <20160113090734.GC14630@quack.suse.cz>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-2-git-send-email-ross.zwisler@linux.intel.com>
 <20160112093458.GR6262@quack.suse.cz>
 <20160113070829.GA30496@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113070829.GA30496@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Wed 13-01-16 00:08:29, Ross Zwisler wrote:
> On Tue, Jan 12, 2016 at 10:34:58AM +0100, Jan Kara wrote:
> > On Thu 07-01-16 22:27:51, Ross Zwisler wrote:
> > > In __dax_pmd_fault() we currently assume that get_block() will always set
> > > bh.b_bdev and we unconditionally dereference it in __dax_dbg().  This
> > > assumption isn't always true - when called for reads of holes
> > > ext4_dax_mmap_get_block() returns a buffer head where bh->b_bdev is never
> > > set.  I hit this BUG while testing the DAX PMD fault path.
> > > 
> > > Instead, initialize bh.b_bdev before passing bh into get_block().  It is
> > > possible that the filesystem's get_block() will update bh.b_bdev, and this
> > > is fine - we just want to initialize bh.b_bdev to something reasonable so
> > > that the calls to __dax_dbg() work and print something useful.
> > > 
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > 
> > Looks good. But don't you need to do the same for __dax_fault(),
> > dax_zero_page_range() and similar places passing bh to dax functions?
> > 
> > 								Honza
> 
> I don't think we need it anywhere else.  The only reason that we need to
> initialize the bh.b_bdev manually in the __dax_pmd_fault() path is that if the
> get_block() call ends up finding a hole (so doesn't fill out b_bdev) we still
> go through the dax_pmd_dbg() path to print an error message, which uses
> b_bdev.  I believe that in the other paths where we hit a hole, such as
> __dax_fault(), we don't use b_bdev because we don't have the same error path
> prints, and the regular code for handling holes doesn't use b_bdev.
> 
> That being said, if you feel like it's cleaner to initialize it
> everywhere so everything is consistent and we don't have to worry about
> it, I'm fine to make the change.

Well, it seems more futureproof to me. In case someone decides to add some
debug message later on...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
