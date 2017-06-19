Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 456AF6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 14:20:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v14so12703419wmf.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 11:20:11 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id b76si11284146wmi.63.2017.06.19.11.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 11:20:09 -0700 (PDT)
Date: Mon, 19 Jun 2017 19:19:57 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH 1/2] mm: introduce bmap_walk()
Message-ID: <20170619181956.GH10672@ZenIV.linux.org.uk>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170617052212.GA8246@lst.de>
 <CAPcyv4g=x+Af1C8_q=+euwNw_Fwk3Wwe45XibtYR5=kbOcmgfg@mail.gmail.com>
 <20170618075152.GA25871@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170618075152.GA25871@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Jun 18, 2017 at 09:51:52AM +0200, Christoph Hellwig wrote:

> > That said, I think "please don't add a new bmap()
> > user, use iomap instead" is a fair comment. You know me well enough to
> > know that would be all it takes to redirect my work, I can do without
> > the bluster.
> 
> But that's not the point.  The point is that ->bmap() semantics simplify
> do not work in practice because they don't make sense.

Speaking of iomap, what's supposed to happen when doing a write into what
used to be a hole?  Suppose we have a file with a megabyte hole in it
and there's some process mmapping that range.  Another process does
write over the entire range.  We call ->iomap_begin() and allocate
disk blocks.  Then we start copying data into those.  In the meanwhile,
the first process attempts to fetch from address in the middle of that
hole.  What should happen?

Should the blocks we'd allocated in ->iomap_begin() be immediately linked
into the whatever indirect locks/btree/whatnot we are using?  That would
require zeroing all of them first - otherwise that readpage will read
uninitialized block.  Another variant would be to delay linking them
in until ->iomap_end(), but...  Suppose we get the page evicted by
memory pressure after the writer is finished with it.  If ->readpage()
comes before ->iomap_end(), we'll need to somehow figure out that it's
not a hole anymore, or we'll end up with an uptodate page full of zeroes
observed by reads after successful write().

The comment you've got in linux/iomap.h would seem to suggest the second
interpretation, but neither it nor anything in Documentation discusses the
relations with readpage/writepage...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
