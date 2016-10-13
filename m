Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE5156B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:34:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so90637730pab.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 13:34:36 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g23si12332857pgn.73.2016.10.13.13.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 13:34:35 -0700 (PDT)
Date: Thu, 13 Oct 2016 14:34:34 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20161013203434.GD26922@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <20160930091418.GC24352@infradead.org>
 <20161003075902.GG6457@quack2.suse.cz>
 <20161003080337.GA13688@infradead.org>
 <20161003081549.GH6457@quack2.suse.cz>
 <20161003093248.GA27720@infradead.org>
 <20161003111358.GQ6457@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003111358.GQ6457@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Oct 03, 2016 at 01:13:58PM +0200, Jan Kara wrote:
> On Mon 03-10-16 02:32:48, Christoph Hellwig wrote:
> > On Mon, Oct 03, 2016 at 10:15:49AM +0200, Jan Kara wrote:
> > > Yeah, so DAX path is special because it installs its own PTE directly from
> > > the fault handler which we don't do in any other case (only driver fault
> > > handlers commonly do this but those generally don't care about
> > > ->page_mkwrite or file mappings for that matter).
> > > 
> > > I don't say there are no simplifications or unifications possible, but I'd
> > > prefer to leave them for a bit later once the current churn with ongoing
> > > work somewhat settles...
> > 
> > Allright, let's keep it simple for now.  Being said this series clearly
> > is 4.9 material, but any chance to get a respin of the invalidate_pages
> 
> Agreed (actually 4.10).
> 
> > series as that might still be 4.8 material?
> 
> The problem with invalidate_pages series is that it depends on the ability
> to clear the dirty bits in the radix tree of DAX mappings (i.e. the first
> series). Otherwise radix tree entries that get once dirty can never be safely
> evicted, invalidate_inode_pages2_range() will keep returning EBUSY and
> callers get confused (I've tried that few weeks ago).
> 
> If I dropped patch 5/6 for 4.9 merge (i.e., we would still happily discard
> dirty radix tree entries from invalidate_inode_pages2_range()), things
> would run fine, just fsync() may miss to flush caches for some pages. I'm
> not sure that's much better than current status quo though. Thoughts?

I'm not sure if I'm understanding this correctly, but if you're saying that we
might end up in a case where fsync()/msync() would fail to properly flush
pages that are/should be dirty, I think this is a no-go.  That could result in
data corruption if a user calls fsync(), thinks they've achieved a
synchronization point (updating other metadata or whatever), then via power
loss they lose data they had flushed via that previous fsync() because it was
still in the CPU cache and never really made it out to media.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
