Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 232B66B0253
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 04:11:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m72so5595564wmc.0
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 01:11:42 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j130si428492wmd.165.2017.10.21.01.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 01:11:41 -0700 (PDT)
Date: Sat, 21 Oct 2017 10:11:40 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 12/13] dax: handle truncate of dma-busy pages
Message-ID: <20171021081140.GA21101@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com> <150846720244.24336.16885325309403883980.stgit@dwillia2-desk3.amr.corp.intel.com> <1508504726.5572.41.camel@kernel.org> <CAPcyv4hXCJYTkUKs6NiOp=8kgExu+bgZnVn_v+Os7fVUc2NxFg@mail.gmail.com> <20171020163221.GB26320@lst.de> <CAPcyv4iGN6KO_ggJ-vTHCPWanudY3Gq6n=+9sbnMsnTeF56uJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iGN6KO_ggJ-vTHCPWanudY3Gq6n=+9sbnMsnTeF56uJA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-xfs@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Oct 20, 2017 at 10:27:22AM -0700, Dan Williams wrote:
> I'll take a look at hooking this up through a page-idle callback. Can
> I get some breadcrumbs to grep for from XFS folks on how to set/clear
> the busy state of extents?

As Brian pointed out it's the xfs_extent_busy.c file (and I pointed
out the same in a reply to the previous series).  Be careful because
you'll need a refcount or flags now that there are different busy
reasons.

I still think we'd be better off just blocking on an elevated page
count directly in truncate as that will avoid all the busy list
manipulations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
