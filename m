Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4C49F6B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:18:51 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so292804pdb.21
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:18:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nz10si346046pdb.211.2014.10.17.00.18.49
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:18:50 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:29:23 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 09/21] dax,ext2: Replace the XIP page fault handler
 with the DAX page fault handler
Message-ID: <20141016212923.GG11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-10-git-send-email-matthew.r.wilcox@intel.com>
 <20141016102047.GG19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016102047.GG19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Calvin Owens <jcalvinowens@gmail.com>

On Thu, Oct 16, 2014 at 12:20:47PM +0200, Mathieu Desnoyers wrote:
> > +/*
> > + * The user has performed a load from a hole in the file.  Allocating
> > + * a new page in the file would cause excessive storage usage for
> > + * workloads with sparse files.  We allocate a page cache page instead.
> > + * We'll kick it out of the page cache if it's ever written to,
> > + * otherwise it will simply fall out of the page cache under memory
> > + * pressure without ever having been dirtied.
> 
> Nice trick :)

It's basically what the page cache does.  Unfortunately, I had to step
out of the room while Calvin detailed his trick for doing it differently,
but if his patch goes in, we should follow suit.

> > +		if (!page) {
> > +			mutex_lock(&mapping->i_mmap_mutex);
> > +			/* Check we didn't race with truncate */
> > +			size = (i_size_read(inode) + PAGE_SIZE - 1) >>
> > +								PAGE_SHIFT;
> > +			if (vmf->pgoff >= size) {
> > +				mutex_unlock(&mapping->i_mmap_mutex);
> > +				error = -EIO;
> > +				goto out;
> > +			}
> > +		}
> 
> If page is non-NULL, is it possible that we return VM_FAULT_LOCKED
> without actually holding i_mmap_mutex ? Is it on purpose ?
> 
> > +		return VM_FAULT_LOCKED;
> > +	}

That's right; this is the original meaning of VM_FAULT_LOCKED, that the
page lock is held.  We took it before the call to get_block(), ensuring
that we don't hit the truncate race.  Er ... hang on.  At some point in
the revising of patches, I dropped the stanza where we re-check i_size
after grabbing the page lock.  Sod ... a v12 of this patchset will have
to be forthcoming!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
