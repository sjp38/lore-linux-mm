Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5188E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:57:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h37-v6so506671pgh.4
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:57:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2-v6sor2539923plt.23.2018.09.24.08.57.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 08:57:25 -0700 (PDT)
Date: Mon, 24 Sep 2018 11:57:21 -0400
From: Barret Rhoden <brho@google.com>
Subject: Re: [PATCH v5 07/11] filesystem-dax: Introduce
 dax_lock_mapping_entry()
Message-ID: <20180924115721.75893931@gnomeregan.cam.corp.google.com>
In-Reply-To: <153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
	<153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, ross.zwisler@linux.intel.com

Hi Dan -

On 2018-07-04 at 14:41 Dan Williams <dan.j.williams@intel.com> wrote:
[snip]
> diff --git a/fs/dax.c b/fs/dax.c
> index 4de11ed463ce..57ec272038da 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
[snip]
> +bool dax_lock_mapping_entry(struct page *page)
> +{
> +	pgoff_t index;
> +	struct inode *inode;
> +	bool did_lock = false;
> +	void *entry = NULL, **slot;
> +	struct address_space *mapping;
> +
> +	rcu_read_lock();
> +	for (;;) {
> +		mapping = READ_ONCE(page->mapping);
> +
> +		if (!dax_mapping(mapping))
> +			break;
> +
> +		/*
> +		 * In the device-dax case there's no need to lock, a
> +		 * struct dev_pagemap pin is sufficient to keep the
> +		 * inode alive, and we assume we have dev_pagemap pin
> +		 * otherwise we would not have a valid pfn_to_page()
> +		 * translation.
> +		 */
> +		inode = mapping->host;
> +		if (S_ISCHR(inode->i_mode)) {
> +			did_lock = true;
> +			break;
> +		}
> +
> +		xa_lock_irq(&mapping->i_pages);
> +		if (mapping != page->mapping) {
> +			xa_unlock_irq(&mapping->i_pages);
> +			continue;
> +		}
> +		index = page->index;
> +
> +		entry = __get_unlocked_mapping_entry(mapping, index, &slot,
> +				entry_wait_revalidate);
> +		if (!entry) {
> +			xa_unlock_irq(&mapping->i_pages);
> +			break;
> +		} else if (IS_ERR(entry)) {
> +			WARN_ON_ONCE(PTR_ERR(entry) != -EAGAIN);
> +			continue;

In the IS_ERR case, do you need to xa_unlock the mapping?  It looks
like you'll deadlock the next time around the loop.

> +		}
> +		lock_slot(mapping, slot);
> +		did_lock = true;
> +		xa_unlock_irq(&mapping->i_pages);
> +		break;
> +	}
> +	rcu_read_unlock();
> +
> +	return did_lock;
> +}
