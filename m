Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCB36B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 17:47:57 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so4764862qcz.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:47:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b7si11790100qce.33.2015.01.13.14.47.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 14:47:56 -0800 (PST)
Date: Tue, 13 Jan 2015 14:47:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 08/20] dax,ext2: Replace the XIP page fault handler
 with the DAX page fault handler
Message-Id: <20150113144753.ea2658cdf1a78e1b8cbdb576@linux-foundation.org>
In-Reply-To: <20150113215334.GK5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-9-git-send-email-matthew.r.wilcox@intel.com>
	<20150112150952.b44ee750a6292284e7a909ff@linux-foundation.org>
	<20150113215334.GK5661@wil.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Jan 2015 16:53:34 -0500 Matthew Wilcox <willy@linux.intel.com> wrote:

> /*
>  * Lock ordering in mm:
>  *
>  * inode->i_mutex       (while writing or truncating, not reading or faulting)
>  *   mm->mmap_sem
> 
> > >  	   In the worst case, the file still has blocks
> > > +	 * allocated past the end of the file.
> > > +	 */
> > > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > > +	if (unlikely(vmf->pgoff >= size)) {
> > > +		error = -EIO;
> > > +		goto out;
> > > +	}
> > 
> > How does this play with holepunching?  Checking i_size won't work there?
> 
> It doesn't.  But the same problem exists with non-DAX files too, and
> when I pointed it out, it was met with a shrug from the crowd.  I saw a
> patch series just recently that fixes it for XFS, but as far as I know,
> btrfs and ext4 still don't play well with pagefault vs hole-punch races.

What are the user-visible effects of the race?

> > > +	memset(&bh, 0, sizeof(bh));
> > > +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
> > > +	bh.b_size = PAGE_SIZE;
> > 
> > ah, there.
> > 
> > PAGE_SIZE varies a lot between architectures.  What are the
> > implications of this>?
> 
> At the moment, you can only do DAX for blocksizes that are equal to
> PAGE_SIZE.  That's a restriction that existed for the previous XIP code,
> and I haven't fixed it all for DAX yet.  I'd like to, but it's not high on
> my list of things to fix.  Since these are in-mmeory filesystems, there's
> not likely to be high demand to move the filesystem between machines.

hm, I guess not.

This means that our users will need to mkfs their filesystems with
blocksize==pagesize.  The "error: unsupported blocksize for dax" printk
should get the message across, but a mention in
Documentation/filesystems/dax.txt's "Shortcomings" section wouldn't
hurt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
