Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20A316B026B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:07:38 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w204-v6so36835096oib.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:07:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6-v6sor8521466oia.15.2018.07.11.14.07.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 14:07:36 -0700 (PDT)
MIME-Version: 1.0
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-23-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-23-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Jul 2018 14:07:09 -0700
Message-ID: <CAG48ez0h5cabNiSBkCnAoyg9LXoSd7PpuStbRpV5r67VMHocRA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Add user-mode indirect branch tracking enabling/disabling
> and supporting routines.
>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> index 4eba7790c4e4..8bbd63e1a2ba 100644
> --- a/arch/x86/kernel/cet.c
> +++ b/arch/x86/kernel/cet.c
[...]
> +static unsigned long ibt_mmap(unsigned long addr, unsigned long len)
> +{
> +       struct mm_struct *mm = current->mm;
> +       unsigned long populate;
> +
> +       down_write(&mm->mmap_sem);
> +       addr = do_mmap(NULL, addr, len, PROT_READ | PROT_WRITE,
> +                      MAP_ANONYMOUS | MAP_PRIVATE,
> +                      VM_DONTDUMP, 0, &populate, NULL);
> +       up_write(&mm->mmap_sem);
> +
> +       if (populate)
> +               mm_populate(addr, populate);
> +
> +       return addr;
> +}

Is this thing going to stay writable? Will any process with an IBT
bitmap be able to disable protections by messing with the bitmap even
if the lock-out mode is active? If so, would it perhaps make sense to
forbid lock-out mode if an IBT bitmap is active, to make it clear that
effective lock-out is impossible in that state?
