Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3C16B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:25:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z189so10117465wmb.6
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:25:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15si3227914wmc.104.2016.10.19.00.25.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 00:25:07 -0700 (PDT)
Date: Wed, 19 Oct 2016 09:25:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 19/20] dax: Protect PTE modification on WP fault by radix
 tree entry lock
Message-ID: <20161019072505.GI29967@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-20-git-send-email-jack@suse.cz>
 <20161018195332.GF7796@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018195332.GF7796@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 18-10-16 13:53:32, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:23PM +0200, Jan Kara wrote:
> > -	void *entry;
> > +	void *entry, **slot;
> >  	pgoff_t index = vmf->pgoff;
> >  
> >  	spin_lock_irq(&mapping->tree_lock);
> > -	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> > -	if (!entry || !radix_tree_exceptional_entry(entry))
> > -		goto out;
> > +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> > +	if (!entry || !radix_tree_exceptional_entry(entry)) {
> > +		if (entry)
> > +			put_unlocked_mapping_entry(mapping, index, entry);
> 
> I don't think you need this call to put_unlocked_mapping_entry().  If we get
> in here we know that 'entry' is a page cache page, in which case
> put_unlocked_mapping_entry() will just return without doing any work.

Right, but that is just an implementation detail internal to how the
locking works. The rules are simple to avoid issues and thus the invariant
is: Once you call get_unlocked_mapping_entry() you either have to lock the
entry and then call put_locked_mapping_entry() or you have to drop it with
put_unlocked_mapping_entry(). Once you add arguments about entry types
etc., errors are much easier to make...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
