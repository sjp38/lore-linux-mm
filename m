Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B732D6B025F
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:59:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w65so13048926oia.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:59:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s23sor3792770oie.87.2017.09.26.06.59.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 06:59:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926063234.GA6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-4-ross.zwisler@linux.intel.com> <20170926063234.GA6870@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 26 Sep 2017 06:59:37 -0700
Message-ID: <CAPcyv4hKb1PshbjLxyWz2fdj=dK2fi2qgJLFaT9pVnmaOoWV6g@mail.gmail.com>
Subject: Re: [PATCH 3/7] xfs: protect S_DAX transitions in XFS read path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 11:32 PM, Christoph Hellwig <hch@lst.de> wrote:
> We can't just take locking one level up, as we need differnet locking
> for different kinds of I/O.
>
> I think you probably want an IOCB_DAX flag to check IS_DAX once and
> then stick to it, similar to what we do for direct I/O.

I wonder if this works better with a reference count mechanism
per-file so that we don't need a hold a lock over the whole
transition. Similar to request_queue reference counting, when DAX is
being turned off we block new references and drain the in-flight ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
