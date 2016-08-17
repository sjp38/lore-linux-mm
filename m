Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D22A6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 16:26:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so249095457pfg.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 13:26:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q11si39257885pfd.42.2016.08.17.13.26.22
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 13:26:22 -0700 (PDT)
Date: Wed, 17 Aug 2016 14:25:56 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 5/7] dax: lock based on slot instead of [mapping, index]
Message-ID: <20160817202556.GA13009@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
 <20160815190918.20672-6-ross.zwisler@linux.intel.com>
 <20160816092816.GE27284@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160816092816.GE27284@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Tue, Aug 16, 2016 at 11:28:16AM +0200, Jan Kara wrote:
> On Mon 15-08-16 13:09:16, Ross Zwisler wrote:
> > DAX radix tree locking currently locks entries based on the unique
> > combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
> > This works for PTEs, but as we move to PMDs we will need to have all the
> > offsets within the range covered by the PMD to map to the same bit lock.
> > To accomplish this, lock based on the 'slot' pointer in the radix tree
> > instead of [mapping, index].
> 
> I'm not convinced this is safe. What makes the slot pointer still valid
> after you drop tree_lock? At least radix_tree_shrink() or
> radix_tree_expand() could move your slot without letting the waiter know
> and he would be never woken.
> 
> 								Honza

Yep, you're right, thanks for catching that.

Given that we can't rely on 'slot' being stable, my next idea is to use a
combination of [mapping, index], but tweak 'index' so that it's always the
beginning of the entry.  So for 4k entries we'd leave it alone, but for 2MiB
entries we'd mask it down to the appropriate 2MiB barrier.

Let me hack on that for a bit, unless you've a better idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
