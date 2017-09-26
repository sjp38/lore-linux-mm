Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C371E6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:11:56 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a74so14182320oib.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 11:11:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 61sor882802ota.520.2017.09.26.11.11.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 11:11:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926143357.GA18758@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-4-ross.zwisler@linux.intel.com> <20170926063234.GA6870@lst.de>
 <CAPcyv4hKb1PshbjLxyWz2fdj=dK2fi2qgJLFaT9pVnmaOoWV6g@mail.gmail.com> <20170926143357.GA18758@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 26 Sep 2017 11:11:55 -0700
Message-ID: <CAPcyv4g=oPXgNJs0E15y_wAKMOMC32Jfjw4HxWGSH+OLss-efg@mail.gmail.com>
Subject: Re: [PATCH 3/7] xfs: protect S_DAX transitions in XFS read path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 7:33 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Tue, Sep 26, 2017 at 06:59:37AM -0700, Dan Williams wrote:
>> > I think you probably want an IOCB_DAX flag to check IS_DAX once and
>> > then stick to it, similar to what we do for direct I/O.
>>
>> I wonder if this works better with a reference count mechanism
>> per-file so that we don't need a hold a lock over the whole
>> transition. Similar to request_queue reference counting, when DAX is
>> being turned off we block new references and drain the in-flight ones.
>
> Maybe.  But that assumes we want to be stuck in a perpetual binary
> DAX on/off state on a given file.  Which makes not only for an awkward
> interface (inode or mount flag), but also might be fundamentally the
> wrong thing to do for some media where you'd happily read directly
> from it but rather buffer writes in DRAM.

I think we'll always need an explicit override available, but yes we
need to think about what the override looks like in the context of a
kernel that is able to automatically pick the right I/O policy
relative to the media type. A potential mixed policy for reads vs
writes makes sense. Where would this finer grained I/O policy
selection go other than more inode flags?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
