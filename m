Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC2D56B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:48:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rz1so24411902pab.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:48:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m187si2370057pga.271.2016.10.11.14.48.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 14:48:19 -0700 (PDT)
Date: Tue, 11 Oct 2016 15:48:17 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 15/17] dax: add struct iomap based DAX PMD support
Message-ID: <20161011214817.GB32165@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475874544-24842-16-git-send-email-ross.zwisler@linux.intel.com>
 <20161010155917.GA19978@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161010155917.GA19978@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Oct 10, 2016 at 05:59:17PM +0200, Christoph Hellwig wrote:
> On Fri, Oct 07, 2016 at 03:09:02PM -0600, Ross Zwisler wrote:
> > -	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> > +	if ((unsigned long)entry & RADIX_DAX_PMD)
> 
> Please introduce a proper inline helper that mask all the possible type
> bits out of the radix tree entry, and use them wherever you do the
> open cast.

Yea, this is messy.  I tried having temporary flags, but that's basically
where we came from with the old 'type' thing which used to be
RADIX_DAX_PTE|RADIX_DAX_PMD.  

After playing with it a bit it seems like the cleanest way is to have a little
flag test helper, like this:

static int dax_flag_test(void *entry, int flags)
{
	return (unsigned long)entry & flags;
}

...

		/*
		 * Besides huge zero pages the only other thing that gets
		 * downgraded are empty entries which don't need to be
		 * unmapped.
		 */
		if (pmd_downgrade && dax_flag_test(entry, RADIX_DAX_HZP))
			unmap_mapping_range(mapping,
				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);

etc.   Please let me know if this is undesirable for some reason.  Vs keeping
the flags in a local variable, this is good because a) it doesn't require
callers to cast, and b) it makes operator precedence easy because the flags
are a param, so no "flags & (flag1|flag2)" nesting, and c) we don't keep a
local variable that could get out of sync with 'entry'.

> >  restart:
> >  	spin_lock_irq(&mapping->tree_lock);
> >  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> > +
> > +	if (entry) {
> > +		if (size_flag & RADIX_DAX_PMD) {
> > +			if (!radix_tree_exceptional_entry(entry) ||
> > +			    !((unsigned long)entry & RADIX_DAX_PMD)) {
> > +				entry = ERR_PTR(-EEXIST);
> > +				goto out_unlock;
> > +			}
> > +		} else { /* trying to grab a PTE entry */
> > +			if (radix_tree_exceptional_entry(entry) &&
> > +			    ((unsigned long)entry & RADIX_DAX_PMD) &&
> > +			    ((unsigned long)entry &
> > +			     (RADIX_DAX_HZP|RADIX_DAX_EMPTY))) {
> 
> And when we do these cases N times next to each other we should
> have a local variable the valid flag bits of entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
