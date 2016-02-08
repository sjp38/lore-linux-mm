Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CEC25828E4
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 13:31:29 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so77363660pab.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 10:31:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 76si48072242pfk.107.2016.02.08.10.31.28
        for <linux-mm@kvack.org>;
        Mon, 08 Feb 2016 10:31:28 -0800 (PST)
Date: Mon, 8 Feb 2016 11:31:12 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160208183112.GF2343@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
 <1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, jmoyer <jmoyer@redhat.com>

On Sun, Feb 07, 2016 at 11:13:51AM -0800, Dan Williams wrote:
> The proposal: make applications explicitly request DAX semantics with
> a new MAP_DAX flag and fail if DAX is unavailable.  Document that a
> successful MAP_DAX request mandates that the application assumes
> responsibility for cpu cache management.  

> Require that all applications that mmap the file agree on MAP_DAX.

I think this proposal could run into issues with aliasing.  For example, say
you have two threads accessing the same region, and one wants to use DAX and
the other wants to use the page cache.  What happens?

If we satisfy both requests, we end up with one user reading and writing to
the page cache, while the other is reading and writing directly to the media.
They can't see each other's changes, and you get data corruption.

If we satisfy the request of whoever asked first, sort of lock the inode into
that mode, and then return an error to the second thread because they are
asking for the other mode, we have now introduced a new weird failure case
where mmaps can randomly fail based on the behavior of other applications.
I think this is where you were going with the last line quoted above, but I
don't understand how it would work in an acceptable way.

It seems like we have to have the decision about whether or not to use DAX
made in the same way for all users of the inode so that we don't run into
these types of conflicts.

> This also solves
> the future problem of DAX support on virtually tagged cache
> architectures where it is difficult for the kernel to know what alias
> addresses need flushing.
> 
> [1]: https://github.com/pmem/nvml

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
