Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD6E6B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:00:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so53349256pfg.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 09:00:03 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id d28si45834850pfb.283.2016.08.30.09.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 09:00:01 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id h186so1364072pfg.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 09:00:01 -0700 (PDT)
Date: Wed, 31 Aug 2016 00:59:19 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
Message-ID: <20160830155919.GA482@swordfish>
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On (08/29/16 14:31), Aaron Lu wrote:
> 
> The global zero page is used to satisfy an anonymous read fault. If
> THP(Transparent HugePage) is enabled then the global huge zero page is used.
> The global huge zero page uses an atomic counter for reference counting
> and is allocated/freed dynamically according to its counter value.
> 

Hello,

for !CONFIG_TRANSPARENT_HUGEPAGE configs mm_put_huge_zero_page() is BUILD_BUG(),
which gives the following build error (mmots v4.8-rc4-mmots-2016-08-29-16-56)


  CC      kernel/fork.o
In file included from ./include/asm-generic/bug.h:4:0,
                 from ./arch/x86/include/asm/bug.h:35,
                 from ./include/linux/bug.h:4,
                 from ./include/linux/mmdebug.h:4,
                 from ./include/linux/gfp.h:4,
                 from ./include/linux/slab.h:14,
                 from kernel/fork.c:14:
In function a??mm_put_huge_zero_pagea??,
    inlined from a??__mmputa?? at kernel/fork.c:777:2,
    inlined from a??mmput_async_fna?? at kernel/fork.c:806:2:
./include/linux/compiler.h:495:38: error: call to a??__compiletime_assert_218a?? declared with attribute error: BUILD_BUG failed
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                      ^
./include/linux/compiler.h:478:4: note: in definition of macro a??__compiletime_asserta??
    prefix ## suffix();    \
    ^~~~~~
./include/linux/compiler.h:495:2: note: in expansion of macro a??_compiletime_asserta??
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/bug.h:51:37: note: in expansion of macro a??compiletime_asserta??
 #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                     ^~~~~~~~~~~~~~~~~~
./include/linux/bug.h:85:21: note: in expansion of macro a??BUILD_BUG_ON_MSGa??
 #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
                     ^~~~~~~~~~~~~~~~
./include/linux/huge_mm.h:218:2: note: in expansion of macro a??BUILD_BUGa??
  BUILD_BUG();
  ^~~~~~~~~
In function a??mm_put_huge_zero_pagea??,
    inlined from a??__mmputa?? at kernel/fork.c:777:2,
    inlined from a??mmputa?? at kernel/fork.c:798:3:
./include/linux/compiler.h:495:38: error: call to a??__compiletime_assert_218a?? declared with attribute error: BUILD_BUG failed
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                      ^
./include/linux/compiler.h:478:4: note: in definition of macro a??__compiletime_asserta??
    prefix ## suffix();    \
    ^~~~~~
./include/linux/compiler.h:495:2: note: in expansion of macro a??_compiletime_asserta??
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/bug.h:51:37: note: in expansion of macro a??compiletime_asserta??
 #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                     ^~~~~~~~~~~~~~~~~~
./include/linux/bug.h:85:21: note: in expansion of macro a??BUILD_BUG_ON_MSGa??
 #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
                     ^~~~~~~~~~~~~~~~
./include/linux/huge_mm.h:218:2: note: in expansion of macro a??BUILD_BUGa??
  BUILD_BUG();
  ^~~~~~~~~
make[1]: *** [scripts/Makefile.build:291: kernel/fork.o] Error 1
make: *** [Makefile:968: kernel] Error 2


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
