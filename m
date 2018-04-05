Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0046B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 16:26:53 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w9-v6so18389639plp.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 13:26:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j62si6104201pge.747.2018.04.05.13.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 13:26:52 -0700 (PDT)
Date: Thu, 5 Apr 2018 13:26:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] include: mm: Adding new inline function vmf_error
Message-ID: <20180405202651.GB3666@bombadil.infradead.org>
References: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
 <20180405125322.2ef3abfc6159a72725095bd0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405125322.2ef3abfc6159a72725095bd0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Thu, Apr 05, 2018 at 12:53:22PM -0700, Andrew Morton wrote:
> > +static inline vm_fault_t vmf_error(int err)
> > +{
> > +	vm_fault_t ret;
> > +
> > +	if (err == -ENOMEM)
> > +		ret = VM_FAULT_OOM;
> > +	else
> > +		ret = VM_FAULT_SIGBUS;
> > +
> > +	return ret;
> > +}
> > +
> 
> That's a bit verbose.  Why not simply
> 
> 	return (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;

That's a little skimpy for my taste (although Souptick's is more verbose
than I like too) ... I suggested this:

> > @@ -8983,9 +8984,9 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
> >  	}
> >  	if (ret) {
> >  		if (ret == -ENOMEM)
> > -			ret = VM_FAULT_OOM;
> > +			retval = VM_FAULT_OOM;
> >  		else /* -ENOSPC, -EIO, etc */
> > -			ret = VM_FAULT_SIGBUS;
> > +			retval = VM_FAULT_SIGBUS;
> >  		if (reserved)
> >  			goto out;
> >  		goto out_noreserve;
> 
> I'm seeing this pattern _a lot_ in filesystems.  It gets written in a
> few different ways, but
> 
> 	ret = (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
> 
> is really common.  I think we should do a helper function as part of
> these cleanups ... maybe:
> 
> static inline vm_fault_t vmf_error(int errno)
> {
> 	if (err == -ENOMEM)
> 		return VM_FAULT_OOM;
> 	return VM_FAULT_SIGBUS;
> }
> 
> -		if (ret == -ENOMEM)
> -			ret = VM_FAULT_OOM;
> -		else /* -ENOSPC, -EIO, etc */
> -			ret = VM_FAULT_SIGBUS;
> +		ret = vmf_error(err);
> 
> I know we've mostly been deleting these errno-to-vm_fault converters,
> but those try to do too much -- they handle an errno of 0 (when there
> are at least three ways to return success -- 0, NOPAGE and LOCKED),
> and often they've encoded some other VM_FAULT code in a different
> errno, eg the way block_page_mkwrite() uses -EFAULT.
> 
> There are a few other error codes to handle under special conditions,
> but the caller can handle them first.  eg I see block_page_mkwrite()
> eventually looking like this:
> 
> 	err = __block_write_begin(page, 0, end, get_block);
> 	if (!err)
> 		err = block_commit_write(page, 0, end);
> 
> 	if (unlikely(err < 0))
> 		goto error;
> 	set_page_dirty(page);
> 	wait_for_stable_page(page);
> 	return 0;
> error:
> 	if (err == -EAGAIN)
> 		ret = VM_FAULT_NOPAGE;
> 	else
> 		ret = vmf_error(err);
> out_unlock:
> 	unlock_page(page);
> 	return ret;
