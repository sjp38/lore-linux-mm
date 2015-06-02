Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A32126B0074
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 22:27:34 -0400 (EDT)
Received: by padj3 with SMTP id j3so56635132pad.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 19:27:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id c7si24060166pdn.193.2015.06.01.19.27.33
        for <linux-mm@kvack.org>;
        Mon, 01 Jun 2015 19:27:33 -0700 (PDT)
Date: Tue, 2 Jun 2015 10:27:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <20150602022730.GA12702@wfg-t540p.sh.intel.com>
References: <201506020621.UtqnXSMY%fengguang.wu@intel.com>
 <20150601232755.GA30913@cloud>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150601232755.GA30913@cloud>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josh@joshtriplett.org
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>

// CC mn10300 maintainers.

On Mon, Jun 01, 2015 at 04:27:55PM -0700, josh@joshtriplett.org wrote:
> On Tue, Jun 02, 2015 at 06:08:25AM +0800, kbuild test robot wrote:
> > All error/warnings:
> > 
> >    In file included from include/linux/page-flags.h:9:0,
> >                     from kernel/bounds.c:9:
> > >> include/linux/bug.h:91:47: warning: 'struct bug_entry' declared inside parameter list
> >     static inline int is_warning_bug(const struct bug_entry *bug)
> >                                                   ^
> > >> include/linux/bug.h:91:47: warning: its scope is only this definition or declaration, which is probably not what you want
> >    include/linux/bug.h: In function 'is_warning_bug':
> > >> include/linux/bug.h:93:12: error: dereferencing pointer to incomplete type
> >      return bug->flags & BUGFLAG_WARNING;
> >                ^
> >    make[2]: *** [kernel/bounds.s] Error 1
> >    make[2]: Target '__build' not remade because of errors.
> >    make[1]: *** [prepare0] Error 2
> >    make[1]: Target 'prepare' not remade because of errors.
> >    make: *** [sub-make] Error 2
> > 
> > vim +93 include/linux/bug.h
> > 
> > 35edd910 Paul Gortmaker      2011-11-16  85  
> > 35edd910 Paul Gortmaker      2011-11-16  86  #endif	/* __CHECKER__ */
> > 35edd910 Paul Gortmaker      2011-11-16  87  
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  88  #ifdef CONFIG_GENERIC_BUG
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  89  #include <asm-generic/bug.h>
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  90  
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08 @91  static inline int is_warning_bug(const struct bug_entry *bug)
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  92  {
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08 @93  	return bug->flags & BUGFLAG_WARNING;
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  94  }
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  95  
> > 7664c5a1 Jeremy Fitzhardinge 2006-12-08  96  const struct bug_entry *find_bug(unsigned long bugaddr);
> 
> This looks like a bug in mn10300.  This code is within an ifdef on
> CONFIG_GENERIC_BUG, and the declaration of the structure is within
> ifdefs on both CONFIG_GENERIC_BUG and CONFIG_BUG, but:
> 
> > CONFIG_MN10300=y
> [...]
> > CONFIG_GENERIC_BUG=y
> [...]
> > # CONFIG_BUG is not set
> 
> Other architectures, including x86 (arch/x86/Kconfig) and powerpc
> (arch/powerpc/Kconfig) have GENERIC_BUG depend on BUG.  Looks like
> mn10300 doesn't.
> 
> - Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
