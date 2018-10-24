Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98EF66B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 14:49:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w15-v6so3620253pge.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 11:49:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z67-v6si5999313pfz.5.2018.10.24.11.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 11:49:31 -0700 (PDT)
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 41C9920831
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:49:30 +0000 (UTC)
Received: by mail-wr1-f49.google.com with SMTP id q7-v6so6701316wrr.8
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 11:49:30 -0700 (PDT)
MIME-Version: 1.0
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com> <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 24 Oct 2018 11:49:17 -0700
Message-ID: <CALCETrUsqCzU6VO0h4EFpsdXOOn-kJY7ogwKQiQScNY9YJ6hWA@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/ldt: Unmap PTEs for the slow before freeing LDT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 23, 2018 at 9:32 AM Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> modify_ldt(2) leaves old LDT mapped after we switch over to the new one.
> Memory for the old LDT gets freed and the pages can be re-used.
>
> Leaving the mapping in place can have security implications. The mapping
> is present in userspace copy of page tables and Meltdown-like attack can
> read these freed and possibly reused pages.

Code looks okay.  But:

> -       /*
> -        * Did we already have the top level entry allocated?  We can't
> -        * use pgd_none() for this because it doens't do anything on
> -        * 4-level page table kernels.
> -        */
> -       pgd = pgd_offset(mm, LDT_BASE_ADDR);

This looks like an unrelated cleanup.  Can it be its own patch?
