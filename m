Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75D0F6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 20:11:41 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h9so2433118uac.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:11:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a3sor890900uac.140.2018.04.18.17.11.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 17:11:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180406205518.E3D989EB@viggo.jf.intel.com>
References: <20180406205501.24A1A4E7@viggo.jf.intel.com> <20180406205518.E3D989EB@viggo.jf.intel.com>
From: Kees Cook <keescook@google.com>
Date: Wed, 18 Apr 2018 17:11:39 -0700
Message-ID: <CAGXu5jJS-PYS7ONy_neDQCqVGRwrtjg=VdktXALQnzRe1+RNuA@mail.gmail.com>
Subject: Re: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, namit@vmware.com

On Fri, Apr 6, 2018 at 1:55 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> +/*
> + * For some configurations, map all of kernel text into the user page
> + * tables.  This reduces TLB misses, especially on non-PCID systems.
> + */
> +void pti_clone_kernel_text(void)
> +{
> +       unsigned long start = PFN_ALIGN(_text);
> +       unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);

I think this is too much set global: _end is after data, bss, and brk,
and all kinds of other stuff that could hold secrets. I think this
should match what mark_rodata_ro() is doing and use
__end_rodata_hpage_align. (And on i386, this should be maybe _etext.)

-Kees

-- 
Kees Cook
Pixel Security
