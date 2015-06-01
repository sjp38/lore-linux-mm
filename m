Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1060B6B0080
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 19:28:01 -0400 (EDT)
Received: by qcmi9 with SMTP id i9so53840391qcm.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 16:28:00 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id f185si14203356qhc.71.2015.06.01.16.27.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 16:27:59 -0700 (PDT)
Date: Mon, 1 Jun 2015 16:27:55 -0700
From: josh@joshtriplett.org
Subject: Re: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <20150601232755.GA30913@cloud>
References: <201506020621.UtqnXSMY%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506020621.UtqnXSMY%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Jun 02, 2015 at 06:08:25AM +0800, kbuild test robot wrote:
> All error/warnings:
> 
>    In file included from include/linux/page-flags.h:9:0,
>                     from kernel/bounds.c:9:
> >> include/linux/bug.h:91:47: warning: 'struct bug_entry' declared inside parameter list
>     static inline int is_warning_bug(const struct bug_entry *bug)
>                                                   ^
> >> include/linux/bug.h:91:47: warning: its scope is only this definition or declaration, which is probably not what you want
>    include/linux/bug.h: In function 'is_warning_bug':
> >> include/linux/bug.h:93:12: error: dereferencing pointer to incomplete type
>      return bug->flags & BUGFLAG_WARNING;
>                ^
>    make[2]: *** [kernel/bounds.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
> 
> vim +93 include/linux/bug.h
> 
> 35edd910 Paul Gortmaker      2011-11-16  85  
> 35edd910 Paul Gortmaker      2011-11-16  86  #endif	/* __CHECKER__ */
> 35edd910 Paul Gortmaker      2011-11-16  87  
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  88  #ifdef CONFIG_GENERIC_BUG
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  89  #include <asm-generic/bug.h>
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  90  
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08 @91  static inline int is_warning_bug(const struct bug_entry *bug)
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  92  {
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08 @93  	return bug->flags & BUGFLAG_WARNING;
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  94  }
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  95  
> 7664c5a1 Jeremy Fitzhardinge 2006-12-08  96  const struct bug_entry *find_bug(unsigned long bugaddr);

This looks like a bug in mn10300.  This code is within an ifdef on
CONFIG_GENERIC_BUG, and the declaration of the structure is within
ifdefs on both CONFIG_GENERIC_BUG and CONFIG_BUG, but:

> CONFIG_MN10300=y
[...]
> CONFIG_GENERIC_BUG=y
[...]
> # CONFIG_BUG is not set

Other architectures, including x86 (arch/x86/Kconfig) and powerpc
(arch/powerpc/Kconfig) have GENERIC_BUG depend on BUG.  Looks like
mn10300 doesn't.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
