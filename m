Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A058E6B0011
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 00:23:52 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ur14so70565996pab.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 21:23:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ht8si15082612pad.98.2015.12.18.21.23.51
        for <linux-mm@kvack.org>;
        Fri, 18 Dec 2015 21:23:52 -0800 (PST)
Date: Fri, 18 Dec 2015 22:23:49 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 2/7] dax: support dirty DAX entries in radix tree
Message-ID: <20151219052349.GA3553@linux.intel.com>
References: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
 <1449602325-20572-3-git-send-email-ross.zwisler@linux.intel.com>
 <20151218090110.GB4297@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151218090110.GB4297@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Dec 18, 2015 at 10:01:10AM +0100, Jan Kara wrote:
> On Tue 08-12-15 12:18:40, Ross Zwisler wrote:
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
> > that can be placed into the radix tree, and this adds a third.  There
> > shouldn't be any collisions between these various exceptional entries
> > because only one type of exceptional entry should be able to be found in a
> > radix tree at a time depending on how it is being used.
> 
> I was thinking about this and I'm not sure the use of exceptional entries
> cannot collide. DAX uses page cache for read mapping of holes. When memory
> pressure happens, page can get evicted again and entry in the radix tree
> will get replaced with a shadow entry. So shadow entries *can* exist in DAX
> mappings. Thus at least your change to clear_exceptional_entry() looks
> wrong to me.
> 
> Also when we'd like to insert DAX radix tree entry, we have to count with
> the fact that there can be shadow entry in place and we have to tear it
> down properly.

You are right, thank you for catching this.

I think the correct thing to do is to just explicitly disallow having shadow
entries in trees for DAX mappings.  As you say the only usage is to track zero
page mappings for reading holes which will get minimal benefit from shadow
entries, and this choice makes the logic both in clear_exceptional_entry() and
in the rest of the DAX code simpler.

I've sent out a v5 that fixes this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
