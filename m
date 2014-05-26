Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE826B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 16:48:48 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 142so6409592ykq.4
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:48:47 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id s62si21062108yhn.213.2014.05.26.13.48.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 13:48:47 -0700 (PDT)
Message-ID: <1401137322.12982.5.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 4/5] mm/rmap: share the i_mmap_rwsem
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 26 May 2014 13:48:42 -0700
In-Reply-To: <alpine.LSU.2.11.1405261216460.3411@eggly.anvils>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
	 <1400816006-3083-5-git-send-email-davidlohr@hp.com>
	 <alpine.LSU.2.11.1405261216460.3411@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 2014-05-26 at 12:35 -0700, Hugh Dickins wrote:
> On Thu, 22 May 2014, Davidlohr Bueso wrote:
> 
> > Similarly to rmap_walk_anon() and collect_procs_anon(),
> > there is opportunity to share the lock in rmap_walk_file()
> > and collect_procs_file() for file backed pages.
> 
> And lots of other places, no?  I welcome i_mmap_rwsem, but I think
> you're approaching it wrongly to separate this off from 2/5, then
> follow anon_vma for the places that can be converted to lock_read().

Sure, but as you can imagine, the reasoning behind it is simplicity and
bisectability. 2/5 is easy to commit typo-like errors, and end up
locking instead of unlocking and vice versa. I ran into a few while
testing and wanted to make life easier for reviewers.

> If you go back through 2/5 and study the context of each, I think
> you'll find most make no modification to the tree, and can well
> use the lock_read() rather than the lock_write().

I was planning on revisiting some of that. I have no concrete examples
yet, but I agree, there could very well be further opportunity to share
the lock in read-only paths. This 4/5 is just the first, and most
obvious, step towards improving the usage of the i_mmap lock.

> I could be wrong, but I don't think there are any hidden gotchas.
> There certainly are in the anon_vma case (where THP makes special
> use of the anon_vma lock), and used to be in the i_mmap_lock case
> (when invalidation had to be single-threaded across cond_rescheds),
> but I think i_mmap_rwsem should be straightforward.
> 
> Sure, it's safe to use the lock_write() variant, but please don't
> prefer it to lock_read() without good reason.

I will dig deeper (probably for 3.17 now), but I really believe this is
the correct way of splitting the patches for this particular series.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
