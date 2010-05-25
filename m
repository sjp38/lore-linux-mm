Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E02C6008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:33:22 -0400 (EDT)
Date: Tue, 25 May 2010 06:33:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH (resend)] xfs: don't allow recursion into fs under
	write_begin
Message-ID: <20100525103317.GB2864@infradead.org>
References: <4BF8056E.8080900@sandeen.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BF8056E.8080900@sandeen.net>
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@sandeen.net>
Cc: xfs-oss <xfs@oss.sgi.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Michael Monnerie <michael.monnerie@is.it-management.at>
List-ID: <linux-mm.kvack.org>

On Sat, May 22, 2010 at 11:25:18AM -0500, Eric Sandeen wrote:
> Michael Monnerie reported this fantastic stack overflow:

> I don't think we can afford to let write_begin recurse into the fs,
> so we can set AOP_FLAG_NOFS ... is this too big a hammer?

I don't really like it.  There's nothing XFS-specific here - it's the
same problem with direct reclaim calling back into the FS and causing
massive amounts of problems.  If we want to fix this class of problems
we just need to do the same thing ext4 and btrfs already do and refuse
to call the allocator from reclaim context.

Just curious, how much stack does the path up to generic_perform_write
use?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
