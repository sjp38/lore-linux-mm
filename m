Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97C228E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:13:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x24-v6so2934536edm.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:13:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8-v6si123956ejr.201.2018.09.27.04.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 04:13:55 -0700 (PDT)
Date: Thu, 27 Sep 2018 13:13:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 07/11] filesystem-dax: Introduce
 dax_lock_mapping_entry()
Message-ID: <20180927111354.GA16469@quack2.suse.cz>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180924115721.75893931@gnomeregan.cam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924115721.75893931@gnomeregan.cam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Barret Rhoden <brho@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, ross.zwisler@linux.intel.com

On Mon 24-09-18 11:57:21, Barret Rhoden wrote:
> Hi Dan -
> 
> On 2018-07-04 at 14:41 Dan Williams <dan.j.williams@intel.com> wrote:
> [snip]
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 4de11ed463ce..57ec272038da 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> [snip]
> > +bool dax_lock_mapping_entry(struct page *page)
> > +{
> > +	pgoff_t index;
> > +	struct inode *inode;
> > +	bool did_lock = false;
> > +	void *entry = NULL, **slot;
> > +	struct address_space *mapping;
> > +
> > +	rcu_read_lock();
> > +	for (;;) {
> > +		mapping = READ_ONCE(page->mapping);
> > +
> > +		if (!dax_mapping(mapping))
> > +			break;
> > +
> > +		/*
> > +		 * In the device-dax case there's no need to lock, a
> > +		 * struct dev_pagemap pin is sufficient to keep the
> > +		 * inode alive, and we assume we have dev_pagemap pin
> > +		 * otherwise we would not have a valid pfn_to_page()
> > +		 * translation.
> > +		 */
> > +		inode = mapping->host;
> > +		if (S_ISCHR(inode->i_mode)) {
> > +			did_lock = true;
> > +			break;
> > +		}
> > +
> > +		xa_lock_irq(&mapping->i_pages);
> > +		if (mapping != page->mapping) {
> > +			xa_unlock_irq(&mapping->i_pages);
> > +			continue;
> > +		}
> > +		index = page->index;
> > +
> > +		entry = __get_unlocked_mapping_entry(mapping, index, &slot,
> > +				entry_wait_revalidate);
> > +		if (!entry) {
> > +			xa_unlock_irq(&mapping->i_pages);
> > +			break;
> > +		} else if (IS_ERR(entry)) {
> > +			WARN_ON_ONCE(PTR_ERR(entry) != -EAGAIN);
> > +			continue;
> 
> In the IS_ERR case, do you need to xa_unlock the mapping?  It looks
> like you'll deadlock the next time around the loop.

Yep, that looks certainly wrong. I'll send a fix.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
