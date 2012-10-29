Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C152E6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 13:06:37 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so2282507wib.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 10:06:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029165705.GA4693@x1.osrc.amd.com>
References: <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com> <20121026144502.6e94643e@dull>
 <20121026221254.7d32c8bf@pyramind.ukuu.org.uk> <508BE459.2080406@redhat.com> <20121029165705.GA4693@x1.osrc.amd.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 29 Oct 2012 10:06:15 -0700
Message-ID: <CA+55aFzbwaHxWPkJ-t-TEh9hUwmA+D-unHGuJ7FPx7ULmrwKMg@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86,mm: drop TLB flush from ptep_set_access_flags
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, florian@openwrt.org, Borislav Petkov <borislav.petkov@amd.com>

On Mon, Oct 29, 2012 at 9:57 AM, Borislav Petkov <bp@alien8.de> wrote:
>
> On current AMD64 processors,

Can you verify that this is true for older cpu's too (ie the old
pre-64-bit ones, say K6 and original Athlon)?

>                 This is done because a table entry is allowed
> to be upgraded (by marking it as present

Well, that was traditionally solved by not caching not-present entries
at all. Which can be a problem for some things (prefetch of NULL etc),
so caching and then re-checking on faults is potentially the correct
thing, but I'm just mentioning it because it might not be much of an
argument for older microarchitectures..

>, or by removing its write,
> execute or supervisor restrictions) without explicitly maintaining TLB
> coherency. Such an upgrade will be found when the table is re-walked,
> which resolves the fault.

.. but this is obviously what we're interested in. And since AMD has
documented it (as well as Intel), I have this strong suspicion that
operating systems have traditionally relied on this behavior.

I don't remember the test coverage details from my Transmeta days, and
while I certainly saw the page table walker, it wasn't my code.

My gut feel is that this is likely something x86 just always does
(because it's the right thing to do to keep things simple for
software), but getting explicit confirmation about older AMD cpu's
would definitely be good.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
