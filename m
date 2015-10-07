Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2B80F6B0254
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 06:20:14 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so7027830lbc.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 03:20:13 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id mq10si24565706lbb.24.2015.10.07.03.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 03:20:12 -0700 (PDT)
Received: by lbwr8 with SMTP id r8so7017057lbw.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 03:20:12 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [linux-next:master 5871/6146] arch/sparc/include/asm/string_64.h:25:25: warning: 'start' may be used uninitialized in this function
References: <201510071617.hCOD5FXZ%fengguang.wu@intel.com>
Date: Wed, 07 Oct 2015 12:20:10 +0200
In-Reply-To: <201510071617.hCOD5FXZ%fengguang.wu@intel.com> (kbuild test
	robot's message of "Wed, 7 Oct 2015 16:46:26 +0800")
Message-ID: <87twq3ugit.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>

On Wed, Oct 07 2015, kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   15e5b1b566ed0689093effb31f13fe29e4c9905a
> commit: 5196456ab776a5974d24994aea1b20afe0c8d020 [5871/6146] slab.h: sprinkle __assume_aligned attributes
> config: sparc64-defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 5196456ab776a5974d24994aea1b20afe0c8d020
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc64 
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of
> it now.

I'm pretty sure it is a false warning, but just for the record (and so
someone can prove me wrong), here's my analysis. Relevant code
(drivers/net/ethernet/broadcom/tg3.c):

  12030         if ((b_offset = (offset & 3))) {
  12031                 /* adjustments to start on required 4 byte boundary */
  12032                 ret = tg3_nvram_read_be32(tp, offset-b_offset, &start);
  12033                 if (ret)
  12034                         return ret;
  12035                 len += b_offset;
  12036                 offset &= ~3;
  12037                 if (len < 4)
  12038                         len = 4;
  12039         }


  12052         if (b_offset || odd_len) {
  12053                 buf = kmalloc(len, GFP_KERNEL);
  12054                 if (!buf)
  12055                         return -ENOMEM;
  12056                 if (b_offset)
  12057                         memcpy(buf, &start, 4);
  12058                 if (odd_len)
  12059                         memcpy(buf+len-4, &end, 4);
  12060                 memcpy(buf + b_offset, data, eeprom->len);
  12061         }

So first off, the real problematic line would be 12057. I'm guessing
that the now known alignment of buf made gcc replace the memcpy call
with effectively "*(__be32*)buf = start;", which then triggered the
warning. But the memcpy is guarded by b_offset != 0, and in that case we
know start is initialized by tg3_nvram_read_be32 (or that we'd taken the
early return).

Rasmus



> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings (new ones prefixed by >>):
>
>    In file included from arch/sparc/include/asm/string.h:4:0,
>                     from include/linux/string.h:17,
>                     from include/linux/dynamic_debug.h:111,
>                     from include/linux/printk.h:277,
>                     from include/linux/kernel.h:13,
>                     from include/linux/list.h:8,
>                     from include/linux/module.h:9,
>                     from drivers/net/ethernet/broadcom/tg3.c:19:
>    drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_set_eeprom':
>>> arch/sparc/include/asm/string_64.h:25:25: warning: 'start' may be used uninitialized in this function [-Wmaybe-uninitialized]
>     #define memcpy(t, f, n) __builtin_memcpy(t, f, n)
>                             ^
>    drivers/net/ethernet/broadcom/tg3.c:12021:9: note: 'start' was declared here
>      __be32 start, end;
>             ^
>
> vim +/start +25 arch/sparc/include/asm/string_64.h
>
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17   9  #ifndef __SPARC64_STRING_H__
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  10  #define __SPARC64_STRING_H__
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  11  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  12  /* Really, userland/ksyms should not see any of this stuff. */
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  13  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  14  #ifdef __KERNEL__
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  15  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  16  #include <asm/asi.h>
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  17  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  18  #ifndef EXPORT_SYMTAB_STROPS
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  19  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  20  /* First the mem*() things. */
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  21  #define __HAVE_ARCH_MEMMOVE
> f05a6865 arch/sparc/include/asm/string_64.h Sam Ravnborg    2014-05-16  22  void *memmove(void *, const void *, __kernel_size_t);
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  23  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  24  #define __HAVE_ARCH_MEMCPY
> 4d14a459 arch/sparc/include/asm/string_64.h David S. Miller 2009-12-10 @25  #define memcpy(t, f, n) __builtin_memcpy(t, f, n)
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  26  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  27  #define __HAVE_ARCH_MEMSET
> 4d14a459 arch/sparc/include/asm/string_64.h David S. Miller 2009-12-10  28  #define memset(s, c, count) __builtin_memset(s, c, count)
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  29  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  30  #define __HAVE_ARCH_MEMSCAN
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  31  
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  32  #undef memscan
> f5e706ad include/asm-sparc/string_64.h      Sam Ravnborg    2008-07-17  33  #define memscan(__arg0, __char, __arg2)					\
>
> :::::: The code at line 25 was first introduced by commit
> :::::: 4d14a459857bd151ecbd14bcd37b4628da00792b sparc: Stop trying to be so fancy and use __builtin_{memcpy,memset}()
>
> :::::: TO: David S. Miller <davem@davemloft.net>
> :::::: CC: David S. Miller <davem@davemloft.net>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
