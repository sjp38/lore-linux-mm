Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9AEA86B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:44:42 -0400 (EDT)
Date: Wed, 26 Aug 2009 21:44:44 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
Message-ID: <20090826194444.GB14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random>
 <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random>
 <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
 <20090825194530.GU14722@random.random>
 <Pine.LNX.4.64.0908261910530.15622@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908261910530.15622@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 26, 2009 at 08:17:50PM +0100, Hugh Dickins wrote:
> Has anyone looked at why Rawhide's mlockall is not faulting in the
> pages, I wonder if there's a separate bug there?)

I reproduced only with self compiled mmotm kernel with full self
compiled userland with just a mlockall and exit (not rawhide
kernel/userland) so there's certainly no bug in rawhide, or at least
nothing special about it.

> No, not while it's down inside page allocation.

There's a slight difference if it's ksm inside page allocation and not
the task itself for other reasons. See the TIF_MEMDIE check in
page_alloc.c, those won't trigger when it's ksm causing a page
fault. So that's the problem left to tackle to make oom killer fully
happy with KSK unshare.

> But you don't like that approach at all, hmm.  It sounds like we'll
> have a fight if I try either that or to reintroduce the ksm_test_exits

;) Well I'd rather have a more unfixable issue if we have to
reintroduce the mm_users check the in page faults.

All is left to address is to teach page_alloc.c that the mm is going
away in a second patch. That might also help when it's aio triggering
gup page allocations or other kernel threads with use_mm just like ksm
and the oom killer selected those "mm" for release.

Having ksm using use_mm before triggering the handle_mm_fault (so
tsk->mm points to the mm of the task) and adding a MMF_MEMDIE to
mm->flags checked by page_alloc would work just fine and should solve
the double task killed... but then I'm unsure.. this is just the first
idea I had.

> in memory.c, once the munlock faulting is eliminated.  Well, I'll give
> it more thought: your patch is a lot better than the status quo,
> and should go in for now - thanks.

Ok, agreed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
