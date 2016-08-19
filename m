Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27B0C6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 15:41:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f14so151807417ioj.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:41:41 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id 97si4996418ota.48.2016.08.19.12.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 12:41:40 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id t127so6914993oie.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:41:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160817222921.GA25148@www.outflux.net>
References: <20160817222921.GA25148@www.outflux.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Aug 2016 12:41:39 -0700
Message-ID: <CA+55aFyiAOSM=ubzfOtdMx6e6vAmDS4JYW4sUU-5sQKPPzWBdQ@mail.gmail.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Wed, Aug 17, 2016 at 3:29 PM, Kees Cook <keescook@chromium.org> wrote:
> When an allocator does not mark all allocations as PageSlab, or does not
> mark multipage allocations with __GFP_COMP, hardened usercopy cannot
> correctly validate the allocation. SLOB lacks this, so short-circuit
> the checking for the allocators that aren't marked with
> CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. This also updates the config
> help and corrects a typo in the usercopy comments.

I think I'm going to instead do just this:

  diff --git a/security/Kconfig b/security/Kconfig
  index df28f2b6f3e1..da10d9b573a4 100644
  --- a/security/Kconfig
  +++ b/security/Kconfig
  @@ -136,6 +136,7 @@ config HAVE_ARCH_HARDENED_USERCOPY
   config HARDENED_USERCOPY
          bool "Harden memory copies between kernel and userspace"
          depends on HAVE_ARCH_HARDENED_USERCOPY
  +       depends on HAVE_HARDENED_USERCOPY_ALLOCATOR
          select BUG
          help
            This option checks for obviously wrong memory regions when

which basically disables the hardened usercopy for SLOB systems.
Nobody cares, because nobody should use SLOB anyway, and certainly
wouldn't use it with hardening.

Let's see if we get any other warnings with that..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
