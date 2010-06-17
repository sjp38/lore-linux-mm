Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C75446B01B5
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 05:12:22 -0400 (EDT)
Date: Thu, 17 Jun 2010 11:11:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2 v4] Writeback livelock avoidance for data integrity
 writes
Message-ID: <20100617091156.GB3453@quack.suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276706031-29421-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

  Sorry for replying to my email but I forgot to set a subject while doing
git send-email. So at least set it now.

								Honza

On Wed 16-06-10 18:33:49, Jan Kara wrote:
>   Hello,
> 
>   here is the fourth version of the writeback livelock avoidance patches
> for data integrity writes. To quickly summarize the idea: we tag dirty
> pages at the beginning of write_cache_pages with a new TOWRITE tag and
> then write only tagged pages to avoid parallel writers to livelock us.
> See changelogs of the patches for more details.
>   I have tested the patches with fsx and a test program I wrote which
> checks that if we crash after fsync, the data is indeed on disk.
>   If there are no more concerns, can these patches get merged?
> 
> 								Honza
> 
>   Changes since last version:
> - tagging function was changed to stop after given amount of pages to
>   avoid keeping tree_lock and irqs disabled for too long
> - changed names and updated comments as Andrew suggested
> - measured memory impact and reported it in the changelog
> 
>   Things suggested but not changed (I want to avoid going in circles ;):
> - use tagging also for WB_SYNC_NONE writeback - there's problem with an
>   interaction with wbc->nr_to_write. If we tag all dirty pages, we can
>   spend too much time tagging when we write only a few pages in the end
>   because of nr_to_write. If we tag only say nr_to_write pages, we may
>   not have enough pages tagged because some pages are written out by
>   someone else and so we would have to restart and tagging would become
>   essentially useless. So my option is - switch to tagging for WB_SYNC_NONE
>   writeback if we can get rid of nr_to_write. But that's a story for
>   a different patch set.
> - implement function for clearing several tags (TOWRITE, DIRTY) at once
>   - IMHO not worth it because we would save only conversion of page index
>   to radix tree offsets. The rest would have to be separate anyways. And
>   the interface would be incosistent as well...
> - use __lookup_tag to implement radix_tree_range_tag_if_tagged - doesn't
>   quite work because __lookup_tag returns only leaf nodes so we'd have to
>   implement tree traversal anyways to tag also internal nodes.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
