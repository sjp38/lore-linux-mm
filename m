Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4346B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 03:59:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f193so51009279wmg.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 00:59:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id di5si33419397wjb.50.2016.10.03.00.59.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 00:59:05 -0700 (PDT)
Date: Mon, 3 Oct 2016 09:59:02 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20161003075902.GG6457@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <20160930091418.GC24352@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160930091418.GC24352@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 30-09-16 02:14:18, Christoph Hellwig wrote:
> On Tue, Sep 27, 2016 at 06:08:04PM +0200, Jan Kara wrote:
> > Hello,
> > 
> > this is a third revision of my patches to clear dirty bits from radix tree of
> > DAX inodes when caches for corresponding pfns have been flushed. This patch set
> > is significantly larger than the previous version because I'm changing how
> > ->fault, ->page_mkwrite, and ->pfn_mkwrite handlers may choose to handle the
> > fault
> 
> Btw, is there ny good reason to keep ->fault, ->pmd_fault, page->mkwrite
> and pfn_mkwrite separate these days?  All of them now take a struct
> vm_fault, and the differences aren't exactly obvious for callers and
> users.

IMO ->fault and ->pmd_fault can be merged, ->page_mkwrite and ->pfn_mkwrite
can be merged. There were even patches flying around for that. I want to do
that but it's not a priority now as the patch set it already large enough.

I'm not sure whether merging ->fault and ->page_mkwrite would be really
helpful and it would certainly require some non-trivial changes in the
fault path. For example currently a write fault of a file mapping will
result in first ->fault being called which handles the read part of the
fault and then ->page_mkwrite is called to handle write-enabling of the
PTE. When the handlers would be merged, calling one handler twice would be
really strange.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
