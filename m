Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA8AD6B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 01:50:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f193so112771372wmg.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 22:50:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f135si29909486wmd.94.2016.10.04.22.50.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Oct 2016 22:50:23 -0700 (PDT)
Date: Wed, 5 Oct 2016 07:50:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161005055020.GB20752@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
 <20161003105949.GP6457@quack2.suse.cz>
 <20161003210557.GA28177@linux.intel.com>
 <20161004055557.GB17515@quack2.suse.cz>
 <20161004153948.GA21248@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004153948.GA21248@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue 04-10-16 09:39:48, Ross Zwisler wrote:
> > The gfp_mask that propagates from __do_fault() or do_page_mkwrite() is fine
> > because at that point it is correct. But once we grab filesystem locks
> > which are not reclaim safe, we should update vmf->gfp_mask we pass further
> > down into DAX code to not contain __GFP_FS (that's a bug we apparently have
> > there). And inside DAX code, we definitely are not generally safe to add
> > __GFP_FS to mapping_gfp_mask(). Maybe we'd be better off propagating struct
> > vm_fault into this function, using passed gfp_mask there and make sure
> > callers update gfp_mask as appropriate.
> 
> Yep, that makes sense to me.  In reviewing your set it also occurred to me that
> we might want to stick a struct vm_area_struct *vma pointer in the vmf, since
> you always need a vma when you are using a vmf, but we pass them as a pair
> everywhere.

Actually, vma pointer will be in struct vm_fault after my DAX
write-protection series. So once that lands, we can clean up whatever
duplicit function parameters...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
