Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 454916B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:34:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n64so1866585wrb.18
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:34:00 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h77si1723160wma.152.2017.09.26.07.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 07:33:58 -0700 (PDT)
Date: Tue, 26 Sep 2017 16:33:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/7] xfs: protect S_DAX transitions in XFS read path
Message-ID: <20170926143357.GA18758@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-4-ross.zwisler@linux.intel.com> <20170926063234.GA6870@lst.de> <CAPcyv4hKb1PshbjLxyWz2fdj=dK2fi2qgJLFaT9pVnmaOoWV6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hKb1PshbjLxyWz2fdj=dK2fi2qgJLFaT9pVnmaOoWV6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 06:59:37AM -0700, Dan Williams wrote:
> > I think you probably want an IOCB_DAX flag to check IS_DAX once and
> > then stick to it, similar to what we do for direct I/O.
> 
> I wonder if this works better with a reference count mechanism
> per-file so that we don't need a hold a lock over the whole
> transition. Similar to request_queue reference counting, when DAX is
> being turned off we block new references and drain the in-flight ones.

Maybe.  But that assumes we want to be stuck in a perpetual binary
DAX on/off state on a given file.  Which makes not only for an awkward
interface (inode or mount flag), but also might be fundamentally the
wrong thing to do for some media where you'd happily read directly
from it but rather buffer writes in DRAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
