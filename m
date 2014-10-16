Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE996B0070
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:20:55 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id eu11so309223pac.21
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:20:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bf2si466306pbb.76.2014.10.17.00.20.54
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:20:54 -0700 (PDT)
Date: Thu, 16 Oct 2014 18:01:26 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 19/21] dax: Add dax_zero_page_range
Message-ID: <20141016220126.GK11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-20-git-send-email-matthew.r.wilcox@intel.com>
 <20141016123824.GQ19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016123824.GQ19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Oct 16, 2014 at 02:38:24PM +0200, Mathieu Desnoyers wrote:
> > +int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
> 
> nit: unsigned -> unsigned int ?
> 
> Do we want a unsigned int or unsigned long here ?

It's supposed to be for a fragment of a page, so until we see a machine
with PAGE_SIZE > 4GB, we're good to use an unsigned int.

> >  	if (!length)
> >  		return 0;
> > +	BUG_ON((offset + length) > PAGE_CACHE_SIZE);
> 
> Isn't it a bit extreme to BUG_ON this condition ? We could return an
> error to the caller, and perhaps WARN_ON_ONCE(), but BUG_ON() appears to
> be slightly too strong here.

Dave Chinner asked for it :-)  The filesystem is supposed to be doing
this clamping (until the last version, I had this function doing the
clamping, and I was told off for "leaving landmines lying around".

> > +static inline int dax_zero_page_range(struct inode *i, loff_t frm,
> > +						unsigned len, get_block_t gb)
> > +{
> > +	return 0;
> 
> Should we return 0 or -ENOSYS here ?

I kind of wonder if we shouldn't just declare the function.  It's called
like this:

        if (IS_DAX(inode))
                return dax_zero_page_range(inode, from, length, ext4_get_block);
        return __ext4_block_zero_page_range(handle, mapping, from, length);

and if CONFIG_DAX is not set, IS_DAX evaluates to 0 at compile time, so
the compiler will optimise out the call to dax_zero_page_range() anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
