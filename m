Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F138B6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:57:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so5213341wmu.19
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 23:57:18 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c1si292091wrf.90.2017.10.12.23.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 23:57:17 -0700 (PDT)
Date: Fri, 13 Oct 2017 08:57:16 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171013065716.GB26461@lst.de>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com> <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

On Thu, Oct 12, 2017 at 10:41:39AM -0700, Dan Williams wrote:
> So, you're jumping into this review at v9 where I've split the patches
> that take an initial MAP_DIRECT lease out from the patches that take
> FL_LAYOUT leases at memory registration time. You can see a previous
> attempt in "[PATCH v8 00/14] MAP_DIRECT for DAX RDMA and userspace
> flush" which should be in your inbox.

The point is that your problem has absolutely nothing to do with mmap,
and all with get_user_pages.

get_user_pages on DAX doesn't give the same guarantees as on pagecache
or anonymous memory, and that is the prbolem we need to fix.  In fact
I'm pretty sure if we try hard enough (and we might have to try
very hard) we can see the same problem with plain direct I/O and without
any RDMA involved, e.g. do a larger direct I/O write to memory that is
mmap()ed from a DAX file, then truncate the DAX file and reallocate
the blocks, and we might corrupt that new file.  We'll probably need
a special setup where there is little other chance but to reallocate
those used blocks.

So what we need to do first is to fix get_user_pages vs unmapping
DAX mmap()ed blocks, be that from a hole punch, truncate, COW
operation, etc.

Then we need to look into the special case of a long-living non-transient
get_user_pages that RDMA does - we can't just reject any truncate or
other operation for that, so that's where something like me layout
lease suggestion comes into play - but the call that should get the
least is not the mmap - it's the memory registration call that does
the get_user_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
