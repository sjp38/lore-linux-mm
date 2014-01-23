Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id E452A6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 02:54:10 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 142so1950687ykq.2
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 23:54:10 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id 69si14344406yhc.266.2014.01.22.23.54.08
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 23:54:09 -0800 (PST)
Date: Thu, 23 Jan 2014 18:53:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Message-ID: <20140123075356.GM13997@dastard>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
 <20140123074825.GL13997@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123074825.GL13997@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu, Jan 23, 2014 at 06:48:25PM +1100, Dave Chinner wrote:
> On Wed, Jan 15, 2014 at 08:24:18PM -0500, Matthew Wilcox wrote:
> > This series of patches add support for XIP to ext4.  Unfortunately,
> > it turns out to be necessary to rewrite the existing XIP support code
> > first due to races that are unfixable in the current design.
> > 
> > Since v4 of this patchset, I've improved the documentation, fixed a
> > couple of warnings that a newer version of gcc emitted, and fixed a
> > bug where we would read/write the wrong address for I/Os that were not
> > aligned to PAGE_SIZE.
> > 
> > I've dropped the PMD fault patch from this set since there are some
> > places where we would need to split a PMD page and there's no way to do
> > that right now.  In its place, I've added a patch which attempts to add
> > support for unwritten extents.  I'm still in two minds about this; on the
> > one hand, it's clearly a win for reads and writes.  On the other hand,
> > it adds a lot of complexity, and it probably isn't a win for pagefaults.
> 
> FYI, this may just be pure coincidence, but shortly after the first
> boot of a machine with this patchset on 3.13 the root *ext3*
> filesystem started having problems.  It now gives persistent ENOSPC
> errors when there's 2.3GB of space free (on a 8GB partition), even
> though e2fsck says the filesystem is clean and error free.
> 
> Fmeh.
> 
> Update: I've just removed the patchset, rebuilt the kernel and the
> ENOSPC problem is still there. So it may be co-incidence, but given
> that it is persistent something is screwed got screwed up in the
> filesytem.

OK, false alarm - it is co-incidence. The damn root filesystem ran
out of inodes. Can you beleive that you're only allowed 600k inodes
in an 8GB filesystems? Sheesh! :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
