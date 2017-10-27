Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8BEB6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 05:13:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8so3028836wmg.4
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:13:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13si5392290wrh.413.2017.10.27.02.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 02:13:03 -0700 (PDT)
Date: Fri, 27 Oct 2017 11:13:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Message-ID: <20171027091301.GG31161@quack2.suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-18-jack@suse.cz>
 <20171024222322.GX3666@dastard>
 <20171026154804.GF31161@quack2.suse.cz>
 <20171027064301.GC22931@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171027064301.GC22931@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Fri 27-10-17 08:43:01, Christoph Hellwig wrote:
> On Thu, Oct 26, 2017 at 05:48:04PM +0200, Jan Kara wrote:
> > But now that I look at XFS implementation again, it misses handling
> > of VM_FAULT_NEEDSYNC in xfs_filemap_pfn_mkwrite() (ext4 gets this right).
> > I'll fix this by using __xfs_filemap_fault() for xfs_filemap_pfn_mkwrite()
> > as well since it mostly duplicates it anyway... Thanks for inquiring!
> 
> My first patches move xfs_filemap_pfn_mkwrite to use __xfs_filemap_fault,
> but that didn't work.  Wish I'd remember why, though.

Maybe due to the additional check on IS_DAX(inode) in __xfs_filemap_fault()
which could do the wrong thing if per-inode DAX flag is switched? Because
otherwise __xfs_filemap_fault(vmf, PE_SIZE_PTE, true) does exactly the same
thing as xfs_filemap_pfn_mkwrite() did.

If we do care about per-inode DAX flag switching, I can just fixup
xfs_filemap_pfn_mkwrite() but my understanding was that we ditched the idea
at least until someone comes up with a reliable way to implement that...

							Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
