Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A7DF6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:24:20 -0500 (EST)
Date: Tue, 10 Nov 2009 22:24:18 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 5/6] mm: stop ptlock enlarging struct page
In-Reply-To: <1257890959.4108.496.camel@laptop>
Message-ID: <Pine.LNX.4.64.0911102214550.6355@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
 <Pine.LNX.4.64.0911102200480.2816@sister.anvils> <1257890959.4108.496.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009, Peter Zijlstra wrote:
> On Tue, 2009-11-10 at 22:02 +0000, Hugh Dickins wrote:
> > 
> > Take the easy way out: switch off SPLIT_PTLOCK_CPUS when DEBUG_SPINLOCK
> > or DEBUG_LOCK_ALLOC is in force.  I've sometimes tried to be cleverer,
> > kmallocing a cacheline for the spinlock when it doesn't fit, but given
> > up each time.  Falling back to mm->page_table_lock (as we do when ptlock
> > is not split) lets lockdep check out the strictest path anyway.
> 
> Why? we know lockdep bloats stuff we never cared.. and hiding a popular
> CONFIG option from lockdep doesn't seem like a good idea to me.

That's a fair opinion, and indeed I Cc'ed you in case it were yours.

I'd like to see how other people feel about it.  Personally I detest
and regret that bloat to struct page, when there's only one particular
use of a page that remotely excuses it.

If it were less tiresome, I'd have gone for the dynamic kmalloc; but
it seemed silly to make that effort when the Kconfig mod is so easy.

But so far as letting lockdep do its job goes, we're actually better
off using page_table_lock there, as I tried to explain: since that
lock is used for a few other purposes, lockdep is more likely to
catch an issue which the SPLIT_PTLOCK case could be hiding.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
