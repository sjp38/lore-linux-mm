Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id E763C6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:39:07 -0500 (EST)
Received: by mail-vc0-f182.google.com with SMTP id hq12so1746120vcb.13
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:39:07 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hf6si1693001vdb.2.2015.01.13.13.39.06
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 13:39:07 -0800 (PST)
Date: Tue, 13 Jan 2015 16:39:03 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 07/20] dax,ext2: Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-ID: <20150113213903.GJ5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-8-git-send-email-matthew.r.wilcox@intel.com>
 <20150112150947.eb6ccb5c45edb4e83cd48b28@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112150947.eb6ccb5c45edb4e83cd48b28@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Mon, Jan 12, 2015 at 03:09:47PM -0800, Andrew Morton wrote:
> > +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> > +{
...
> > +			if (pgsz < PAGE_SIZE)
> > +				memset(addr, 0, pgsz);
> > +			else
> > +				clear_page(addr);
> 
> Are there any cache issues in all this code? flush_dcache_page(addr)?

Here, no.  This is only called to initialise a newly allocated block.

Elsewhere, maybe.  When i was originally working on this, I think I had
code that forced mmaps of DAX files to be aligned to SHMLBA, because I
remember noticing a bug in sparc64's remap_file_range().  Unfortunately,
in the various rewrites, that got lost.  So it needs to be put back in.

flush_dcache_page() in particular won't work because it needs a struct
page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
