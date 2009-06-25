Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AAE986B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:46:29 -0400 (EDT)
Date: Thu, 25 Jun 2009 13:47:55 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite
	when blocksize < pagesize
Message-ID: <20090625174754.GA21957@infradead.org>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090625161753.GB30755@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 06:17:53PM +0200, Nick Piggin wrote:
> Basically the problems is that i_op->truncate a) cannot return an error
> (which is causing problems missing -EIO today anyway), and b) is called
> after i_size update which makes it not possible to error-out without
> races anyway, and c) does not get the old i_size so you can't unmap the
> last partial page with it.
> 
> My patch is basically moving ->truncate call into setattr, and have
> the filesystem call vmtruncate. I've jt to clean up loose ends.

We absolutely need to get rid of ->truncate.  Due to the above issues
XFS already does the majority of the truncate work from setattr, and it
works pretty well.  The only problem is the generic aops calling
vmtruncate directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
