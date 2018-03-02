Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1AD6B0008
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 13:37:42 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id m50so5738553otb.0
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 10:37:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor2680999oic.138.2018.03.02.10.37.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 10:37:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180302174530.GV19312@magnolia>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151996282448.28483.10415125852182473579.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180302174530.GV19312@magnolia>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 2 Mar 2018 10:37:40 -0800
Message-ID: <CAPcyv4iu32ja_vPiN=E0DP7_PFaj887XQ48EOMupE0Q4p1dCkQ@mail.gmail.com>
Subject: Re: [PATCH v5 02/12] dax: introduce IS_DEVDAX() and IS_FSDAX()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-xfs <linux-xfs@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable <stable@vger.kernel.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 2, 2018 at 9:45 AM, Darrick J. Wong <darrick.wong@oracle.com> wrote:
> On Thu, Mar 01, 2018 at 07:53:44PM -0800, Dan Williams wrote:
>> The current IS_DAX() helper that checks if a file is in DAX mode serves
>> two purposes. It is a control flow branch condition for DAX vs
>> non-DAX paths and it is a mechanism to perform dead code elimination. The
>> dead code elimination is required in the CONFIG_FS_DAX=n case since
>> there are symbols in fs/dax.c that will be elided. While the
>> dead code elimination can be addressed with nop stubs for the fs/dax.c
>> symbols that does not address the need for a DAX control flow helper
>> where fs/dax.c symbols are not involved.
>>
>> Moreover, the control flow changes, in some cases, need to be cognizant
>> of whether the DAX file is a typical file or a Device-DAX special file.
>> Introduce IS_DEVDAX() and IS_FSDAX() to simultaneously address the
>> file-type control flow and dead-code elimination use cases. IS_DAX()
>> will be deleted after all sites are converted to use the file-type
>> specific helper.
>>
>> Note, this change is also a pre-requisite for fixing the definition of
>> the S_DAX inode flag in the CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case.
>> The flag needs to be defined, non-zero, if either DAX facility is
>> enabled.
>>
>> Cc: "Theodore Ts'o" <tytso@mit.edu>
>> Cc: Andreas Dilger <adilger.kernel@dilger.ca>
>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
>> Cc: linux-xfs@vger.kernel.org
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: <stable@vger.kernel.org>
>> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
>> Reported-by: Jan Kara <jack@suse.cz>
>> Reviewed-by: Jan Kara <jack@suse.cz>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  include/linux/fs.h |   22 ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 79c413985305..bd0c46880572 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1909,6 +1909,28 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
>>  #define IS_WHITEOUT(inode)   (S_ISCHR(inode->i_mode) && \
>>                                (inode)->i_rdev == WHITEOUT_DEV)
>>
>> +static inline bool IS_DEVDAX(struct inode *inode)
>> +{
>> +     if (!IS_ENABLED(CONFIG_DEV_DAX))
>> +             return false;
>> +     if ((inode->i_flags & S_DAX) == 0)
>> +             return false;
>> +     if (!S_ISCHR(inode->i_mode))
>> +             return false;
>> +     return true;
>> +}
>> +
>> +static inline bool IS_FSDAX(struct inode *inode)
>> +{
>> +     if (!IS_ENABLED(CONFIG_FS_DAX))
>> +             return false;
>
> I echo Jan's complaint from the last round that the dead code
> elimination here is subtle, as compared to:
>
> #if IS_ENABLED(CONFIG_FS_DAX)
> static inline bool IS_FSDAX(struct inode *inode) { ... }
> #else
> # define IS_FSDAX(inode) (false)
> #endif
>
> But I guess even with that we're relying on dead code elimination higher
> up in the call stack...

If IS_FSDAX() was only a dead-code elimination mechanism rather than a
runtime branch condition then I agree. Otherwise I think IS_ENABLED()
is suitable and not subtle, especially when used in a header file.

>> +     if ((inode->i_flags & S_DAX) == 0)
>> +             return false;
>> +     if (S_ISCHR(inode->i_mode))
>> +             return false;
>
> I'm curious, do we have character devices with S_DAX set?

Yes, Device-DAX, see:

    ab68f2622136 /dev/dax, pmem: direct access to persistent memory

> I /think/ we're expecting that only block/char devices and files will
> ever have S_DAX set, so IS_FSDAX is only true for block devices and
> files.  Right?

We had S_DAX on block-devices for a short while, but deleted it and
went with the Device-DAX interface instead. So it's only regular files
and /dev/daxX.Y nodes these days.

> (A comment here about why S_ISCHR->false here would be helpful.)

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
