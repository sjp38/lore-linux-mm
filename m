Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C5B496B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:29:43 -0400 (EDT)
Date: Wed, 26 Aug 2009 21:29:07 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090826194444.GB14722@random.random>
Message-ID: <Pine.LNX.4.64.0908262118470.4364@sister.anvils>
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
> On Wed, Aug 26, 2009 at 08:17:50PM +0100, Hugh Dickins wrote:
> > Has anyone looked at why Rawhide's mlockall is not faulting in the
> > pages, I wonder if there's a separate bug there?)
> 
> I reproduced only with self compiled mmotm kernel with full self
> compiled userland with just a mlockall and exit (not rawhide
> kernel/userland) so there's certainly no bug in rawhide, or at least
> nothing special about it.

I just tried again and got it myself: the faulting page is a PROT_NONE
page of libc, yes, that figures: mlocking would not fault it in, but
munlocking would (in its current implementation) insist on faulting it.

I don't know what my difficulty was yesterday: perhaps that page
isn't always PROT_NONE, perhaps I got confused and was testing the
wrong kernel, one without KSM or one with my follow_page munlock.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
