Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0113D6B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 09:57:01 -0500 (EST)
Date: Tue, 3 Nov 2009 15:56:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] [PATCH] Avoid livelock for fsync
Message-ID: <20091103145654.GC29873@duck.suse.cz>
References: <20091026181314.GE7233@duck.suse.cz> <20091103131434.GA9648@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091103131434.GA9648@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, chris.mason@oracle.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

  Hi Fengguang,

On Tue 03-11-09 21:14:34, Wu Fengguang wrote:
> Sorry for being late! - for some reason I was just able to see your email.
  No problem :).

> On Mon, Oct 26, 2009 at 07:13:14PM +0100, Jan Kara wrote:
> >   Hi,
> > 
> >   on my way back from Kernel Summit, I've coded the attached patch which
> > implements livelock avoidance for write_cache_pages. We tag patches that
> > should be written in the beginning of write_cache_pages and then write
> > only tagged pages (see the patch for details). The patch is based on Nick's
> > idea.
> 
> Yes, tagging is a very fine grained way for livelock avoidance.
> However I doubt this patch can achieve the simplification goals
> listed below..
> 
> >   The next thing I've aimed at with this patch is a simplification of
> > current writeback code. Basically, with this patch I think we can just rip
> > out all the range_cyclic and nr_to_write (or other "fairness logic"). The
> > rationalle is following:
> >   What we want to achieve with fairness logic is that when a page is
> > dirtied, it gets written to disk within some reasonable time (like 30s or
> 
> Right.
> 
> > so). We track dirty time on per-inode basis only because keeping it
> > per-page is simply too expensive. So in this setting fairness between
> 
> Right.
> 
> > inodes really does not make any sence - why should be a page in a file
> > penalized and written later only because there are lots of other dirty
> > pages in the file? It is enough to make sure that we don't write one file
> > indefinitely when there are new dirty pages continuously created - and my
> > patch achieves that.
> 
> This is a big policy change. Imagine dirty files A=4GB, B=C=D=1MB.
> With current policy, it could be
> 
>         sync 4MB of A
>         sync B
>         sync C
>         sync D
>         sync 4MB of A
>         sync 4MB of A
>         ...
> 
> And you want to change to
> 
>         sync A (all 4GB)
>         sync B
>         sync C
>         sync D
> 
> This means the writeback of B,C,D won't be able to start at 30s, but
> delayed to 80s because of A. This is not entirely fair. IMHO writeback
> of big files shall not delay small files too much. 
  Yes, I'm aware of this change. It's just that I'm not sure we really
care. There are few reasons to this: What advantage does it bring that we
are "fair among files"? User can only tell the difference if after a crash,
files he wrote long time ago are still not on disk. But we shouldn't
accumulate too many dirty data (like minutes of writeback) in caches
anyway... So the difference should not be too big. Also how is the case
"one big and a few small files" different from the case "many small files"
where to be fair among files does not bring anything? 
  It's just that see some substantial code complexity and also performance
impact (because of smaller chunks of sequential IO) in trying to be fair
among files and I don't really see adequate advantages of that approach.
That's why I'm suggesting we should revisit the decision and possibly go in
a different direction.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
