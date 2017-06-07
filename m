Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2436B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 01:11:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s3so702617oia.4
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 22:11:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b36si320121ote.53.2017.06.06.22.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 22:11:29 -0700 (PDT)
Received: from mail-ua0-f173.google.com (mail-ua0-f173.google.com [209.85.217.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AD16323A02
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 05:11:28 +0000 (UTC)
Received: by mail-ua0-f173.google.com with SMTP id x47so1164966uab.0
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 22:11:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrV9Xnr7vUdd4Q1dfHL8_FN6WAiGeXLGe3aDxs83a39OUw@mail.gmail.com>
References: <cover.1496701658.git.luto@kernel.org> <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
 <1496776285.20270.64.camel@redhat.com> <CALCETrVX73+vHJMVYaddygEFj42oc3ShoUrXOm_s6CBwEP1peA@mail.gmail.com>
 <1496806405.29205.131.camel@redhat.com> <CALCETrV9Xnr7vUdd4Q1dfHL8_FN6WAiGeXLGe3aDxs83a39OUw@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 22:11:07 -0700
Message-ID: <CALCETrUkGkgQ2H8ZUxyT4XKtOReP6gReO4xWVGnUhcefGpPvWg@mail.gmail.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 6, 2017 at 9:54 PM, Andy Lutomirski <luto@kernel.org> wrote:
> Anyway, my point is that I think that, if this is really a problem, we
> should optimize mm_cpumask updating more generally instead of coming
> up with something that's specific to idle transitions.
>

I suspect the right data structure may be some kind of linked list,
not a bitmask at all.  The operations that should be fast are adding
yourself to the list, removing yourself from the list, and iterating
over all CPUs in the list.  Iterating over all CPUs in the list should
be reasonably fast, but the other two operations are more important.
We have the nice property that a given CPU is only on one such list at
a time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
