Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78D3D6B0268
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 13:10:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h200so4575215oib.18
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 10:10:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e65sor2085118oif.122.2017.10.09.10.10.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 10:10:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009034506.GI3666@dastard>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732936625.22363.7638037715540836828.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009034506.GI3666@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 9 Oct 2017 10:10:42 -0700
Message-ID: <CAPcyv4jGgrrwrvd7ExyG6BNKemWg7yvtAG7wyUm64SwtNn70cw@mail.gmail.com>
Subject: Re: [PATCH v7 09/12] xfs: wire up ->lease_direct()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Oct 8, 2017 at 8:45 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Fri, Oct 06, 2017 at 03:36:06PM -0700, Dan Williams wrote:
>> A 'lease_direct' lease requires that the vma have a valid MAP_DIRECT
>> mapping established. For xfs we establish a new lease and then check if
>> the MAP_DIRECT mapping has been broken. We want to be sure that the
>> process will receive notification that the MAP_DIRECT mapping is being
>> torn down so it knows why other code paths are throwing failures.
>>
>> For example in the RDMA/ibverbs case we want ibv_reg_mr() to fail if the
>> MAP_DIRECT mapping is invalid or in the process of being invalidated.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Jeff Moyer <jmoyer@redhat.com>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Jeff Layton <jlayton@poochiereds.net>
>> Cc: "J. Bruce Fields" <bfields@fieldses.org>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  fs/xfs/xfs_file.c |   28 ++++++++++++++++++++++++++++
>>  1 file changed, 28 insertions(+)
>>
>> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
>> index e35518600e28..823b65f17429 100644
>> --- a/fs/xfs/xfs_file.c
>> +++ b/fs/xfs/xfs_file.c
>> @@ -1166,6 +1166,33 @@ xfs_filemap_direct_close(
>>       put_map_direct_vma(vma->vm_private_data);
>>  }
>>
>> +static struct lease_direct *
>> +xfs_filemap_direct_lease(
>> +     struct vm_area_struct   *vma,
>> +     void                    (*break_fn)(void *),
>> +     void                    *owner)
>> +{
>> +     struct lease_direct     *ld;
>> +
>> +     ld = map_direct_lease(vma, break_fn, owner);
>> +
>> +     if (IS_ERR(ld))
>> +             return ld;
>> +
>> +     /*
>> +      * We now have an established lease while the base MAP_DIRECT
>> +      * lease was not broken. So, we know that the "lease holder" will
>> +      * receive a SIGIO notification when the lease is broken and
>> +      * take any necessary cleanup actions.
>> +      */
>> +     if (!is_map_direct_broken(vma->vm_private_data))
>> +             return ld;
>> +
>> +     map_direct_lease_destroy(ld);
>> +
>> +     return ERR_PTR(-ENXIO);
>
> What's any of this got to do with XFS? Shouldn't it be in generic
> code, and called generic_filemap_direct_lease()?

True, I can move this to generic code. The filesystem is in charge of
where it wants to store the 'struct map_direct_state' context, but for
generic_filemap_direct_lease() it can just assume that it is stored in
->vm_private_data. I'll add comments to this effect on the new
routine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
