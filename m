Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 989B96B00A9
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 14:05:56 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so7434625pbb.28
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 11:05:56 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id gg7si7505959pac.188.2014.04.13.11.05.55
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 11:05:55 -0700 (PDT)
Date: Sun, 13 Apr 2014 14:05:52 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140413180552.GS5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408175600.GE2713@quack.suse.cz>
 <20140408202102.GB5727@linux.intel.com>
 <20140409091450.GA32103@quack.suse.cz>
 <20140409151908.GD5727@linux.intel.com>
 <20140409205529.GO32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409205529.GO32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 10:55:29PM +0200, Jan Kara wrote:
> > In addition to writing back dirty pages, filemap_write_and_wait_range()
> > will evict clean pages.  Unintuitive, I know, but it matches what the
> > direct I/O path does.  Plus, if we fall back to buffered I/O for holes
> > (see above), then this will do the right thing at that time.
>   Ugh, I'm pretty certain filemap_write_and_wait_range() doesn't evict
> anything ;). Direct IO path calls that function so that direct IO read
> after buffered write returns the written data. In that case we don't evict
> anything from page cache because direct IO read doesn't invalidate any
> information we have cached. Only direct IO write does that and for that we
> call invalidate_inode_pages2_range() after writing the pages. So I maintain
> that what you do doesn't make sense to me. You might need to do some
> invalidation of hole pages. But note that generic_file_direct_write() does
> that for you and even though that isn't serialized in any way with page
> faults which can instantiate the hole pages again, things should work out
> fine for you since that function also invalidates the range again after
> ->direct_IO callback is done. So AFAICT you don't have to do anything
> except writing some nice comment about this ;).

You're right.  I'm not sure what I got confused with there.  I don't
think there's a race I need to worry about ... even if another page gets
instantiated (consider one thread furiously loading from a hole as fast
as it can while another thread does a write), we'll shoot it down again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
