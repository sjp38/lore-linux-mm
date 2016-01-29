Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA486B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:29:04 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l66so48073362wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:29:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a63si10081793wmd.11.2016.01.29.02.29.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 02:29:03 -0800 (PST)
Subject: Re: [linux-next:master 1875/2100] include/linux/jump_label.h:122:2:
 error: implicit declaration of function 'atomic_read'
References: <201601291512.vqk4lpvV%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AB3EEB.8090808@suse.cz>
Date: Fri, 29 Jan 2016 11:28:59 +0100
MIME-Version: 1.0
In-Reply-To: <201601291512.vqk4lpvV%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: kbuild-all@01.org, linux-s390@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On 01/29/2016 08:06 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   735cfa51151aeae6df04074165aa36b42481df86
> commit: e8bd33570a656979c09ce66a11ca8864fda8ad0c [1875/2100] mm, printk: introduce new format string for flags-fix
> config: s390-allyesconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout e8bd33570a656979c09ce66a11ca8864fda8ad0c
>         # save the attached .config to linux build tree
>         make.cross ARCH=s390 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/static_key.h:1:0,
>                     from include/linux/tracepoint-defs.h:11,
>                     from include/linux/mmdebug.h:6,
>                     from arch/s390/include/asm/cmpxchg.h:10,
>                     from arch/s390/include/asm/atomic.h:19,
>                     from include/linux/atomic.h:4,
>                     from include/linux/debug_locks.h:5,
>                     from include/linux/lockdep.h:23,
>                     from include/linux/hardirq.h:5,
>                     from include/linux/kvm_host.h:10,
>                     from arch/s390/kernel/asm-offsets.c:10:
>    include/linux/jump_label.h: In function 'static_key_count':
>>> include/linux/jump_label.h:122:2: error: implicit declaration of function 'atomic_read' [-Werror=implicit-function-declaration]
>      return atomic_read(&key->enabled);

Sigh.

I don't get it, there's "#include <linux/atomic.h>" in jump_label.h right before
it gets used. So, what implicit declaration?

BTW, do you really need to use VM_BUG_ON() and thus include mmdebug.h in
arch/s390/include/asm/cmpxchg.h ? Is that assertion really related to VM?

>      ^
>    In file included from include/linux/atomic.h:4:0,
>                     from include/linux/debug_locks.h:5,
>                     from include/linux/lockdep.h:23,
>                     from include/linux/hardirq.h:5,
>                     from include/linux/kvm_host.h:10,
>                     from arch/s390/kernel/asm-offsets.c:10:
>    arch/s390/include/asm/atomic.h: At top level:
>    arch/s390/include/asm/atomic.h:74:19: error: static declaration of 'atomic_read' follows non-static declaration
>     static inline int atomic_read(const atomic_t *v)
>                       ^
>    In file included from include/linux/static_key.h:1:0,
>                     from include/linux/tracepoint-defs.h:11,
>                     from include/linux/mmdebug.h:6,
>                     from arch/s390/include/asm/cmpxchg.h:10,
>                     from arch/s390/include/asm/atomic.h:19,
>                     from include/linux/atomic.h:4,
>                     from include/linux/debug_locks.h:5,
>                     from include/linux/lockdep.h:23,
>                     from include/linux/hardirq.h:5,
>                     from include/linux/kvm_host.h:10,
>                     from arch/s390/kernel/asm-offsets.c:10:
>    include/linux/jump_label.h:122:9: note: previous implicit declaration of 'atomic_read' was here
>      return atomic_read(&key->enabled);
>             ^
>    cc1: some warnings being treated as errors
>    make[2]: *** [arch/s390/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
> 
> vim +/atomic_read +122 include/linux/jump_label.h
> 
> c0ccf6f99 Anton Blanchard 2015-04-09  106  #include <asm/jump_label.h>
> c0ccf6f99 Anton Blanchard 2015-04-09  107  #endif
> c0ccf6f99 Anton Blanchard 2015-04-09  108  
> c0ccf6f99 Anton Blanchard 2015-04-09  109  #ifndef __ASSEMBLY__
> bf5438fca Jason Baron     2010-09-17  110  
> bf5438fca Jason Baron     2010-09-17  111  enum jump_label_type {
> 76b235c6b Peter Zijlstra  2015-07-24  112  	JUMP_LABEL_NOP = 0,
> 76b235c6b Peter Zijlstra  2015-07-24  113  	JUMP_LABEL_JMP,
> bf5438fca Jason Baron     2010-09-17  114  };
> bf5438fca Jason Baron     2010-09-17  115  
> bf5438fca Jason Baron     2010-09-17  116  struct module;
> bf5438fca Jason Baron     2010-09-17  117  
> 851cf6e7d Andrew Jones    2013-08-09  118  #include <linux/atomic.h>
> ea5e9539a Mel Gorman      2014-06-04  119  
> ea5e9539a Mel Gorman      2014-06-04  120  static inline int static_key_count(struct static_key *key)
> ea5e9539a Mel Gorman      2014-06-04  121  {
> ea5e9539a Mel Gorman      2014-06-04 @122  	return atomic_read(&key->enabled);
> ea5e9539a Mel Gorman      2014-06-04  123  }
> ea5e9539a Mel Gorman      2014-06-04  124  
> bf5438fca Jason Baron     2010-09-17  125  #ifdef HAVE_JUMP_LABEL
> bf5438fca Jason Baron     2010-09-17  126  
> a1efb01fe Peter Zijlstra  2015-07-24  127  #define JUMP_TYPE_FALSE	0UL
> a1efb01fe Peter Zijlstra  2015-07-24  128  #define JUMP_TYPE_TRUE	1UL
> a1efb01fe Peter Zijlstra  2015-07-24  129  #define JUMP_TYPE_MASK	1UL
> c5905afb0 Ingo Molnar     2012-02-24  130  
> 
> :::::: The code at line 122 was first introduced by commit
> :::::: ea5e9539abf1258f23e725cb9cb25aa74efa29eb include/linux/jump_label.h: expose the reference count
> 
> :::::: TO: Mel Gorman <mgorman@suse.de>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
