Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 13A366B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:57:16 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id c203so2259423oia.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 15:57:16 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id s4si19363961obf.20.2016.02.28.15.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 15:57:15 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id ts10so120897315obc.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 15:57:15 -0800 (PST)
Date: Sun, 28 Feb 2016 15:57:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live
 pages
In-Reply-To: <20160204195324.GA8208@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1602281552160.2997@eggly.anvils>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org> <1454109573-29235-2-git-send-email-hannes@cmpxchg.org> <20160203131748.GB15520@mguzik> <20160203140824.GJ21016@esperanza> <20160203183547.GA4007@cmpxchg.org> <alpine.LSU.2.11.1602031648050.1497@eggly.anvils>
 <20160204195324.GA8208@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Mateusz Guzik <mguzik@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Greg Thelen <gthelen@google.com>

On Thu, 4 Feb 2016, Johannes Weiner wrote:
> On Wed, Feb 03, 2016 at 05:39:08PM -0800, Hugh Dickins wrote:
> 
> > And (even more off-topic), I'm slightly sad to see that the lrucare
> > arg which mem_cgroup_migrate() used to have (before I renamed it and
> > you renamed it back!) has gone, so mem_cgroup_migrate() now always
> > demands lrucare of commit_charge().  I'd hoped that with your
> > separation of new from old charge, mem_cgroup_migrate() would never
> > need lrucare; but that's not true for the fuse case, though true
> > for everyone else.  Maybe just not worth bothering about?  Or the
> > reintroduction of some unnecessary zone->lru_lock-ing in page
> > migration, which we ought to try to avoid?
> > 
> > Or am I wrong, and even fuse doesn't need it?  That early return
> > "if (newpage->mem_cgroup)": isn't mem_cgroup_migrate() a no-op for
> > fuse, or is there some corner case by which newpage can be on LRU
> > but its mem_cgroup unset?
> 
> That should be impossible nowadays.
> 
> I went through the git log to find out why we used to do the LRU
> handling for newpage, and the clue is in this patch and the way
> charging used to work at that time:
> 
> commit 5a6475a4e162200f43855e2d42bbf55bcca1a9f2
> Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date:   Wed Mar 23 16:42:42 2011 -0700
> 
>     memcg: fix leak on wrong LRU with FUSE
>     
>     fs/fuse/dev.c::fuse_try_move_page() does
>     
>        (1) remove a page by ->steal()
>        (2) re-add the page to page cache
>        (3) link the page to LRU if it was not on LRU at (1)
>     
>     This implies the page is _on_ LRU when it's added to radix-tree.  So, the
>     page is added to memory cgroup while it's on LRU.  because LRU is lazy and
>     no one flushs it.
> 
> We used to uncharge the page when deleting it from the page cache, not
> on the final put. So when fuse replaced a page in cache, it would
> uncharge the stolen page while it was on the LRU and then re-charge.
> 
> Nowadays this doesn't happen, and if newpage is a stolen page cache
> page it just remains charged and we bail out of the transfer.
> 
> I don't see a sceniaro where newpage would be uncharged yet on LRU.
> 
> Thanks for your insights, Hugh. I'll send patches to clean this up.

And thank you for following up and identifying that commit, which
explained why it was needed, and now is not.  Not a big deal, but
it is satisfying to be able to eliminate that piece of lrucruft,
as your patch then did: thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
