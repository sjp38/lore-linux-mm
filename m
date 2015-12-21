Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id CA4A66B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:45:39 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 78so19059352pfw.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:45:39 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pf6si10278575pac.27.2015.12.21.09.45.39
        for <linux-mm@kvack.org>;
        Mon, 21 Dec 2015 09:45:39 -0800 (PST)
Date: Mon, 21 Dec 2015 10:45:34 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 2/7] dax: support dirty DAX entries in radix tree
Message-ID: <20151221174534.GA4978@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-3-git-send-email-ross.zwisler@linux.intel.com>
 <20151221171512.GA7030@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151221171512.GA7030@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Dec 21, 2015 at 06:15:12PM +0100, Jan Kara wrote:
> On Fri 18-12-15 22:22:15, Ross Zwisler wrote:
> > Add support for tracking dirty DAX entries in the struct address_space
> > radix tree.  This tree is already used for dirty page writeback, and it
> > already supports the use of exceptional (non struct page*) entries.
> > 
> > In order to properly track dirty DAX pages we will insert new exceptional
> > entries into the radix tree that represent dirty DAX PTE or PMD pages.
> > These exceptional entries will also contain the writeback addresses for the
> > PTE or PMD faults that we can use at fsync/msync time.
> > 
> > There are currently two types of exceptional entries (shmem and shadow)
> > that can be placed into the radix tree, and this adds a third.  We rely on
> > the fact that only one type of exceptional entry can be found in a given
> > radix tree based on its usage.  This happens for free with DAX vs shmem but
> > we explicitly prevent shadow entries from being added to radix trees for
> > DAX mappings.
> > 
> > The only shadow entries that would be generated for DAX radix trees would
> > be to track zero page mappings that were created for holes.  These pages
> > would receive minimal benefit from having shadow entries, and the choice
> > to have only one type of exceptional entry in a given radix tree makes the
> > logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> The patch looks good to me. Just one comment: When we have this exclusion
> between different types of exceptional entries, there is no real need to
> have separate counters of 'shadow' and 'dax' entries, is there? We can have
> one 'nrexceptional' counter and don't have to grow struct inode
> unnecessarily which would be really welcome since DAX isn't a mainstream
> feature. Could you please change the code? Thanks!

Sure, this sounds good.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
