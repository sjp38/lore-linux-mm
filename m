Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B73A6B02A4
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 21:28:26 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o691SOfk031570
	for <linux-mm@kvack.org>; Thu, 8 Jul 2010 18:28:24 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by wpaz1.hot.corp.google.com with ESMTP id o691SNrk010731
	for <linux-mm@kvack.org>; Thu, 8 Jul 2010 18:28:23 -0700
Received: by pwi1 with SMTP id 1so630155pwi.1
        for <linux-mm@kvack.org>; Thu, 08 Jul 2010 18:28:22 -0700 (PDT)
Date: Thu, 8 Jul 2010 18:28:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH]shmem: reduce one time of locking in pagefault
In-Reply-To: <20100707013919.GA22097@sli10-desk.sh.intel.com>
Message-ID: <alpine.DEB.1.00.1007081814420.1132@tigran.mtv.corp.google.com>
References: <1278465346.11107.8.camel@sli10-desk.sh.intel.com> <20100706183254.cf67e29e.akpm@linux-foundation.org> <20100707013919.GA22097@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jul 2010, Shaohua Li wrote:
> On Wed, Jul 07, 2010 at 09:32:54AM +0800, Andrew Morton wrote:
> > 
> > The patch doesn't make shmem_getpage() any clearer :(

:)

> > 
> > shmem_inode_info.lock appears to be held too much.  Surely
> > lookup_swap_cache() didn't need it (for example).
> > 
> > What data does shmem_inode_info.lock actually protect?
> As far as my understanding, it protects shmem swp_entry, which is most used
> to support swap. It also protects some accounting. If no swap, the lock almost
> can be removed like tiny-shmem.

That's right: shmem_info_info.lock protects what's in shmem_inode_info,
plus what hangs off it (the shmem_swp blocks).

We want that lock across the lookup_swap_cache() to be sure that what we
find is still what we want (otherwise another thread might bring it out
of swap and that swap be reused for something else) - the page lock is
good once you have a page to lock, but until then....  I guess could be
done by dropping the lock then retaking and rechecking after, but that
would go right against the grain of this patch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
