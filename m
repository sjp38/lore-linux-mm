Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 92C8E6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 12:20:48 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id v14so195245084ykd.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 09:20:48 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id p68si65204974ywd.409.2016.01.05.09.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 09:20:47 -0800 (PST)
Received: by mail-yk0-x22e.google.com with SMTP id k129so266165090yke.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 09:20:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160105171235.GB6462@linux.intel.com>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
	<20160105111358.GD2724@quack.suse.cz>
	<20160105171235.GB6462@linux.intel.com>
Date: Tue, 5 Jan 2016 09:20:47 -0800
Message-ID: <CAPcyv4jAAAtRc7GSOqDZixxpQfM4bzHtkwmrsjLJ0Bqba+0KRA@mail.gmail.com>
Subject: Re: [PATCH v6 4/7] dax: add support for fsync/msync
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Jan 5, 2016 at 9:12 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Tue, Jan 05, 2016 at 12:13:58PM +0100, Jan Kara wrote:
>> On Wed 23-12-15 12:39:17, Ross Zwisler wrote:
>> > To properly handle fsync/msync in an efficient way DAX needs to track dirty
>> > pages so it is able to flush them durably to media on demand.
>> >
>> > The tracking of dirty pages is done via the radix tree in struct
>> > address_space.  This radix tree is already used by the page writeback
>> > infrastructure for tracking dirty pages associated with an open file, and
>> > it already has support for exceptional (non struct page*) entries.  We
>> > build upon these features to add exceptional entries to the radix tree for
>> > DAX dirty PMD or PTE pages at fault time.
>> >
>> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> ...
>> > +static int dax_writeback_one(struct block_device *bdev,
>> > +           struct address_space *mapping, pgoff_t index, void *entry)
>> > +{
>> > +   struct radix_tree_root *page_tree = &mapping->page_tree;
>> > +   int type = RADIX_DAX_TYPE(entry);
>> > +   struct radix_tree_node *node;
>> > +   struct blk_dax_ctl dax;
>> > +   void **slot;
>> > +   int ret = 0;
>> > +
>> > +   spin_lock_irq(&mapping->tree_lock);
>> > +   /*
>> > +    * Regular page slots are stabilized by the page lock even
>> > +    * without the tree itself locked.  These unlocked entries
>> > +    * need verification under the tree lock.
>> > +    */
>> > +   if (!__radix_tree_lookup(page_tree, index, &node, &slot))
>> > +           goto unlock;
>> > +   if (*slot != entry)
>> > +           goto unlock;
>> > +
>> > +   /* another fsync thread may have already written back this entry */
>> > +   if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
>> > +           goto unlock;
>> > +
>> > +   radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
>> > +
>> > +   if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
>> > +           ret = -EIO;
>> > +           goto unlock;
>> > +   }
>> > +
>> > +   dax.sector = RADIX_DAX_SECTOR(entry);
>> > +   dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
>> > +   spin_unlock_irq(&mapping->tree_lock);
>> > +
>> > +   /*
>> > +    * We cannot hold tree_lock while calling dax_map_atomic() because it
>> > +    * eventually calls cond_resched().
>> > +    */
>> > +   ret = dax_map_atomic(bdev, &dax);
>> > +   if (ret < 0)
>> > +           return ret;
>> > +
>> > +   if (WARN_ON_ONCE(ret < dax.size)) {
>> > +           ret = -EIO;
>> > +           dax_unmap_atomic(bdev, &dax);
>> > +           return ret;
>> > +   }
>> > +
>> > +   spin_lock_irq(&mapping->tree_lock);
>> > +   /*
>> > +    * We need to revalidate our radix entry while holding tree_lock
>> > +    * before we do the writeback.
>> > +    */
>>
>> Do we really need to revalidate here? dax_map_atomic() makes sure the addr
>> & size is still part of the device. I guess you are concerned that due to
>> truncate or similar operation those sectors needn't belong to the same file
>> anymore but we don't really care about flushing sectors for someone else,
>> do we?
>>
>> Otherwise the patch looks good to me.
>
> Yep, the concern is that we could have somehow raced against a truncate
> operation while we weren't holding the tree_lock, and that now the address we
> are about to flush belongs to another file or is unallocated by the
> filesystem.
>
> I agree that this should be non-destructive - if you think the additional
> check and locking isn't worth the overhead, I'm happy to take it out.  I don't
> have a strong opinion either way.
>

My concern is whether flushing potentially invalid virtual addresses
is problematic on some architectures.  Maybe it's just FUD, but it's
less work in my opinion to just revalidate the address versus auditing
each arch for this concern.

At a minimum we can change the comment to not say "We need to" and
instead say "TODO: are all archs ok with flushing potentially invalid
addresses?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
