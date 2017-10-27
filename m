Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFBE6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:45:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q127so2858040wmd.1
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 23:45:29 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v7si5190823wra.534.2017.10.26.23.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 23:45:27 -0700 (PDT)
Date: Fri, 27 Oct 2017 08:45:27 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove
	'page-less' support
Message-ID: <20171027064526.GD22931@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com> <20171020074750.GA13568@lst.de> <20171020093148.GA20304@lst.de> <20171026105850.GA31161@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026105850.GA31161@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jeff Moyer <jmoyer@redhat.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-nvdimm@lists.01.org, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Oct 26, 2017 at 12:58:50PM +0200, Jan Kara wrote:
> But are we guaranteed page refs are short term? E.g. if someone creates
> v4l2 videobuf in MAP_SHARED mapping of a file on DAX filesystem, page refs
> can be rather long-term similarly as in RDMA case. Also freeing of blocks
> on page reference drop is another async entry point into the filesystem
> which could unpleasantly surprise us but I guess workqueues would solve
> that reasonably fine.

The point is that we need to prohibit long term elevated page counts
with DAX anyway - we can't just let people grab allocated blocks forever
while ignoring file system operations.  For stage 1 we'll just need to
fail those, and in the long run they will have to use a mechanism
similar to FL_LAYOUT locks to deal with file system allocation changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
