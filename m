Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DC0316B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 22:03:14 -0500 (EST)
Received: by iacb35 with SMTP id b35so4538040iac.14
        for <linux-mm@kvack.org>; Fri, 16 Dec 2011 19:03:14 -0800 (PST)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 05/11] mm: compaction: Determine if dirty pages can be migrated without blocking within ->migratepage
Date: Sat, 17 Dec 2011 11:03:01 +0800
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-6-git-send-email-mgorman@suse.de> <20111216152054.f7445e98.akpm@linux-foundation.org>
In-Reply-To: <20111216152054.f7445e98.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201112171103.01613.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Saturday 17 December 2011 07:20:54 Andrew Morton wrote:
> On Wed, 14 Dec 2011 15:41:27 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Asynchronous compaction is used when allocating transparent hugepages
> > to avoid blocking for long periods of time. Due to reports of
> > stalling, there was a debate on disabling synchronous compaction
> > but this severely impacted allocation success rates. Part of the
> > reason was that many dirty pages are skipped in asynchronous compaction
> > by the following check;
> > 
> > 	if (PageDirty(page) && !sync &&
> > 		mapping->a_ops->migratepage != migrate_page)
> > 			rc = -EBUSY;
> > 
> > This skips over all mapping aops using buffer_migrate_page()
> > even though it is possible to migrate some of these pages without
> > blocking. This patch updates the ->migratepage callback with a "sync"
> > parameter. It is the responsibility of the callback to fail gracefully
> > if migration would block.
> > 
> > ...
> >
> > @@ -259,6 +309,19 @@ static int migrate_page_move_mapping(struct address_space *mapping,
> >  	}
> >  
> >  	/*
> > +	 * In the async migration case of moving a page with buffers, lock the
> > +	 * buffers using trylock before the mapping is moved. If the mapping
> > +	 * was moved, we later failed to lock the buffers and could not move
> > +	 * the mapping back due to an elevated page count, we would have to
> > +	 * block waiting on other references to be dropped.
> > +	 */
> > +	if (!sync && head && !buffer_migrate_lock_buffers(head, sync)) {
> 
> Once it has been established that "sync" is true, I find it clearer to
> pass in plain old "true" to buffer_migrate_lock_buffers().  Minor point.
> 
> 
> 
> I hadn't paid a lot of attention to buffer_migrate_page() before. 
> Scary function.  I'm rather worried about its interactions with ext3
> journal commit which locks buffers then plays with them while leaving
> the page unlocked.  How vigorously has this been whitebox-tested?

buffer_migrate_page() is done under page lock & buffer head locks.

I had assumed that anyone who has locked the buffer_heads should 
also have a stable relationship between buffer_head <---> page,
otherwise, the buffer_head locking semantics should be broken itself ?

I am actually using the similar logic for some other stuff,
it will make me cry if it can really crash ext3....


Thanks,

Nai 

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
