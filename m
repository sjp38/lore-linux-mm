Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9706B7070
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:00:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so9639669pgr.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:00:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q10si16808154pll.221.2018.12.04.12.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:00:55 -0800 (PST)
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ADB4E214F1
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:00:54 +0000 (UTC)
Received: by mail-wm1-f53.google.com with SMTP id q26so10566512wmf.5
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:00:54 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com> <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
In-Reply-To: <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 4 Dec 2018 12:00:41 -0800
Message-ID: <CALCETrXM_nQMFHsAfQGqqURL3=B46AXdiG+4p8Mpm6n4cOqXsw@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@kernel.org>
Cc: alison.schofield@intel.com, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Dec 4, 2018 at 11:19 AM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Mon, Dec 3, 2018 at 11:37 PM Alison Schofield
> <alison.schofield@intel.com> wrote:
> >

> Finally, If you're going to teach the kernel how to have some user
> pages that aren't in the direct map, you've essentially done XPO,
> which is nifty but expensive.  And I think that doing this gets you
> essentially all the benefit of MKTME for the non-pmem use case.  Why
> exactly would any software want to use anything other than a
> CPU-managed key for anything other than pmem?
>

Let me say this less abstractly.  Here's a somewhat concrete actual
proposal.  Make a new memfd_create() flag like MEMFD_ISOLATED.  The
semantics are that the underlying pages are made not-present in the
direct map when they're allocated (which is hideously slow, but so be
it), and that anything that tries to get_user_pages() the resulting
pages fails.  And then make sure we have all the required APIs so that
QEMU can still map this stuff into a VM.

If there is indeed a situation in which MKTME-ifying the memory adds
some value, then we can consider doing that.

And maybe we get fancy and encrypt this memory when it's swapped, but
maybe we should just encrypt everything when it's swapped.
