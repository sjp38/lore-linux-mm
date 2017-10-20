Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72F496B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 13:27:25 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t134so11651027oih.6
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 10:27:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23sor666864oth.274.2017.10.20.10.27.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 10:27:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020163221.GB26320@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150846720244.24336.16885325309403883980.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1508504726.5572.41.camel@kernel.org> <CAPcyv4hXCJYTkUKs6NiOp=8kgExu+bgZnVn_v+Os7fVUc2NxFg@mail.gmail.com>
 <20171020163221.GB26320@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 10:27:22 -0700
Message-ID: <CAPcyv4iGN6KO_ggJ-vTHCPWanudY3Gq6n=+9sbnMsnTeF56uJA@mail.gmail.com>
Subject: Re: [PATCH v3 12/13] dax: handle truncate of dma-busy pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-xfs@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Oct 20, 2017 at 9:32 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, Oct 20, 2017 at 08:42:00AM -0700, Dan Williams wrote:
>> I agree, but it needs quite a bit more thought and restructuring of
>> the truncate path. I also wonder how we reclaim those stranded
>> filesystem blocks, but a first approximation is wait for the
>> administrator to delete them or auto-delete them at the next mount.
>> XFS seems well prepared to reflink-swap these DMA blocks around, but
>> I'm not sure about EXT4.
>
> reflink still is an optional and experimental feature in XFS.  That
> being said we should not need to swap block pointers around on disk.
> We just need to prevent the block allocator from reusing the blocks
> for new allocations, and we have code for that, both for transactions
> that haven't been committed to disk yet, and for deleted blocks
> undergoing discard operations.
>
> But as mentioned in my second mail from this morning I'm not even
> sure we need that.  For short-term elevated page counts like normal
> get_user_pages users I think we can just wait for the page count
> to reach zero, while for abuses of get_user_pages for long term
> pinning memory (not sure if anyone but rdma is doing that) we'll need
> something like FL_LAYOUT leases to release the mapping.

I'll take a look at hooking this up through a page-idle callback. Can
I get some breadcrumbs to grep for from XFS folks on how to set/clear
the busy state of extents?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
