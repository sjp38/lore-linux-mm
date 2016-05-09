Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 926D76B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 05:38:32 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so81546310lfq.2
        for <linux-mm@kvack.org>; Mon, 09 May 2016 02:38:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si25033705wme.34.2016.05.09.02.38.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 02:38:31 -0700 (PDT)
Date: Mon, 9 May 2016 11:38:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160509093828.GF11897@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <20160506203308.GA12506@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160506203308.GA12506@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Fri 06-05-16 14:33:08, Ross Zwisler wrote:
> On Mon, Apr 18, 2016 at 11:35:23PM +0200, Jan Kara wrote:
> > Hello,
> > 
> > this is my third attempt at DAX page fault locking rewrite. The patch set has
> > passed xfstests both with and without DAX mount option on ext4 and xfs for
> > me and also additional page fault beating using the new page fault stress
> > tests I have added to xfstests. So I'd be grateful if you guys could have a
> > closer look at the patches so that they can be merged. Thanks.
> > 
> > Changes since v2:
> > - lot of additional ext4 fixes and cleanups
> > - make PMD page faults depend on CONFIG_BROKEN instead of #if 0
> > - fixed page reference leak when replacing hole page with a pfn
> > - added some reviewed-by tags
> > - rebased on top of current Linus' tree
> > 
> > Changes since v1:
> > - handle wakeups of exclusive waiters properly
> > - fix cow fault races
> > - other minor stuff
> > 
> > General description
> > 
> > The basic idea is that we use a bit in an exceptional radix tree entry as
> > a lock bit and use it similarly to how page lock is used for normal faults.
> > That way we fix races between hole instantiation and read faults of the
> > same index. For now I have disabled PMD faults since there the issues with
> > page fault locking are even worse. Now that Matthew's multi-order radix tree
> > has landed, I can have a look into using that for proper locking of PMD faults
> > but first I want normal pages sorted out.
> > 
> > In the end I have decided to implement the bit locking directly in the DAX
> > code. Originally I was thinking we could provide something generic directly
> > in the radix tree code but the functions DAX needs are rather specific.
> > Maybe someone else will have a good idea how to distill some generally useful
> > functions out of what I've implemented for DAX but for now I didn't bother
> > with that.
> > 
> > 								Honza
> 
> Hey Jan,
> 
> Another hit in testing, which may or may not be related to the last one.  The
> BUG is a few lines off from the previous report:
> 	kernel BUG at mm/workingset.c:423!
> vs
> 	kernel BUG at mm/workingset.c:435!
> 
> I've been able to consistently hit this one using DAX + ext4 with generic/086.
> For some reason generic/086 always passes when run by itself, but fails
> consistently if you run it after a set of other tests.  Here is a relatively
> fast set that reproduces it:

Thanks for reports! It is strange that I didn't see this happening but I've
been testing against somewhat older base so maybe something has changed.
Anyway the culprit seems to be that workingset tracking code messes with
radix tree which is managed by DAX and these two were never meant to
coexist so assertions naturally trip. In particular we should not add radix
tree node to working-set list of nodes for eviction in
page_cache_tree_delete() for DAX inodes. However that seems to happen in
your case and so far I don't quite understand why...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
