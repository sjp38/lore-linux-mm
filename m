Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9C86B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 11:32:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g131so6490138oic.10
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 08:32:24 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id f4si3003528oib.427.2017.08.09.08.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 08:32:23 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id q70so5997629oic.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 08:32:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201708092333.gJ53XSff%fengguang.wu@intel.com>
References: <201708092333.gJ53XSff%fengguang.wu@intel.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 9 Aug 2017 17:32:21 +0200
Message-ID: <CAK8P3a3yweXF_rXgs7ymTfeiO=bRU3gOX=zGhQcMdz4nV7sk_A@mail.gmail.com>
Subject: Re: drivers/tty/serial/8250/8250_fintek.c:364: warning: 'probe_data'
 is used uninitialized in this function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Daniel Micay <danielmicay@gmail.com>, kbuild-all@01.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 9, 2017 at 5:07 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   bfa738cf3dfae2111626650f86135f93c5ff0a22
> commit: 6974f0c4555e285ab217cee58b6e874f776ff409 include/linux/string.h: add the option of fortified string.h functions
> date:   4 weeks ago
> config: x86_64-randconfig-v0-08092220 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         git checkout 6974f0c4555e285ab217cee58b6e874f776ff409
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>    In file included from include/linux/bitmap.h:8,
>                     from include/linux/cpumask.h:11,
>                     from arch/x86/include/asm/cpumask.h:4,
>                     from arch/x86/include/asm/msr.h:10,
>                     from arch/x86/include/asm/processor.h:20,
>                     from arch/x86/include/asm/cpufeature.h:4,
>                     from arch/x86/include/asm/thread_info.h:52,
>                     from include/linux/thread_info.h:37,
>                     from arch/x86/include/asm/preempt.h:6,
>                     from include/linux/preempt.h:80,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/seqlock.h:35,
>                     from include/linux/time.h:5,
>                     from include/linux/stat.h:18,
>                     from include/linux/module.h:10,
>                     from drivers/tty/serial/8250/8250_fintek.c:11:
>    include/linux/string.h: In function 'strcpy':
>    include/linux/string.h:209: warning: '______f' is static but declared in inline function 'strcpy' which is not static
>    include/linux/string.h:211: warning: '______f' is static but declared in inline function 'strcpy' which is not static


This clearly comes from __trace_if() when CONFIG_PROFILE_ALL_BRANCHES
is enabled. I did not see the warning with gcc-7.1.1, and I guess this only
happens on older compilers like the gcc-4.4 that was used here.

What is the reason for __FORTIFY_INLINE to be "extern __always_inline"
rather than "static __always_inline"? If they cannot just be 'static', maybe
this can be changed to depend on the compiler version.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
