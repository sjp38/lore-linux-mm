Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56B5B6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 16:03:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so24061706wml.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:03:12 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id z6si5318268wmg.146.2016.08.19.13.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 13:03:11 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id f65so47092069wmi.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:03:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyiAOSM=ubzfOtdMx6e6vAmDS4JYW4sUU-5sQKPPzWBdQ@mail.gmail.com>
References: <20160817222921.GA25148@www.outflux.net> <CA+55aFyiAOSM=ubzfOtdMx6e6vAmDS4JYW4sUU-5sQKPPzWBdQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 19 Aug 2016 13:03:09 -0700
Message-ID: <CAGXu5jJi4qMD5p38i5NuR7fh38m7mp+7qZNXgUiGNRTaLtYoxA@mail.gmail.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Fri, Aug 19, 2016 at 12:41 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Aug 17, 2016 at 3:29 PM, Kees Cook <keescook@chromium.org> wrote:
>> When an allocator does not mark all allocations as PageSlab, or does not
>> mark multipage allocations with __GFP_COMP, hardened usercopy cannot
>> correctly validate the allocation. SLOB lacks this, so short-circuit
>> the checking for the allocators that aren't marked with
>> CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. This also updates the config
>> help and corrects a typo in the usercopy comments.
>
> I think I'm going to instead do just this:
>
>   diff --git a/security/Kconfig b/security/Kconfig
>   index df28f2b6f3e1..da10d9b573a4 100644
>   --- a/security/Kconfig
>   +++ b/security/Kconfig
>   @@ -136,6 +136,7 @@ config HAVE_ARCH_HARDENED_USERCOPY
>    config HARDENED_USERCOPY
>           bool "Harden memory copies between kernel and userspace"
>           depends on HAVE_ARCH_HARDENED_USERCOPY
>   +       depends on HAVE_HARDENED_USERCOPY_ALLOCATOR
>           select BUG
>           help
>             This option checks for obviously wrong memory regions when
>
> which basically disables the hardened usercopy for SLOB systems.
> Nobody cares, because nobody should use SLOB anyway, and certainly
> wouldn't use it with hardening.

Okay, I can live with that. I'd hoped to keep the general split
between the other checks (i.e. stack) and the allocator, but if this
is preferred, that's cool. :)

> Let's see if we get any other warnings with that..

Another report came back on NFS root, but it didn't stop the system
from booting, and may be a legit memory exposure report. I'm still
investigating that.

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
