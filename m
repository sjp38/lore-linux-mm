Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09B4E6B0007
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:28:17 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so6395582plr.14
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 04:28:17 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h3-v6si3830830plb.527.2018.02.12.04.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Feb 2018 04:28:16 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] headers: untangle kmemleak.h from mm.h
In-Reply-To: <a4629db7-194d-3c7c-c8fd-24f61b220a70@infradead.org>
References: <a4629db7-194d-3c7c-c8fd-24f61b220a70@infradead.org>
Date: Mon, 12 Feb 2018 23:28:09 +1100
Message-ID: <87zi4ev1d2.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-s390 <linux-s390@vger.kernel.org>, John Johansen <john.johansen@canonical.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, X86 ML <x86@kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, virtualization@lists.linux-foundation.org, iommu@lists.linux-foundation.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Randy Dunlap <rdunlap@infradead.org> writes:

> From: Randy Dunlap <rdunlap@infradead.org>
>
> Currently <linux/slab.h> #includes <linux/kmemleak.h> for no obvious
> reason. It looks like it's only a convenience, so remove kmemleak.h
> from slab.h and add <linux/kmemleak.h> to any users of kmemleak_*
> that don't already #include it.
> Also remove <linux/kmemleak.h> from source files that do not use it.
>
> This is tested on i386 allmodconfig and x86_64 allmodconfig. It
> would be good to run it through the 0day bot for other $ARCHes.
> I have neither the horsepower nor the storage space for the other
> $ARCHes.
>
> [slab.h is the second most used header file after module.h; kernel.h
> is right there with slab.h. There could be some minor error in the
> counting due to some #includes having comments after them and I
> didn't combine all of those.]
>
> This is Lingchi patch #1 (death by a thousand cuts, applied to kernel
> header files).
>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

I threw it at a random selection of configs and so far the only failures
I'm seeing are:

  lib/test_firmware.c:134:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]                                                                                                          
  lib/test_firmware.c:620:25: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
  lib/test_firmware.c:620:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
  security/integrity/digsig.c:146:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]

Full results trickling in here, not all the failures there are caused by
this patch, ie. some configs are broken in mainline:

  http://kisskb.ellerman.id.au/kisskb/head/13396/

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
