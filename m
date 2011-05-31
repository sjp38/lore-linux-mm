Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 739AE6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:05:47 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4VH5j1N017865
	for <linux-mm@kvack.org>; Tue, 31 May 2011 10:05:45 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe14.cbf.corp.google.com with ESMTP id p4VH5Zh4009999
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 May 2011 10:05:35 -0700
Received: by pwi8 with SMTP id 8so2572468pwi.8
        for <linux-mm@kvack.org>; Tue, 31 May 2011 10:05:35 -0700 (PDT)
Date: Tue, 31 May 2011 10:05:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: RE: [PATCH 1/14] mm: invalidate_mapping_pages flush cleancache
In-Reply-To: <ba74b4e5-500e-4662-ade0-c0b714b8f570@default>
Message-ID: <alpine.LSU.2.00.1105310951160.1719@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils alpine.LSU.2.00.1105301733500.5482@sister.anvils> <ba74b4e5-500e-4662-ade0-c0b714b8f570@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, chris.mason@oracle.com

On Tue, 31 May 2011, Dan Magenheimer wrote:
> > 
> > truncate_inode_pages_range() and invalidate_inode_pages2_range()
> > call cleancache_flush_inode(mapping) before and after: shouldn't
> > invalidate_mapping_pages() be doing the same?
> 
> I don't claim to be an expert on VFS, and so I have cc'ed
> Chris Mason who originally placed the cleancache hooks
> in VFS, but I think this patch is unnecessary.  Instead
> of flushing ALL of the cleancache pages belonging to
> the inode with cleancache_flush_inode, the existing code
> eventually calls __delete_from_page_cache on EACH page
> that is being invalidated.

On each one that's in pagecache (and satisfies the other "can we
do it easily?" conditions peculiar to invalidate_mapping_pages()).
But there may be other slots in the range that don't reach
__delete_from_page_cache() e.g. because not currently in pagecache,
but whose cleancache ought to be flushed.  I think that's what a
caller of invalidate_mapping_pages(), e.g. drop caches, expects.

> And since __delete_from_page_cache
> calls cleancache_flush_page, only that subset of pages
> in the mapping that invalidate_mapping_pages() would
> invalidate (which, from the comment above the routine
> indicates, is only *unlocked* pages) is removed from
> cleancache.

It's nice to target the particular range asked for, rather than
throwing away all the cleancache for the whole mapping, I can
see that (though that's a defect in the cleancache_flush_inode()
interface).  But then why do truncate_inode_pages_range() and
invalidate_inode_pages2_range() throw it all away, despite
going down to __delete_from_page_cache on individual pages found?

Maybe the right patch is to remove cleancache_flush_inode() from
the two instead of adding it to the one?  But I think not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
