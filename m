Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 520CC6B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 16:16:05 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id ks9so1247497vcb.41
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:16:04 -0700 (PDT)
Received: from mail-ve0-x234.google.com (mail-ve0-x234.google.com [2607:f8b0:400c:c01::234])
        by mx.google.com with ESMTPS id sq9si4090589vdc.53.2014.03.25.13.16.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 13:16:03 -0700 (PDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so1215121veb.11
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:16:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
	<1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
	<533016CB.4090807@citrix.com>
	<CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
Date: Tue, 25 Mar 2014 13:16:02 -0700
Message-ID: <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, Mar 24, 2014 at 8:31 AM, Steven Noonan <steven@uplinklabs.net> wrote:
> Vrabel's comments make me think that revisiting the elimination of the
> _PAGE_NUMA bit implementation would be a good idea... should I CC you
> on this discussion (not sure if you're subscribed to xen-devel, or if
> LKML is a better place for that discussion)?

I detest the PAGE_NUMA games myself, but:

From: David Vrabel <david.vrabel@citrix.com>:
>
> I really do not understand how you're supposed to distinguish between a
> PTE for a PROT_NONE page and one with _PAGE_NUMA -- they're identical.
> i.e., pte_numa() will return true for a PROT_NONE protected page which
> just seems wrong to me.

The way to distinguish PAGE_NUMA from PROTNONE is *supposed* to be by
looking at the vma, and PROTNONE goes together with a vma with
PROT_NONE. That's what the comments in pgtable_types.h say.

However, as far as I can tell, that is pure and utter bullshit.  It's
true that generally handle_mm_fault() shouldn't be called for
PROT_NONE pages, since it will fail the protection checks. However, we
have FOLL_FORCE that overrides those protection checks for things like
ptrace etc. So people have tried to convince me that _PAGE_NUMA works,
but I'm really not at all sure they are right.

I fundamentally think that it was a horrible horrible disaster to make
_PAGE_NUMA alias onto _PAGE_PROTNONE.

But I'm cc'ing the people who tried to convince me otherwise last time
around, to see if they can articulate this mess better now.

The argument *seems* to be that if things are truly PROT_NONE, then
the page will never be touched by page faulting code (and as
mentioned, I think that argument is fundamentally broken), and if it's
PROT_NUMA then the page faulting code will magically do the right
thing.

FURTHERMORE, the argument was that we can't just call things PROT_NONE
and just say that "those are the semantics", because on other
architectures PROT_NONE might mean/do something else.  Which really
makes no sense either, because if the argument was that PROT_NONE
causes faults that can either be handled as faults (for PROT_NONE) or
as NUMA issues (for NUMA), then dammit, that argument should be
completely architecture-independent.

But I gave up arguing with people. I will state (again) that I think
this is a f*cking mess, and saying that PROTNONE and NUMA are somehow
the exact same thing on x86 but not in general is bogus crap. And
saying that you can determine which it is from the vma is very
debatable too.

Let the people responsible for the crap try to explain why it works
and has to be that mess. Again. Rik, Mel?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
