Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f172.google.com (mail-yw0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7FF6B0255
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:18:14 -0500 (EST)
Received: by mail-yw0-f172.google.com with SMTP id u200so25548317ywf.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:18:14 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id b135si1795980ywa.305.2016.02.17.14.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 14:18:13 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id u9so13212749ykd.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:18:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160217215420.GK14140@quack.suse.cz>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
	<1455680059-20126-7-git-send-email-ross.zwisler@linux.intel.com>
	<20160217215420.GK14140@quack.suse.cz>
Date: Wed, 17 Feb 2016 14:18:13 -0800
Message-ID: <CAPcyv4g3iCL1q7FoeTwKvtqo2mLfA=mfi1K5PdmZVjU+PA-gOA@mail.gmail.com>
Subject: Re: [PATCH v3 6/6] block: use dax_do_io() if blkdev_dax_capable()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Al Viro <viro@ftp.linux.org.uk>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Wed, Feb 17, 2016 at 1:54 PM, Jan Kara <jack@suse.cz> wrote:
> On Tue 16-02-16 20:34:19, Ross Zwisler wrote:
>> From: Dan Williams <dan.j.williams@intel.com>
>>
>> Setting S_DAX on an inode requires that the inode participate in the
>> DAX-fsync mechanism which expects to use the pagecache for tracking
>> potentially dirty cpu cachelines.  However, dax_do_io() participates in
>> the standard pagecache sync semantics and arranges for dirty pages to be
>> flushed through the driver when a direct-IO operation accesses the same
>> ranges.
>>
>> It should always be valid to use the dax_do_io() path regardless of
>> whether the block_device inode has S_DAX set.  In either case dirty
>> pages or dirty cachelines are made durable before the direct-IO
>> operation proceeds.
>
> Please no. I agree that going via DAX path for normal likely won't
> introduce new data corruption issues. But I dislike having a special
> case for block devices. Also you have no way of turning DAX off for block
> devices AFAIU and as Dave said, DAX should be opt-in, not opt-out. Note
> that you may actually want to go through the block layer for normal IO e.g.
> because you use IO cgroups to limit processes so using DAX regresses some
> functionality.
>

Sounds good.

As Ross mentioned in the cover letter, I'm fine with dropping this one
for now as we think through how to restore raw device DAX support.  In
the meantime we can still force CONFIG_BLK_DEV_DAX=y for testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
