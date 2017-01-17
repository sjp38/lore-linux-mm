Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4146B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:46:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p192so34369163wme.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 07:46:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b79si16329047wma.103.2017.01.17.07.46.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 07:46:40 -0800 (PST)
Date: Tue, 17 Jan 2017 16:46:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] sharing pages between mappings
Message-ID: <20170117154637.GT2517@quack2.suse.cz>
References: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
 <20170111115143.GJ16116@quack2.suse.cz>
 <CAJfpeguuBgypYh3G1Ew1a37o4WuRozPzLe=D_gh2BbtYXE=zzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpeguuBgypYh3G1Ew1a37o4WuRozPzLe=D_gh2BbtYXE=zzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Wed 11-01-17 15:13:19, Miklos Szeredi wrote:
> On Wed, Jan 11, 2017 at 12:51 PM, Jan Kara <jack@suse.cz> wrote:
> > On Wed 11-01-17 11:29:28, Miklos Szeredi wrote:
> >> I know there's work on this for xfs, but could this be done in generic mm
> >> code?
> >>
> >> What are the obstacles?  page->mapping and page->index are the obvious
> >> ones.
> >
> > Yes, these two are the main that come to my mind. Also you'd need to
> > somehow share the mapping->i_mmap tree so that unmap_mapping_range() works.
> >
> >> If that's too difficult is it maybe enough to share mappings between
> >> files while they are completely identical and clone the mapping when
> >> necessary?
> >
> > Well, but how would the page->mapping->host indirection work? Even if you
> > have identical contents of the mappings, you still need to be aware there
> > are several inodes behind them and you need to pick the right one
> > somehow...
> 
> When do we actually need page->mapping->host?  The only place where
> it's not available is page writeback.  Then we can know that the
> original page was already cow-ed and after being cowed, the page
> belong only to a single inode.

Yeah, in principle the information may exist, however propagating it to all
appropriate place may be a mess.

> What then happens if the newly written data is cloned before being
> written back?   We can either write back the page during the clone, so
> that only clean pages are ever shared.  Or we can let dirty pages be
> shared between inodes.

The former is what I'd suggest for sanity... I.e. share only read-only
pages.

> In that latter case the question is: do we
> care about which inode we use for writing back the data?  Is the inode
> needed at all?  I don't know enough about filesystem internals to see
> clearly what happens in such a situation.
> 
> >> All COW filesystems would benefit, as well as layered ones: lots of
> >> fuse fs, and in some cases overlayfs too.
> >>
> >> Related:  what can DAX do in the presence of cloned block?
> >
> > For DAX handling a block COW should be doable if that is what you are
> > asking about. Handling of blocks that can be written to while they are
> > shared will be rather difficult (you have problems with keeping dirty bits
> > in the radix tree consistent if nothing else).
> 
> What happens if you do:
> 
> - clone_file_range(A, off1, B, off2, len);
> 
> - mmap both A and B using DAX.
> 
> The mapping will contain the same struct page for two different mappings, no?

Not the same struct page, as DAX does not have pages with struct page.
However the same pfn will be underlying off1 of A and off2 of B. And for
reads this is just fine. Once you want to write, you have to make sure you
COW before you start modifying the data or you'll get data corruption (we
synchronize operations using the exceptional entries in mapping->page_tree
in DAX and these are separate for A and B).

									Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
