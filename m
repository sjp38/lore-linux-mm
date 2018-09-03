Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA1C86B6835
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 09:56:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id a15-v6so590368qtj.15
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 06:56:50 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id v200-v6si8977144wmd.0.2018.09.03.06.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 06:56:49 -0700 (PDT)
Date: Mon, 3 Sep 2018 14:56:36 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180903135636.GL19965@ZenIV.linux.org.uk>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

On Mon, Sep 03, 2018 at 02:34:27PM +0200, Andrey Konovalov wrote:

> > Al, very annoyed by that kind of information-hiding crap...
> 
> This patch only adds __force to hide the reports I've looked at and
> decided that the code does the right thing. The cases where this is
> not the case are handled by the previous patches in the patchset. I'll
> this to the patch description as well. Is that OK?

I don't know about you, but personally I've run into "I've looked,
I'm sure it's OK here" -> (a year or so later) "why is it OK, again?
Oh, bugger..." quite a few times.  Some, but not all, hadn't been
OK all along, some used to be but got quietly broken by subsequent
changes by people who had no idea that some property of implementation
was critical for correctness in the place in question, some (even
more embarrassingly) were broken by a patch of my own.

It happens.  "Looked in there, decided that the warning was bogus and
quietly shut it up" has turned out to be a source of trouble down the
road a lot of times.  If you are forcibly removing a warning (not by
reorganizing the logics and annotations, that is - by force-cast, or
something similar to it), leave behind something more useful than
"On $DATE I've decided it was OK" (and even that - only accessible via
git blame/git show).  As a hint for yourself, if nothing else - you
might end up asking yourself the same question a year or two (or twenty,
for that matter) later while looking for likely source of odd breakage
and trying to narrow the search down.

Force-cast conflates a *lot* of situations together - it's pretty much
"fuck off, I know what's going on here, it's OK" and no more than that;
hell, even the warning it removes would've carried more information...

That kind of "these are false positives, let's turn them off to search for
real problems" patches is fine when developing a branch like that; it's
leaving them in for posterity that tends to cause PITA...

I'm not attacking you, BTW - it's really a generic point re force-casts.
There had been some really outrageous cases lately[1] and I think that
this point does need to be made.  Unexplained force-cast is worse than
leaving a warning in.

[1] with, if my reading of the situation is correct,
	newbie asking maintainers if dealing with endianness warnings in
a certain driver would be useful
	newbie getting told (perhaps by maintainers, perhaps by somebody else)
that those were all noise, the driver's correct and the most useful thing to
be done with them would be to make them STFU
	force-cast-laden patch from said newbie doing just that picked by said
maintainers, "cleaning up" the warnings.  And committed with authorship pinned
to the newbie ;-/
Not nice, seeing that the code in driver is *not* correct, despite the high-handed
"shut that noise off, everything's fine there" commit - undoing that "cleanup" and
trying to redo annotations properly starts to converge on absolutely real bugs on
b-e hosts in about 10 minutes.  In PCIe driver, with devices existing as separate
cards, not just something always embedded into x86 or arm motherboard...
