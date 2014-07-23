Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C1B966B0037
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:58:02 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so2196880pdj.7
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:58:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id by5si3583416pab.140.2014.07.23.12.57.46
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 12:58:01 -0700 (PDT)
Date: Wed, 23 Jul 2014 15:57:44 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 10/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140723195744.GG6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <00ad731b459e32ce965af8530bcd611a141e41b6.1406058387.git.matthew.r.wilcox@intel.com>
 <53CFE965.5020304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CFE965.5020304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 07:57:09PM +0300, Boaz Harrosh wrote:
> > +/*
> > + * The user has performed a load from a hole in the file.  Allocating
> > + * a new page in the file would cause excessive storage usage for
> > + * workloads with sparse files.  We allocate a page cache page instead.
> > + * We'll kick it out of the page cache if it's ever written to,
> > + * otherwise it will simply fall out of the page cache under memory
> > + * pressure without ever having been dirtied.
> > + */
> 
> Do you like this ?? I understand that you cannot use the ZERO page or
> such global page on a page cache since each instance needs its own
> list_head/index/mapping and so on. But why use any page at all.
> 
> use a global ZERO page, either the system global, or static local to
> this system. map it to the current application VMA in question, using it's
> pfn (page_to_pfn) just like you do with real DAX-blocks from prd.

I must admit to not understanding the MM particularly well.  There would
seem to be problems with rmap when doing this kind of trick.  Also, this
is how reading from holes on regular filesystems work (except for the
part about kicking it out of page cache on a write).  A third reason is
that there are some forms of PMem which are terribly slow to write to.
I have a longer-term plan to support these memories by transparently
caching them in DRAM and only writing back to the media on flush/sync.

> Say app A reads an hole, then app B reads an hole. Both now point to the same
> zero page pfn, now say app B writes to that hole, mkwrite will convert it to
> a real dax-block pfn and will map the new pfn in the faulting vma. But what about
> app A, will it read the old pfn? who loops on all VMA's that have some mapping
> and invalidates those mapping.

That's the call to unmap_mapping_range().

> Same with truncate. App A mmap-read a block, app B does a read-mmap then a truncate.
> who loops on all VMA mappings of these blocks to invalidate them. With page-cache and
> pages we have a list of all VMA's that currently have mappings on a page, but with
> dax-pfns (dax-blocks) we do *not* have page struct, who keeps the list of current
> active vma-mappings?

Same solution ... there's a list in the address_space of all the VMAs who
have it mapped.  See truncate_pagecache() in mm/truncate.c (filesystems
usually call truncate_setsize()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
