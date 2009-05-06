Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 504B46B0062
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:17:25 -0400 (EDT)
Date: Wed, 6 May 2009 15:17:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
	registrations.
Message-ID: <20090506131735.GW16078@random.random>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com> <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A0181EA.3070600@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 08:26:18AM -0400, Rik van Riel wrote:
> The user can break up the underlying VMAs though.
>
> I am just wondering out loud if we really want two
> VMA-like objects in the kernel, the VMA itself and
> a separate KSM object, with different semantics.
>
> Maybe this is fine, but I do think it's a question
> that needs to be thought about.

If we want to keep KVM self contained we need a separate object. If we
want to merge part of KVM into the kernel VM core, then it can use the
vma and use madvise or better its own syscall (usually madvise doesn't
depend on admin starting kernel threads) or similar and the semantics
will change slightly. From a practical point of view I don't think
there's much difference and it can be done later if we change our
mind, given the low amount of apps that uses KVM (but for those few
apps like KVM, KSM can save tons of memory).

For example for the swapping of KSM pages we've been thinking of using
external rmap hooks to avoid the VM to know anything specific to KSM
pages but to still allow their unmapping and swap. Otherwise if there
are other modules like KVM that wants to extend the VM they'll also
have to add their own PG_ bitflags just for allow the swapping of
their own pages in the VM LRUs etc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
