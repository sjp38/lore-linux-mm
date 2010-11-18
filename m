Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E32E36B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 00:46:35 -0500 (EST)
Date: Thu, 18 Nov 2010 16:46:29 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101118054629.GA3339@amd>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290007734.2109.941.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 04:28:54PM +0100, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 23:57 +1100, Nick Piggin wrote:
> > On Wed, Nov 17, 2010 at 04:23:58AM -0800, Michel Lespinasse wrote:
> > > When faulting in pages for mlock(), we want to break COW for anonymous
> > > or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
> > > no need to write-fault into VM_SHARED vmas since shared file pages can
> > > be mlocked first and dirtied later, when/if they actually get written to.
> > > Skipping the write fault is desirable, as we don't want to unnecessarily
> > > cause these pages to be dirtied and queued for writeback.
> > 
> > It's not just to break COW, but to do block allocation and such
> > (filesystem's page_mkwrite op). That needs to at least be explained
> > in the changelog.
> 
> Agreed, the 0/3 description actually does mention this.

Oh, missed that, but yes the changelog needs to.

 
> > Filesystem doesn't have a good way to fully pin required things
> > according to mlock, but page_mkwrite provides some reasonable things
> > (like block allocation / reservation).
> 
> Right, but marking all pages dirty isn't really sane. I can imagine
> making the reservation but not marking things dirty solution, although
> it might be lots harder to implement, esp since some filesystems don't
> actually have a page_mkwrite() implementation.

I think it is sane enough. Going back to previous behaviour would be
a regression, wouldn't it?

The right way to fix this would not be to introduce the new regression
but either/both: a specific syscall to mlock-for-read which does not do
any reservations, fix filesystem hook to allow reservation without
implying dirtying. A simple flag to page_mkwrite will be enough (plus
the logic to call it from VM).

If an app has called mlock, presumably it doesn't want to SIGBUS from
out of space, if it can possibly help it. If it isn't going to write
to it, then PROT_READ would be appropriate.

If not, then a note to man page maintainer, and an idea of performance
improvement in an actual use case would be nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
