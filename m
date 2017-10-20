Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88D736B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:47:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g90so5364286wrd.14
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 00:47:52 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y6si348824wrb.228.2017.10.20.00.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 00:47:51 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:47:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove
	'page-less' support
Message-ID: <20171020074750.GA13568@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jeff Moyer <jmoyer@redhat.com>, hch@lst.de, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-nvdimm@lists.01.org, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

> The solution presented is not pretty. It creates a stream of leases, one
> for each get_user_pages() invocation, and polls page reference counts
> until DMA stops. We're missing a reliable way to not only trap the
> DMA-idle event, but also block new references being taken on pages while
> truncate is allowed to progress. "[PATCH v3 12/13] dax: handle truncate of
> dma-busy pages" presents other options considered, and notes that this
> solution can only be viewed as a stop-gap.

I'd like to brainstorm how we can do something better.

How about:

If we hit a page with an elevated refcount in truncate / hole puch
etc for a DAX file system we do not free the blocks in the file system,
but add it to the extent busy list.  We mark the page as delayed
free (e.g. page flag?) so that when it finally hits refcount zero we
call back into the file system to remove it from the busy list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
