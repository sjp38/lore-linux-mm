Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C51446B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:37:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h16so12809074wrf.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:37:45 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g16si6972651wrb.337.2017.09.26.07.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 07:37:44 -0700 (PDT)
Date: Tue, 26 Sep 2017 16:37:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170926143743.GB18758@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-2-ross.zwisler@linux.intel.com> <20170925233812.GM10955@dastard> <20170926093548.GB13627@quack2.suse.cz> <20170926110957.GR10955@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926110957.GR10955@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 09:09:57PM +1000, Dave Chinner wrote:
> Well, quite frankly, I never wanted the mount option for XFS. It was
> supposed to be for initial testing only, then we'd /always/ use the
> the inode flags. For a filesystem to default to using DAX, we
> set the DAX flag on the root inode at mkfs time, and then everything
> inode flag based just works.

And I deeply fundamentally disagree.  The mount option is a nice
enough big hammer to try a mode without encoding nitty gritty details
into the application ABI.

The per-inode persistent flag is the biggest nightmare ever, as we see
in all these discussions about it.

What does it even mean?  Right now it forces direct addressing as long
as the underlying media supports that.  But what about media that
you directly access but you really don't want to because it's really slow?
Or media that is so god damn fast that you never want to buffer?  Or
media where you want to buffer for writes (or at least some of them)
but not for reads?

It encodes a very specific mechanism for an early direct access
implementation into the ABI.  What we really need is for applications
to declare an intent, not specify a particular mechanism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
