Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68CC56B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 20:08:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so148002066pgc.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 17:08:33 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id t127si4751266pgt.302.2016.12.15.17.08.31
        for <linux-mm@kvack.org>;
        Thu, 15 Dec 2016 17:08:32 -0800 (PST)
Date: Fri, 16 Dec 2016 12:07:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 1/3] dax: masking off __GFP_FS in fs DAX handlers
Message-ID: <20161216010730.GY4219@dastard>
References: <148184524161.184728.14005697153880489871.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148184524161.184728.14005697153880489871.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 15, 2016 at 04:40:41PM -0700, Dave Jiang wrote:
> The caller into dax needs to clear __GFP_FS mask bit since it's
> responsible for acquiring locks / transactions that blocks __GFP_FS
> allocation.  The caller will restore the original mask when dax function
> returns.

What's the allocation problem you're working around here? Can you
please describe the call chain that is the problem?

>  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
>  
>  	if (IS_DAX(inode)) {
> +		gfp_t old_gfp = vmf->gfp_mask;
> +
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
> +		vmf->gfp_mask = old_gfp;

I really have to say that I hate code that clears and restores flags
without any explanation of why the code needs to play flag tricks. I
take one look at the XFS fault handling code and ask myself now "why
the hell do we need to clear those flags?" Especially as the other
paths into generic fault handlers /don't/ require us to do this.
What does DAX do that require us to treat memory allocation contexts
differently to the filemap_fault() path?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
