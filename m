Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C01B6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:15:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so28407632pgn.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:15:13 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q5si1570463pgp.174.2017.09.27.09.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 09:15:12 -0700 (PDT)
Date: Wed, 27 Sep 2017 10:15:10 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20170927161510.GB24314@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-2-ross.zwisler@linux.intel.com>
 <20170925233812.GM10955@dastard>
 <20170926093548.GB13627@quack2.suse.cz>
 <20170926110957.GR10955@dastard>
 <20170926143743.GB18758@lst.de>
 <20170926173057.GB20159@linux.intel.com>
 <20170927064001.GA27601@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927064001.GA27601@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 11:40:01PM -0700, Christoph Hellwig wrote:
> On Tue, Sep 26, 2017 at 11:30:57AM -0600, Ross Zwisler wrote:
> > I agree that Christoph's idea about having the system intelligently adjust to
> > use DAX based on performance information it gathers about the underlying
> > persistent memory (probably via the HMAT on x86_64 systems) is interesting,
> > but I think we're still a ways away from that.
> 
> So what are the missing blockers for a getting started?

Well, I don't know if platforms that support HMAT + PMEM are widely available,
but we have all the details in the ACPI spec, so we could begin to code it up
and things will "just work" when platforms arrive.

> > FWIW, as my patches suggest and Jan observed I think that we should allow
> > users to turn on DAX by treating the inode flag and the mount flag as an 'or'
> > operation.  i.e. you get DAX if either the mount option is specified or if the
> > inode flag is set, and you can continue to manipulate the per-inode flag as
> > you want regardless of the mount option.  I think this provides maximum
> > flexibility of the mechanism to select DAX without enforcing policy.
> 
> IFF we stick to the dax flag that's the only workable way.  The only
> major issue I still see with that is that this allows unprivilegued
> users to enable DAX on a any file they own / have write access to.
> So there isn't really any way to effectively disable the DAX path
> by the sysadmin.

Hum, I wonder if maybe we need/want three different mount modes?  What about:

autodax (the default): the filesystem is free to use DAX or not, as it sees
fit and thinks is optimal.  For the time being we can make this mean "don't
use DAX", and phase in DAX usage as we add support for the HMAT, etc.

Users can manually turn on DAX for a given inode by setting the DAX inode
flag, but there is no way for the user to *prevent* DAX for an inode - the
kernel can always choose to turn it on.

MAP_DIRECT and MAP_SYNC work.

nodax: Don't use DAX.  The kernel won't choose to use DAX, and any DAX inode
flags will be ignored.  This gives the sysadmin the override that I think
you're looking for.  The user can still manipulate the inode flags as they see
fit.

MAP_DIRECT and MAP_SYNC both fail.

dax: Use DAX for all inodes in the filesystem.  Again the inode flags are
essentially ignored, but the user can manipulate the inode flags as they see
fit.  This is basically unchanged from how it works today, modulo the bug
where DAX can get turned off if you unset the inode flag where it wasn't even
set (patch 1 in my series).

MAP_DIRECT and MAP_SYNC work.

> > Does it make sense at this point to just start a "dax" man page that can
> > contain info about the mount options, inode flags, kernel config options, how
> > to get PMDs, etc?  Or does this documentation need to be sprinkled around more
> > in existing man pages?
> 
> A dax manpage would be good.

Okay, I'll start with a manpage, and once we agree on whats in there we can
start working on code again. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
