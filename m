Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 194366B000C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 16:55:40 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 88-v6so6360303wrp.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 13:55:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3-v6sor8184628wrn.5.2018.10.11.13.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 13:55:38 -0700 (PDT)
MIME-Version: 1.0
References: <20181011151523.27101-1-yu-cheng.yu@intel.com> <20181011151523.27101-8-yu-cheng.yu@intel.com>
 <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
In-Reply-To: <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 11 Oct 2018 13:55:26 -0700
Message-ID: <CALCETrUJ1t_K=FQExa_K0yg+aXkPot6wn6RHBPDc3BsAxtmMBw@mail.gmail.com>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, Daniel Micay <danielmicay@gmail.com>

On Thu, Oct 11, 2018 at 1:39 PM Jann Horn <jannh@google.com> wrote:
>
> On Thu, Oct 11, 2018 at 5:20 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > Create a guard area between VMAs to detect memory corruption.
> [...]
> > +config VM_AREA_GUARD
> > +       bool "VM area guard"
> > +       default n
> > +       help
> > +         Create a guard area between VM areas so that access beyond
> > +         limit can be detected.
> > +
> >  endmenu
>
> Sorry to bring this up so late, but Daniel Micay pointed out to me
> that, given that VMA guards will raise the number of VMAs by
> inhibiting vma_merge(), people are more likely to run into
> /proc/sys/vm/max_map_count (which limits the number of VMAs to ~65k by
> default, and can't easily be raised without risking an overflow of
> page->_mapcount on systems with over ~800GiB of RAM, see
> https://lore.kernel.org/lkml/20180208021112.GB14918@bombadil.infradead.org/
> and replies) with this change.
>
> Playing with glibc's memory allocator, it looks like glibc will use
> mmap() for 128KB allocations; so at 65530*128KB=8GB of memory usage in
> 128KB chunks, an application could run out of VMAs.

Ugh.

Do we have a free VM flag so we could do VM_GUARD to force a guard
page?  (And to make sure that, when a new VMA is allocated, it won't
be directly adjacent to a VM_GUARD VMA.)
