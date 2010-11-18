Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B011F6B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:01:34 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oAII0Ica019051
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:00:21 -0800
Received: from gyh3 (gyh3.prod.google.com [10.243.50.195])
	by kpbe11.cbf.corp.google.com with ESMTP id oAIHxCnL004121
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:00:17 -0800
Received: by gyh3 with SMTP id 3so2432429gyh.0
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:00:17 -0800 (PST)
Date: Thu, 18 Nov 2010 10:00:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
In-Reply-To: <20101118133904.GB18834@infradead.org>
Message-ID: <alpine.LSU.2.00.1011180941450.3210@tigran.mtv.corp.google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com> <1289996638-21439-4-git-send-email-walken@google.com> <20101117125756.GA5576@amd> <1290007734.2109.941.camel@laptop> <20101118054629.GA3339@amd> <2ADBEB7E-0EC8-4536-B556-0453A8E1D5FA@mit.edu>
 <20101118133904.GB18834@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Theodore Tso <tytso@mit.edu>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Christoph Hellwig wrote:
> On Thu, Nov 18, 2010 at 05:43:06AM -0500, Theodore Tso wrote:
> > Why is it at all important that mlock() force block allocation for sparse blocks?    It's  not at all specified in the mlock() API definition that it does that.
> > 
> > Are there really programs that assume that mlock() == fallocate()?!?
> 
> If there are programs that do they can't predate linux 2.6.15, and only
> work on btrfs/ext4/xfs/etc, but not ext2/ext3/reiserfs.  Seems rather
> unlikely to me.

Yes, almost.  I'm very much on this side, that mlocking should not dirty
all those pages; but better admit one argument for the opposition - it's
possible that we'd find a case somewhere, which has always (i.e. even pre-
page_mkwrite) relied upon mlock of an entirely sparse file to result in
a nicely ordered allocation of blocks to the file (as would often have
happened with pdflush, I think), to give good sequential read patterns
ever after; but with this patch would now get much more random block
ordering, according to where the real writes actually fall.

It would be possible for a filesystem's ->fault(vma, &vmf) to observe
that it's being called on a VM_LOCKED|VM_SHARED vma, and make sure that
the page has backing in that case, to reproduce the old allocation behaviour
without all the unnecessary writing.  But that would be extra work in every
filesystem that cares.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
