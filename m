Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id EA1216B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 21:25:50 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id r5so1132946qcx.28
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 18:25:50 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g1si14260326yhd.204.2014.09.16.18.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 18:25:50 -0700 (PDT)
Date: Tue, 16 Sep 2014 21:25:42 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Best way to pin a page in ext4?
Message-ID: <20140917012542.GO6205@thunk.org>
References: <20140915185102.0944158037A@closure.thunk.org>
 <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
 <20140916180759.GI6205@thunk.org>
 <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andreas Dilger <adilger@dilger.ca>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Tue, Sep 16, 2014 at 05:07:18PM -0700, Hugh Dickins wrote:
> You might (I'm not certain) be able to get away with extending the
> use of mlock_vma_page() and munlock_vma_page() in this (admittedly
> attractive) way, up until someone mmap's that range (and mlocks
> then munlocks it? again, I'm not certain if that's necessary).
> Then the PageMlocked flag is liable to be cleared, because the
> page will not be found in any mlock'ed vma; and the page can
> then be reclaimed behind your back (statistics gone wrong too?
> again I'm not sure).
> 
> Now, I expect it's unlikely (impossible?) for anyone to mmap your
> bitmap pages while they're being used as filesystem metadata (rather
> than mere blockdev pages).  But you can see why we would prefer not
> to export those functions.

Yes, it's impossible for anyone to mmap the pages from
EXT4_SB(sb)->s_buddy_cache inode, because it's not exposed in any way
to userspace.  But I can see why you wouldn't want it to be used
almost anywhere else.

> For now I agree with Andreas, just grab an extra refcount; but you're
> right that leaving these pages on evictable LRUs is regrettable,
> and can be inefficient under reclaim.

OK, fair enough, that seems simpler all around.

Cheers,

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
