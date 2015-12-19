Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 08AFE4402ED
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 13:37:48 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 140so93534590ykp.0
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 10:37:48 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id t82si16294071ywa.142.2015.12.19.10.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Dec 2015 10:37:47 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id p130so93573130yka.1
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 10:37:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
Date: Sat, 19 Dec 2015 10:37:46 -0800
Message-ID: <CAPcyv4irspQEPVdYfLK+QfW4t-1_y1gFFVuBm00=i03PFQwEYw@mail.gmail.com>
Subject: Re: [PATCH v5 4/7] dax: add support for fsync/sync
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Dec 18, 2015 at 9:22 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> To properly handle fsync/msync in an efficient way DAX needs to track dirty
> pages so it is able to flush them durably to media on demand.
>
> The tracking of dirty pages is done via the radix tree in struct
> address_space.  This radix tree is already used by the page writeback
> infrastructure for tracking dirty pages associated with an open file, and
> it already has support for exceptional (non struct page*) entries.  We
> build upon these features to add exceptional entries to the radix tree for
> DAX dirty PMD or PTE pages at fault time.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
[..]
> +static void dax_writeback_one(struct address_space *mapping, pgoff_t index,
> +               void *entry)
> +{
> +       struct radix_tree_root *page_tree = &mapping->page_tree;
> +       int type = RADIX_DAX_TYPE(entry);
> +       struct radix_tree_node *node;
> +       void **slot;
> +
> +       if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
> +               WARN_ON_ONCE(1);
> +               return;
> +       }
> +
> +       spin_lock_irq(&mapping->tree_lock);
> +       /*
> +        * Regular page slots are stabilized by the page lock even
> +        * without the tree itself locked.  These unlocked entries
> +        * need verification under the tree lock.
> +        */
> +       if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> +               goto unlock;
> +       if (*slot != entry)
> +               goto unlock;
> +
> +       /* another fsync thread may have already written back this entry */
> +       if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +               goto unlock;
> +
> +       radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> +
> +       if (type == RADIX_DAX_PMD)
> +               wb_cache_pmem(RADIX_DAX_ADDR(entry), PMD_SIZE);
> +       else
> +               wb_cache_pmem(RADIX_DAX_ADDR(entry), PAGE_SIZE);

Hi Ross, I should have realized this sooner, but what guarantees that
the address returned by RADIX_DAX_ADDR(entry) is still valid at this
point?  I think we need to store the sector in the radix tree and then
perform a new dax_map_atomic() operation to either lookup a valid
address or fail the sync request.  Otherwise, if the device is gone
we'll crash, or write into some other random vmalloc address space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
