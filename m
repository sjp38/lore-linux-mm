Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3F96B0038
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 17:24:35 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id y195so8211724oia.22
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 14:24:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d70si3861312oig.310.2017.12.28.14.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Dec 2017 14:24:34 -0800 (PST)
Date: Fri, 29 Dec 2017 09:24:20 +1100
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
Message-ID: <20171228222419.GQ1871@rh>
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227220636.361857279@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>

On Wed, Dec 27, 2017 at 04:06:36PM -0600, Christoph Lameter wrote:
> This is a patchset on top of Matthew Wilcox Xarray code and implements
> object migration of xarray nodes. The migration is integrated into
> the defragmetation and shrinking logic of the slab allocator.
.....
> This is only possible for xarray for now but it would be worthwhile
> to extend this to dentries and inodes.

Christoph, you keep saying this is the goal, but I'm yet to see a
solution proposed for the atomic replacement of all the pointers to
an inode from external objects.  An inode that has no active
references still has an awful lot of passive and internal references
that need to be dealt with.

e.g. racing page operations accessing mapping->host, the inode in
various lists (e.g. superblock inode list, writeback lists, etc),
the inode lookup cache(s), backpointers from LSMs, fsnotify marks,
crypto information, internal filesystem pointers (e.g. log items,
journal handles, buffer references, etc) and so on. And each
filesystem has a different set of passive references, too.

Oh, and I haven't even mentioned deadlocks yet, either. :P

IOWs, just saying "it would be worthwhile to extend this to dentries
and inodes" completely misrepresents the sheer complexity of doing
so. We've known that atomic replacement is the big problem for
defragging inodes and dentries since this work was started, what,
more than 10 years? And while there's been many revisions of the
core defrag code since then, there has been no credible solution
presented for atomic replacement of objects with complex external
references. This is a show-stopper for inode/dentry slab defrag, and
I don't see that this new patchset is any different...

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
