Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C54966B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 00:48:19 -0400 (EDT)
Date: Tue, 19 May 2009 12:48:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090519044832.GA8769@localhost>
References: <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com> <20090519134253.4ECF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090519134253.4ECF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 19, 2009 at 12:44:19PM +0800, KOSAKI Motohiro wrote:
> > > begin:       2479             2344             9659              210                0           579643
> > > end:          284           232010           234142              260           772776         20917184
> > > restore:      379           232159           234371              301           774888         20967849
> > > 
> > > The numbers show that
> > > 
> > > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> > >   I'd attribute that improvement to the mmap readahead improvements :-)
> > > 
> > > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> > >   That's a huge improvement - which means with the VM_EXEC protection logic,
> > >   active mmap pages is pretty safe even under partially cache hot streaming IO.
> > > 
> > > - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
> > >   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
> > >   That roughly means the active mmap pages get 20.8 more chances to get
> > >   re-referenced to stay in memory.
> > > 
> > > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> > >   dropped pages are mostly inactive ones. The patch has almost no impact in
> > >   this aspect, that means it won't unnecessarily increase memory pressure.
> > >   (In contrast, your 20% mmap protection ratio will keep them all, and
> > >   therefore eliminate the extra 41 major faults to restore working set
> > >   of zsh etc.)
> > 
> > I'm surprised this.
> > Why your patch don't protect mapped page from streaming io?
> 
> I guess you use initlevel=5 and use only terminal, right?
> if so, dropping some graphics component makes sense.

No, it's in pure console mode, no X running at all.

> 
> > 
> > I strongly hope reproduce myself, please teach me reproduce way.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
