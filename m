Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A21426B00FE
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 17:09:11 -0400 (EDT)
Date: Tue, 27 Mar 2012 23:08:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: [TOPIC] Last iput() from flusher thread, last fput() from
 munmap()...
Message-ID: <20120327210858.GH5020@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

  Hello,

  maybe the name of this topic could be "How hard should be life of
filesystems?" but that's kind of broad topic and suggests too much of
bikeshedding. I'd like to concentrate on concrete possible pain points
between filesystems & VFS (possibly writeback or even generally MM).
Lately, I've myself came across the two issues in $SUBJECT:
1) dropping of last file reference can happen from munmap() and in that
   case mmap_sem will be held when ->release() is called. Even more it
   could be held when ->evict_inode() is called to delete inode because
   inode was unlinked.
2) since flusher thread takes inode reference when writing inode out, the
   last inode reference can be dropped from flusher thread. Thus inode may
   get deleted in the flusher thread context. This does not seem that
   problematic on its own but if we realize progress of memory reclaim
   depends (at least from a longterm perspective) on flusher thread making
   progress, things start looking a bit uncertain. Even more so when we
   would like avoid ->writepage() calls from reclaim and let flusher thread
   do the work instead. That would then require filesystems to carefully
   design their ->evict_inode() routines so that things are not
   deadlockable.

  Both these issues should be avoidable (we can postpone fput() after we
drop mmap_sem; we can tweak inode refcounting to avoid last iput() from
flusher thread) but obviously there's some cost in the complexity of generic
layer. So the question is, is it worth it?

Certainly we can also discuss other pain points if people come with them.
We should have enough know-how in place to be able to tell which changes
are reasonably possible and which are not...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
