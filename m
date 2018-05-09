Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A67D6B059C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 18:54:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u13-v6so114456oif.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 15:54:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n126-v6sor12983808oib.270.2018.05.09.15.54.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 15:54:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180509122733.lokyqv5aluwhlml7@quack2.suse.cz>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152461283072.17530.11313844322317294220.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180509122733.lokyqv5aluwhlml7@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 9 May 2018 15:54:16 -0700
Message-ID: <CAPcyv4hwGc0GUST-bNrgpgrmnfHgcxKf35M8p8mnu2FbSJe7Qw@mail.gmail.com>
Subject: Re: [PATCH v9 9/9] xfs, dax: introduce xfs_break_dax_layouts()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, May 9, 2018 at 5:27 AM, Jan Kara <jack@suse.cz> wrote:
> On Tue 24-04-18 16:33:50, Dan Williams wrote:
>> xfs_break_dax_layouts(), similar to xfs_break_leased_layouts(), scans
>> for busy / pinned dax pages and waits for those pages to go idle before
>> any potential extent unmap operation.
>>
>> dax_layout_busy_page() handles synchronizing against new page-busy
>> events (get_user_pages). It invalidates all mappings to trigger the
>> get_user_pages slow path which will eventually block on the xfs inode
>> lock held in XFS_MMAPLOCK_EXCL mode. If dax_layout_busy_page() finds a
>> busy page it returns it for xfs to wait for the page-idle event that
>> will fire when the page reference count reaches 1 (recall ZONE_DEVICE
>> pages are idle at count 1, see generic_dax_pagefree()).
>>
>> While waiting, the XFS_MMAPLOCK_EXCL lock is dropped in order to not
>> deadlock the process that might be trying to elevate the page count of
>> more pages before arranging for any of them to go idle. I.e. the typical
>> case of submitting I/O is that iov_iter_get_pages() elevates the
>> reference count of all pages in the I/O before starting I/O on the first
>> page. The process of elevating the reference count of all pages involved
>> in an I/O may cause faults that need to take XFS_MMAPLOCK_EXCL.
>>
>> Although XFS_MMAPLOCK_EXCL is dropped while waiting, XFS_IOLOCK_EXCL is
>> held while sleeping. We need this to prevent starvation of the truncate
>> path as continuous submission of direct-I/O could starve the truncate
>> path indefinitely if the lock is dropped.
>>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Reported-by: Jan Kara <jack@suse.cz>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Looks good to me except some nits below. Feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>
>
> for as much as it is worth with XFS code ;)
>
>> +static int
>> +xfs_break_dax_layouts(
>> +     struct inode            *inode,
>> +     uint                    iolock,
>> +     bool                    *did_unlock)
>> +{
>> +     struct page             *page;
>> +
>> +     *did_unlock = false;
>> +     page = dax_layout_busy_page(inode->i_mapping);
>> +     if (!page)
>> +             return 0;
>> +
>> +     return ___wait_var_event(&page->_refcount,
>> +                     atomic_read(&page->_refcount) == 1, TASK_INTERRUPTIBLE,
>> +                     0, 0, xfs_wait_dax_page(inode, did_unlock));
>> +}
>> +
>>  int
>>  xfs_break_layouts(
>>       struct inode            *inode,
>> @@ -729,17 +760,23 @@ xfs_break_layouts(
>>
>>       ASSERT(xfs_isilocked(XFS_I(inode), XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
>>
>> -     switch (reason) {
>> -     case BREAK_UNMAP:
>> -             ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
>> -             /* fall through */
>> -     case BREAK_WRITE:
>> -             error = xfs_break_leased_layouts(inode, iolock, &retry);
>> -             break;
>> -     default:
>> -             WARN_ON_ONCE(1);
>> -             return -EINVAL;
>> -     }
>> +     do {
>> +             switch (reason) {
>> +             case BREAK_UNMAP:
>> +                     ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
>
> Maybe move the assertion to xfs_break_dax_layouts()?

Makes sense, sure.

>
>> +
>> +                     error = xfs_break_dax_layouts(inode, *iolock, &retry);
>> +                     /* fall through */
>> +             case BREAK_WRITE:
>> +                     if (error || retry)
>> +                             break;
>
> The error handling IMHO belongs above the 'fall through' comment above.

Ok, yes I think this location is a stale holdover.

>
>> +                     error = xfs_break_leased_layouts(inode, iolock, &retry);
>> +                     break;
>> +             default:
>> +                     WARN_ON_ONCE(1);
>> +                     return -EINVAL;
>> +             }
>> +     } while (error == 0 && retry);
>
> As a general 'taste' comment, I prefer if the 'retry' is always initialized
> to 'false' at the beginning of the loop body in these kinds of loops. That
> way it is obvious we are doing the right thing when looking at the loop
> body and we don't have to verify that each case statement initializes
> 'retry' properly (in fact I'd remove the initialization from
> xfs_break_dax_layouts() and xfs_break_leased_layouts()). But this is more a
> matter of taste and consistency with other code in the area so I defer to
> XFS maintainers for a final opinion. Darrick?

I'm fine with making this change, I'll proceed unless / until Darrick says no.
