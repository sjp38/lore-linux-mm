Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E7EE76B00EB
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:58:57 -0400 (EDT)
Date: Tue, 15 May 2012 02:58:54 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] xfs: hole-punch retaining cache beyond
Message-ID: <20120515065854.GB7373@infradead.org>
References: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
 <alpine.LSU.2.00.1205131350150.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205131350150.1547@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 13, 2012 at 01:51:18PM -0700, Hugh Dickins wrote:
> xfs has a very inefficient hole-punch implementation, invalidating all
> the cache beyond the hole (after flushing dirty back to disk, from which
> all must be read back if wanted again).  So if you punch a hole in a
> file mlock()ed into userspace, pages beyond the hole are inadvertently
> munlock()ed until they are touched again.
> 
> Is there a strong internal reason why that has to be so on xfs?
> Or is it just a relic from xfs supporting XFS_IOC_UNRESVSP long
> before Linux 2.6.16 provided truncate_inode_pages_range()?
> 
> If the latter, then this patch mostly fixes it, by passing the proper
> range to xfs_flushinval_pages().  But a little more should be done to
> get it just right: a partial page on either side of the hole is still
> written back to disk, invalidated and munlocked.

I think the original reason is that no range version of the macros
existed.  Giving the somewhat odd calling convention I'd prefer to
simplify deprecate the old wrappers and convert the callers to direct
calls of the VM functions on a 1 by 1 basis.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
