Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 668C86B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:08:02 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id n8so306273qaq.40
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 11:08:02 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id n67si13627175yhp.61.2014.09.16.11.08.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 11:08:01 -0700 (PDT)
Date: Tue, 16 Sep 2014 14:07:59 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Best way to pin a page in ext4?
Message-ID: <20140916180759.GI6205@thunk.org>
References: <20140915185102.0944158037A@closure.thunk.org>
 <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Mon, Sep 15, 2014 at 02:57:23PM -0600, Andreas Dilger wrote:
> 
> As discussed in http://lists.openwall.net/linux-ext4/2013/03/25/15
> the bitmap pages were being evicted under memory pressure even when
> they are active use.  That turned out to be an MM problem and not an
> ext4 problem in the end, and was fixed in commit c53954a092d in 3.11,
> in case you are running an older kernel.

Yes, I remember.  And that could potentially be a contributing factor,
since the user in question is using 3.2.  However, the user in
question has a use case where bitmap pinning is probably going to be
needed given the likely allocation patterns of a DVR; if the pages
aren't pinned, it's likely that by the time the DVR needs to fallocate
space for a new show, the bitmap pages would have been aged out due to
not being frequently accessed enough, even if the usage tracking was
backported to a 3.2 kernel.

> > The other approach would be to keep an elevated refcount on the pages in
> > question, but it seemed it would be more efficient use the mlock
> > facility since that keeps the pages on an unevictable list.
> 
> It doesn't seem unreasonable to just grab an extra refcount on the pages
> when they are first loaded.  

Well yes, but using mlock_vma_page() would be a bit more efficient,
and technically, more correct than simply elevating the refcount.

> However, the memory usage may be fairly
> high (32MB per 1TB of disk) so this definitely can't be generally used,
> and it would be nice to make sure that ext4 is already doing the right
> thing to keep these important pages in cache.

Well, as I mentioned above, the use case in question is a DVR, where
having the disk need to suddenly seek a large number block groups, and
thus pull in a largish number of allocation bitmaps, might be harmful
for a video replay that might be happening at the same time that the
DVR needs to fallocate space for a new TV show to be recorded.

And for a 2TB disk, the developer in question felt that he could
afford pinning 64MB.  So no, it's not a general solution, but it's
probably good enough for now.

Long run, I think we really need to consider trying to cache free
space information in some kind in-memory of rbtree, with a bail-out in
the worst case of the free space is horrendously fragmented in a
particular block group.  But as a quick hack, using mlock_vma_page()
was the simplest short term solution.

The main question then for the mm developers is would there be
objections in making mlock/munlock_vma_page() be EXPORT_SYMBOL_GPL and
moving the function declaration from mm/internal.h to
include/linux/mm.h?

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
