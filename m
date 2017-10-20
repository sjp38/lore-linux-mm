Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B224F6B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:31:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k15so5491600wrc.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:31:50 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n17si518377wrg.297.2017.10.20.02.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 02:31:49 -0700 (PDT)
Date: Fri, 20 Oct 2017 11:31:48 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove
	'page-less' support
Message-ID: <20171020093148.GA20304@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com> <20171020074750.GA13568@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020074750.GA13568@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jeff Moyer <jmoyer@redhat.com>, hch@lst.de, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-nvdimm@lists.01.org, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Oct 20, 2017 at 09:47:50AM +0200, Christoph Hellwig wrote:
> I'd like to brainstorm how we can do something better.
> 
> How about:
> 
> If we hit a page with an elevated refcount in truncate / hole puch
> etc for a DAX file system we do not free the blocks in the file system,
> but add it to the extent busy list.  We mark the page as delayed
> free (e.g. page flag?) so that when it finally hits refcount zero we
> call back into the file system to remove it from the busy list.

Brainstorming some more:

Given that on a DAX file there shouldn't be any long-term page
references after we unmap it from the page table and don't allow
get_user_pages calls why not wait for the references for all
DAX pages to go away first?  E.g. if we find a DAX page in
truncate_inode_pages_range that has an elevated refcount we set
a new flag to prevent new references from showing up, and then
simply wait for it to go away.  Instead of a busy way we can
do this through a few hashed waitqueued in dev_pagemap.  And in
fact put_zone_device_page already gets called when putting the
last page so we can handle the wakeup from there.

In fact if we can't find a page flag for the stop new callers
things we could probably come up with a way to do that through
dev_pagemap somehow, but I'm not sure how efficient that would
be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
