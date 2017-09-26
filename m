Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3DE6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 17:06:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f84so19635173pfj.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:06:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u8si6426084plh.71.2017.09.26.14.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 14:06:47 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:06:45 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Message-ID: <20170926210645.GA7798@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-7-ross.zwisler@linux.intel.com>
 <CAPcyv4jtO028KeZK7SdkOUsgMLGqgttLzBCYgH0M+RP3eAXf4A@mail.gmail.com>
 <20170926185751.GB31146@linux.intel.com>
 <CAPcyv4iVc9y8PE24ZvkiBYdp4Die0Q-K5S6QexW_6YQ_M0F4QA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iVc9y8PE24ZvkiBYdp4Die0Q-K5S6QexW_6YQ_M0F4QA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 12:19:21PM -0700, Dan Williams wrote:
> On Tue, Sep 26, 2017 at 11:57 AM, Ross Zwisler
<>
> > This decision can only be made (in this
> > proposed scheme) *after* the inode->i_mapping->i_mmap  tree has been
> > populated, which means we need another call into the filesystem after this
> > insertion has happened.
> 
> I get that, but it seems over-engineered and something that can also
> be safely cleaned up after the fact by the code path that is disabling
> DAX.

I don't think you can safely clean it up after the fact because some thread
might have already called ->mmap() to set up the vma->vm_flags for their new
mapping, but they haven't added it to inode->i_mapping->i_mmap.

The inode->i_mapping->i_mmap tree is the only way (that I know of at least)
that the filesystem has any idea about about the mapping.  This is the method
by which we would try and clean up mapping flags, if we were to do so, and
it's the only way that the filesystem can know whether or not mappings exist.

The only way that I could think of to make this safely work is to have the
insertion into the inode->i_mapping->i_mmap tree be our sync point.  After
that the filesystem and the mapping code can communicate on the state of DAX,
but before that I think it's basically indeterminate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
