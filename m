Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF766B025E
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 10:09:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so13386499wmp.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 07:09:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jm1si1023612wjb.11.2016.07.26.07.09.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 07:09:35 -0700 (PDT)
Date: Tue, 26 Jul 2016 16:09:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 14/15] dax: Protect PTE modification on WP fault by radix
 tree entry lock
Message-ID: <20160726140930.GD6860@quack2.suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
 <1469189981-19000-15-git-send-email-jack@suse.cz>
 <20160725213059.GA19713@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725213059.GA19713@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>

On Mon 25-07-16 15:30:59, Ross Zwisler wrote:
> On Fri, Jul 22, 2016 at 02:19:40PM +0200, Jan Kara wrote:
> > Currently PTE gets updated in wp_pfn_shared() after dax_pfn_mkwrite()
> > has released corresponding radix tree entry lock. When we want to
> > writeprotect PTE on cache flush, we need PTE modification to happen
> > under radix tree entry lock to ensure consisten updates of PTE and radix
> > tree (standard faults use page lock to ensure this consistency). So move
> > update of PTE bit into dax_pfn_mkwrite().
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> After applying the whole series to a v4.7 baseline I was hitting a deadlock in
> my testing, and it bisected to this commit.  This deadlock happens in my QEMU
> guest with generic/068, ext4 and DAX.  It reproduces 100% of the time after
> this commit.
> 
> Here is the lockdep info, passed through kasan_symbolize.py:

Thanks! I've checked why I didn't see this and apparently I've run last
round of testing on the wrong branch. Drat.

I've fixed the bug you've spotted (we need to release tree_lock earlier)
but xfstests are triggering some more issues now for me so I'm debugging
those.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
