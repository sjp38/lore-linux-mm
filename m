Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62D056B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:25:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so1574825pfa.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:25:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y131si41443157pfg.33.2016.10.19.10.25.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 10:25:42 -0700 (PDT)
Date: Wed, 19 Oct 2016 11:25:41 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 19/20] dax: Protect PTE modification on WP fault by radix
 tree entry lock
Message-ID: <20161019172541.GD22463@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-20-git-send-email-jack@suse.cz>
 <20161018195332.GF7796@linux.intel.com>
 <20161019072505.GI29967@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019072505.GI29967@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Oct 19, 2016 at 09:25:05AM +0200, Jan Kara wrote:
> On Tue 18-10-16 13:53:32, Ross Zwisler wrote:
> > On Tue, Sep 27, 2016 at 06:08:23PM +0200, Jan Kara wrote:
> > > -	void *entry;
> > > +	void *entry, **slot;
> > >  	pgoff_t index = vmf->pgoff;
> > >  
> > >  	spin_lock_irq(&mapping->tree_lock);
> > > -	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> > > -	if (!entry || !radix_tree_exceptional_entry(entry))
> > > -		goto out;
> > > +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> > > +	if (!entry || !radix_tree_exceptional_entry(entry)) {
> > > +		if (entry)
> > > +			put_unlocked_mapping_entry(mapping, index, entry);
> > 
> > I don't think you need this call to put_unlocked_mapping_entry().  If we get
> > in here we know that 'entry' is a page cache page, in which case
> > put_unlocked_mapping_entry() will just return without doing any work.
> 
> Right, but that is just an implementation detail internal to how the
> locking works. The rules are simple to avoid issues and thus the invariant
> is: Once you call get_unlocked_mapping_entry() you either have to lock the
> entry and then call put_locked_mapping_entry() or you have to drop it with
> put_unlocked_mapping_entry(). Once you add arguments about entry types
> etc., errors are much easier to make...

Makes sense.  You can add:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
