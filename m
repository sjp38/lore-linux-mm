Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE086B7049
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:19:21 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id u17so9538483pgn.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:19:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q14si15460592pgg.433.2018.12.04.11.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 11:19:19 -0800 (PST)
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 448CA21508
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:19:19 +0000 (UTC)
Received: by mail-wr1-f52.google.com with SMTP id q18so17157084wrx.9
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:19:19 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 4 Dec 2018 11:19:05 -0800
Message-ID: <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alison.schofield@intel.com, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Cc: David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Mon, Dec 3, 2018 at 11:37 PM Alison Schofield
<alison.schofield@intel.com> wrote:
>
> Hi Thomas, David,
>
> Here is an updated RFC on the API's to support MKTME.
> (Multi-Key Total Memory Encryption)
>
> This RFC presents the 2 API additions to support the creation and
> usage of memory encryption keys:
>  1) Kernel Key Service type "mktme"
>  2) System call encrypt_mprotect()
>
> This patchset is built upon Kirill Shutemov's work for the core MKTME
> support.
>
> David: Please let me know if the changes made, based on your review,
> are reasonable. I don't think that the new changes touch key service
> specific areas (much).
>
> Thomas: Please provide feedback on encrypt_mprotect(). If not a
> review, then a direction check would be helpful.
>

I'm not Thomas, but I think it's the wrong direction.  As it stands,
encrypt_mprotect() is an incomplete version of mprotect() (since it's
missing the protection key support), and it's also functionally just
MADV_DONTNEED.  In other words, the sole user-visible effect appears
to be that the existing pages are blown away.  The fact that it
changes the key in use doesn't seem terribly useful, since it's
anonymous memory, and the most secure choice is to use CPU-managed
keying, which appears to be the default anyway on TME systems.  It
also has totally unclear semantics WRT swap, and, off the top of my
head, it looks like it may have serious cache-coherency issues and
like swapping the pages might corrupt them, both because there are no
flushes and because the direct-map alias looks like it will use the
default key and therefore appear to contain the wrong data.

I would propose a very different direction: don't try to support MKTME
at all for anonymous memory, and instead figure out the important use
cases and support them directly.  The use cases that I can think of
off the top of my head are:

1. pmem.  This should probably use a very different API.

2. Some kind of VM hardening, where a VM's memory can be protected a
little tiny bit from the main kernel.  But I don't see why this is any
better than XPO (eXclusive Page-frame Ownership), which brings to
mind:

The main implementation concern I have with this patch set is cache
coherency and handling of the direct map.  Unless I missed something,
you're not doing anything about the direct map, which means that you
have RW aliases of the same memory with different keys.  For use case
#2, this probably means that you need to either get rid of the direct
map and make get_user_pages() fail, or you need to change the key on
the direct map as well, probably using the pageattr.c code.

As for caching, As far as I can tell from reading the preliminary
docs, Intel's MKTME, much like AMD's SME, is basically invisible to
the hardware cache coherency mechanism.  So, if you modify a physical
address with one key (or SME-enable bit), and you read it with
another, you get garbage unless you flush.  And, if you modify memory
with one key then remap it with a different key without flushing in
the mean time, you risk corruption.  And, what's worse, if I'm reading
between the lines in the docs correctly, if you use PCONFIG to change
a key, you may need to do a bunch of cache flushing to ensure you get
reasonable effects.  (If you have dirty cache lines for some (PA, key)
and you PCONFIG to change the underlying key, you get different
results depending on whether the writeback happens before or after the
package doing the writeback notices the PCONFIG.)

Finally, If you're going to teach the kernel how to have some user
pages that aren't in the direct map, you've essentially done XPO,
which is nifty but expensive.  And I think that doing this gets you
essentially all the benefit of MKTME for the non-pmem use case.  Why
exactly would any software want to use anything other than a
CPU-managed key for anything other than pmem?

--Andy
