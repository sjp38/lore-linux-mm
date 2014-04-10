Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id BD68C6B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:43:50 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so3402853eek.9
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 11:43:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g47si7077578eet.324.2014.04.10.11.43.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 11:43:48 -0700 (PDT)
Date: Thu, 10 Apr 2014 20:43:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 18/22] xip: Add xip_zero_page_range
Message-ID: <20140410184346.GD8060@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <5a87acda8c3e4d2b7ea5dd1249fcbf8be23b9645.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409101512.GL32103@quack.suse.cz>
 <20140410142729.GL5727@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140410142729.GL5727@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu 10-04-14 10:27:29, Matthew Wilcox wrote:
> On Wed, Apr 09, 2014 at 12:15:12PM +0200, Jan Kara wrote:
> > > +		/*
> > > +		 * ext4 sometimes asks to zero past the end of a block.  It
> > > +		 * really just wants to zero to the end of the block.
> > > +		 */
> >   Then we should really fix ext4 I believe...
> 
> Since I didn't want to do this ...
> 
> > > +/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
> > > +#define dax_truncate_page(inode, from, get_block)	\
> > > +	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
> >                                          ^^^^
> > This should be (PAGE_CACHE_SIZE - (from & (PAGE_CACHE_SIZE - 1))), shouldn't it?
> 
> ... I could get away without doing that ;-)
  I understand but ultimately the API is cleaner if it doesn't allow size
past end of block. So IMHO we shouldn't introduce new places that call the
function like this and we should fix places that do it now (make it
WARN_ON_ONCE() and let ext4 guys do the work for you ;).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
