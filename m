Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAD36B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 04:15:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so51457382wmg.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 01:15:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kq1si33536096wjb.150.2016.10.03.01.15.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 01:15:56 -0700 (PDT)
Date: Mon, 3 Oct 2016 10:15:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20161003081549.GH6457@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <20160930091418.GC24352@infradead.org>
 <20161003075902.GG6457@quack2.suse.cz>
 <20161003080337.GA13688@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003080337.GA13688@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 03-10-16 01:03:37, Christoph Hellwig wrote:
> On Mon, Oct 03, 2016 at 09:59:02AM +0200, Jan Kara wrote:
> > IMO ->fault and ->pmd_fault can be merged, ->page_mkwrite and ->pfn_mkwrite
> > can be merged. There were even patches flying around for that. I want to do
> > that but it's not a priority now as the patch set it already large enough.
> > 
> > I'm not sure whether merging ->fault and ->page_mkwrite would be really
> > helpful and it would certainly require some non-trivial changes in the
> > fault path. For example currently a write fault of a file mapping will
> > result in first ->fault being called which handles the read part of the
> > fault and then ->page_mkwrite is called to handle write-enabling of the
> > PTE. When the handlers would be merged, calling one handler twice would be
> > really strange.
> 
> Except for the DAX path, where we apparently need to call out to
> the mkwrite handler from ->fault.  Or at least used to, with some
> leftovers in XFS and not extN.

Yeah, so DAX path is special because it installs its own PTE directly from
the fault handler which we don't do in any other case (only driver fault
handlers commonly do this but those generally don't care about
->page_mkwrite or file mappings for that matter).

I don't say there are no simplifications or unifications possible, but I'd
prefer to leave them for a bit later once the current churn with ongoing
work somewhat settles...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
