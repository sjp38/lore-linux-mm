Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD386B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 16:39:52 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b202-v6so6780208oii.23
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 13:39:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g144-v6sor14100808oib.48.2018.10.11.13.39.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 13:39:50 -0700 (PDT)
MIME-Version: 1.0
References: <20181011151523.27101-1-yu-cheng.yu@intel.com> <20181011151523.27101-8-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151523.27101-8-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 11 Oct 2018 22:39:24 +0200
Message-ID: <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com, Andy Lutomirski <luto@amacapital.net>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, rdunlap@infradead.org, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com, Daniel Micay <danielmicay@gmail.com>

On Thu, Oct 11, 2018 at 5:20 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> Create a guard area between VMAs to detect memory corruption.
[...]
> +config VM_AREA_GUARD
> +       bool "VM area guard"
> +       default n
> +       help
> +         Create a guard area between VM areas so that access beyond
> +         limit can be detected.
> +
>  endmenu

Sorry to bring this up so late, but Daniel Micay pointed out to me
that, given that VMA guards will raise the number of VMAs by
inhibiting vma_merge(), people are more likely to run into
/proc/sys/vm/max_map_count (which limits the number of VMAs to ~65k by
default, and can't easily be raised without risking an overflow of
page->_mapcount on systems with over ~800GiB of RAM, see
https://lore.kernel.org/lkml/20180208021112.GB14918@bombadil.infradead.org/
and replies) with this change.

Playing with glibc's memory allocator, it looks like glibc will use
mmap() for 128KB allocations; so at 65530*128KB=8GB of memory usage in
128KB chunks, an application could run out of VMAs.

People already run into that limit sometimes when mapping files, and
recommend raising it:

https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
http://docs.actian.com/vector/4.2/User/Increase_max_map_count_Kernel_Parameter_(Linux).htm
https://www.suse.com/de-de/support/kb/doc/?id=7000830 (they actually
ran into ENOMEM on **munmap**, because you can't split VMAs once the
limit is reached): "A custom application was failing on a SLES server
with ENOMEM errors when attempting to release memory using an munmap
call. This resulted in memory failing to be released, and the system
load and swap use increasing until the SLES machine ultimately crashed
or hung."
https://access.redhat.com/solutions/99913
https://forum.manjaro.org/t/resolved-how-to-set-vm-max-map-count-during-boot/43360

Arguably the proper solution to this would be to raise the default
max_map_count to be much higher; but then that requires fixing the
mapcount overflow.
