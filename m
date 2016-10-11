Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2C206B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:18:06 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id kc8so23697951pab.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:18:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id ua5si4760306pac.134.2016.10.11.14.18.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 14:18:05 -0700 (PDT)
Date: Tue, 11 Oct 2016 15:18:04 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 09/17] dax: coordinate locking for offsets in PMD range
Message-ID: <20161011211804.GA32165@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475874544-24842-10-git-send-email-ross.zwisler@linux.intel.com>
 <20161011070409.GC6952@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011070409.GC6952@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Oct 11, 2016 at 09:04:09AM +0200, Jan Kara wrote:
> On Fri 07-10-16 15:08:56, Ross Zwisler wrote:
> > DAX radix tree locking currently locks entries based on the unique
> > combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
> > This works for PTEs, but as we move to PMDs we will need to have all the
> > offsets within the range covered by the PMD to map to the same bit lock.
> > To accomplish this, for ranges covered by a PMD entry we will instead lock
> > based on the page offset of the beginning of the PMD entry.  The 'mapping'
> > pointer is still used in the same way.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> The patch looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> Just one thing which IMO deserves a comment below:
> 
> > @@ -448,9 +460,12 @@ restart:
> >  }
> >  
> >  void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> > -				   pgoff_t index, bool wake_all)
> > +		pgoff_t index, void *entry, bool wake_all)
> >  {
> > -	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
> > +	struct exceptional_entry_key key;
> > +	wait_queue_head_t *wq;
> > +
> > +	wq = dax_entry_waitqueue(mapping, index, entry, &key);
> 
> So I believe we should comment above this function that the 'entry' it gets
> may be invalid by the time it gets it (we call it without tree_lock held so
> the passed entry may be changed in the radix tree as we work) but we use it
> only to find appropriate waitqueue where tasks sleep waiting for that old
> entry to unlock so we indeed wake up all tasks we need.

Added, thanks for the suggestion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
