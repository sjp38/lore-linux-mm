Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A70366B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 05:18:04 -0400 (EDT)
Date: Tue, 27 Oct 2009 10:17:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] [PATCH] Avoid livelock for fsync
Message-ID: <20091027091758.GA4285@duck.suse.cz>
References: <20091026181314.GE7233@duck.suse.cz> <20091027033947.GB11828@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027033947.GB11828@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, WU Fengguang <wfg@mail.ustc.edu.cn>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Tue 27-10-09 04:39:47, Nick Piggin wrote:
> On Mon, Oct 26, 2009 at 07:13:14PM +0100, Jan Kara wrote:
> >   on my way back from Kernel Summit, I've coded the attached patch which
> > implements livelock avoidance for write_cache_pages. We tag patches that
> > should be written in the beginning of write_cache_pages and then write
> > only tagged pages (see the patch for details). The patch is based on Nick's
> > idea.
> >   The next thing I've aimed at with this patch is a simplification of
> > current writeback code. Basically, with this patch I think we can just rip
> > out all the range_cyclic and nr_to_write (or other "fairness logic"). The
> > rationalle is following:
> >   What we want to achieve with fairness logic is that when a page is
> > dirtied, it gets written to disk within some reasonable time (like 30s or
> > so). We track dirty time on per-inode basis only because keeping it
> > per-page is simply too expensive. So in this setting fairness between
> > inodes really does not make any sence - why should be a page in a file
> > penalized and written later only because there are lots of other dirty
> > pages in the file? It is enough to make sure that we don't write one file
> > indefinitely when there are new dirty pages continuously created - and my
> > patch achieves that.
> >   So with my patch we can make write_cache_pages always write from
> > range_start (or 0) to range_end (or EOF) and write all tagged pages. Also
> > after changing balance_dirty_pages() so that a throttled process does not
> > directly submit the IO (Fengguang has the patches for this), we can
> > completely remove the nr_to_write logic because nothing really uses it
> > anymore. Thus also the requeue_io logic should go away etc...
> >   Fengguang, do you have the series somewhere publicly available? You had
> > there a plenty of changes and quite some of them are not needed when the
> > above is done. So could you maybe separate out the balance_dirty_pages
> > change and I'd base my patch and further simplifications on top of that?
> > Thanks.
> 
> Like I said (and as we concluded when I last posted my tagging patch),
> I think this idea should work fine, but there is perhaps a little bit of
> overhead/complexity so provided that we can get some numbers or show a
> real improvement in behaviour or code simplifications then I think we
> could justify the patch.
  Yes, after I rebase my patch on top of Fengguang's work, I'll write also
the cleanup patch so that we can really see, how much simpler the code gets
and can test what advantages / disadvantages does it bring. I'll keep you
updated.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
