Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id B44546B025E
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 03:03:09 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id bx1so147890307obb.0
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 00:03:09 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a8si7590591obt.51.2015.12.30.00.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 00:03:08 -0800 (PST)
Message-ID: <56838FA3.5030909@oracle.com>
Date: Wed, 30 Dec 2015 16:02:43 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/7] dax: support dirty DAX entries in radix tree
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com> <1450899560-26708-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1450899560-26708-3-git-send-email-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

Hi Ross,

On 12/24/2015 03:39 AM, Ross Zwisler wrote:
> Add support for tracking dirty DAX entries in the struct address_space
> radix tree.  This tree is already used for dirty page writeback, and it
> already supports the use of exceptional (non struct page*) entries.
> 
> In order to properly track dirty DAX pages we will insert new exceptional
> entries into the radix tree that represent dirty DAX PTE or PMD pages.

I may get it wrong, but there is "struct page" for persistent memory after
"[PATCH v4 00/18]get_user_pages() for dax pte and pmd mappings".
So why not just add "struct page" to radix tree directly just like normal page cache?

Then we don't need to deal with any exceptional entries and special writeback.

Thanks,
Bob

> These exceptional entries will also contain the writeback sectors for the
> PTE or PMD faults that we can use at fsync/msync time.
> 
> There are currently two types of exceptional entries (shmem and shadow)
> that can be placed into the radix tree, and this adds a third.  We rely on
> the fact that only one type of exceptional entry can be found in a given
> radix tree based on its usage.  This happens for free with DAX vs shmem but
> we explicitly prevent shadow entries from being added to radix trees for
> DAX mappings.
> 
> The only shadow entries that would be generated for DAX radix trees would
> be to track zero page mappings that were created for holes.  These pages
> would receive minimal benefit from having shadow entries, and the choice
> to have only one type of exceptional entry in a given radix tree makes the
> logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/block_dev.c             |  2 +-
>  fs/inode.c                 |  2 +-
>  include/linux/dax.h        |  5 ++++
>  include/linux/fs.h         |  3 +-
>  include/linux/radix-tree.h |  9 ++++++
>  mm/filemap.c               | 17 ++++++++----
>  mm/truncate.c              | 69 ++++++++++++++++++++++++++--------------------
>  mm/vmscan.c                |  9 +++++-
>  mm/workingset.c            |  4 +--
>  9 files changed, 78 insertions(+), 42 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
