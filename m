Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6E0076B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:57:53 -0400 (EDT)
Date: Wed, 26 Aug 2009 20:57:27 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090826194444.GB14722@random.random>
Message-ID: <Pine.LNX.4.64.0908262048270.21188@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils> <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random> <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random> <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
 <20090825194530.GU14722@random.random> <Pine.LNX.4.64.0908261910530.15622@sister.anvils>
 <20090826194444.GB14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Andrea Arcangeli wrote:
> 
> All is left to address is to teach page_alloc.c that the mm is going
> away in a second patch. That might also help when it's aio triggering
> gup page allocations or other kernel threads with use_mm just like ksm
> and the oom killer selected those "mm" for release.
> 
> Having ksm using use_mm before triggering the handle_mm_fault (so
> tsk->mm points to the mm of the task) and adding a MMF_MEMDIE to
> mm->flags checked by page_alloc would work just fine and should solve
> the double task killed... but then I'm unsure.. this is just the first
> idea I had.

Yes, I began to have thoughts along those lines too as I was writing
my reply.  It is a different angle on the problem, I hadn't looked at
it that way before, and it does seem worth pursuing.  MMF_MEMDIE, yes,
that might be useful.  But KSM_RUN_UNMERGE wouldn't be able to use_mm
since it's coming from a normal user process - perhaps it should be a
kill-me-first like swapoff via PF_SWAPOFF.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
