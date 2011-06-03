Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 662806B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 01:16:14 -0400 (EDT)
Date: Fri, 3 Jun 2011 01:16:09 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/14] tmpfs: take control of its truncate_range
Message-ID: <20110603051609.GC16721@infradead.org>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
 <alpine.LSU.2.00.1105301737040.5482@sister.anvils>
 <20110601003942.GB4433@infradead.org>
 <alpine.LSU.2.00.1106010940590.23468@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106010940590.23468@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 01, 2011 at 09:58:18AM -0700, Hugh Dickins wrote:
> (i915 isn't really doing hole-punching there, I think it just found it
> a useful interface to remove the page-and-swapcache without touching
> i_size.  Parentheses because it makes no difference to your point.)

Keeping i_size while removing pages on tmpfs fits the defintion of hole
punching for me.  Not that it matters anyway.

> When I say "shmem", I am including the !SHMEM-was-TINY_SHMEM case too,
> which goes to ramfs.  Currently i915 has been configured to disable that
> possibility, though we insisted on it originally: there may or may not be
> good reason for disabling it - may just be a side-effect of the rather
> twisted unintuitive SHMEM/TMPFS dependencies.

Hmm, the two different implementations make everything harder.  Also
because we don't even implement the hole punching in !SHMEM tmpfs.

> Fine, I'll add tmpfs PUNCH_HOLE later on.  And wire up madvise MADV_REMOVE
> to fallocate PUNCH_HOLE, yes?

Yeah.  One thing I've noticed is that the hole punching doesn't seem
to do the unmap_mapping_range.  It might be worth to audit that from the
VM point of view.

> Would you like me to remove the ->truncate_range method from
> inode_operations completely?

Doing that would be nice.  Do we always have the required file struct
for ->fallocate in the callers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
