Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4625F6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 13:05:35 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h6so4356849qtm.15
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 10:05:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q126sor413197qka.74.2018.02.08.10.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 10:05:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
References: <20180208021112.GB14918@bombadil.infradead.org> <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 8 Feb 2018 13:05:33 -0500
Message-ID: <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

>> That seems pretty bad.  So here's a patch which adds documentation to the
>> two sysctls that a sysadmin could use to shoot themselves in the foot,
>> and adds a warning if they change either of them to a dangerous value.
>
> I have negative feelings about this patch, mostly because AFAICS:
>
>  - It documents an issue instead of fixing it.
>  - It likely only addresses a small part of the actual problem.

The standard map_max_count / pid_max are very low and there are many
situations where either or both need to be raised.

VM fragmentation in long-lived processes is a major issue. There are
allocators like jemalloc designed to minimize VM fragmentation by
never unmapping memory but they're relying on not having anything else
using mmap regularly so they can have all their ranges merged
together, unless they decide to do something like making a 1TB
PROT_NONE mapping up front to slowly consume. If you Google this
sysctl name, you'll find lots of people running into the limit. If
you're using a debugging / hardened allocator designed to use a lot of
guard pages, the standard map_max_count is close to unusable...

I think the same thing applies to pid_max. There are too many
reasonable reasons to increase it. Process-per-request is quite
reasonable if you care about robustness / security and want to sandbox
each request handler. Look at Chrome / Chromium: it's currently
process-per-site-instance, but they're moving to having more processes
with site isolation to isolate iframes into their own processes to
work towards enforcing the boundaries between sites at a process
level. It's way worse for fine-grained server-side sandboxing. Using a
lot of processes like this does counter VM fragmentation especially if
long-lived processes doing a lot of work are mostly avoided... but if
your allocators like using guard pages you're still going to hit the
limit.

I do think the default value in the documentation should be fixed but
if there's a clear problem with raising these it really needs to be
fixed. Google either of the sysctl names and look at all the people
running into issues and needing to raise them. It's only going to
become more common to raise these with people trying to use lots of
fine-grained sandboxing. Process-per-request is back in style.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
