Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16A006B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 13:43:46 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b35so101573794qta.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 10:43:46 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com (prod-mail-xrelay05.akamai.com. [23.79.238.179])
        by mx.google.com with ESMTP id 34si2940083qtt.92.2016.07.13.10.43.44
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 10:43:45 -0700 (PDT)
Subject: Re: [memcg:since-4.6 827/827]
 arch/s390/include/asm/jump_label.h:17:32: error: expected ':' before
 '__stringify'
References: <201607140156.2OxakZPq%fengguang.wu@intel.com>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <57867DD0.9080801@akamai.com>
Date: Wed, 13 Jul 2016 13:43:44 -0400
MIME-Version: 1.0
In-Reply-To: <201607140156.2OxakZPq%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

Hi,

This is likely due to the fact that the s390 bits
bits were not pulled into -mm here:

http://lkml.iu.edu/hypermail/linux/kernel/1607.0/03114.html

However, I do see them in linux-next, I think from
the s390 tree. So perhaps, that patch can be pulled
in here as well?

Thanks,

-Jason

On 07/13/2016 01:19 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.6
> head:   92b971babd4ca0b796a247752839f82b6f77a5e7
> commit: 92b971babd4ca0b796a247752839f82b6f77a5e7 [827/827] jump_label: remove bug.h, atomic.h dependencies for HAVE_JUMP_LABEL
> config: s390-default_defconfig (attached as .config)
> compiler: s390x-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 92b971babd4ca0b796a247752839f82b6f77a5e7
>         # save the attached .config to linux build tree
>         make.cross ARCH=s390 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/compiler.h:60:0,
>                     from include/uapi/linux/stddef.h:1,
>                     from include/linux/stddef.h:4,
>                     from include/uapi/linux/posix_types.h:4,
>                     from include/uapi/linux/types.h:13,
>                     from include/linux/types.h:5,
>                     from include/linux/jump_label.h:77,
>                     from arch/s390/lib/uaccess.c:10:
>    arch/s390/include/asm/jump_label.h: In function 'arch_static_branch':
>>> arch/s390/include/asm/jump_label.h:17:32: error: expected ':' before '__stringify'
>      asm_volatile_goto("0: brcl 0,"__stringify(JUMP_LABEL_NOP_OFFSET)"\n"
>                                    ^
>    include/linux/compiler-gcc.h:243:47: note: in definition of macro 'asm_volatile_goto'
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                                   ^
>    In file included from include/linux/jump_label.h:105:0,
>                     from arch/s390/lib/uaccess.c:10:
>>> arch/s390/include/asm/jump_label.h:25:1: warning: label 'label' defined but not used [-Wunused-label]
>     label:
>     ^
> 
> vim +17 arch/s390/include/asm/jump_label.h
> 
> d5caa4db Heiko Carstens 2015-01-29  11  /*
> d5caa4db Heiko Carstens 2015-01-29  12   * We use a brcl 0,2 instruction for jump labels at compile time so it
> d5caa4db Heiko Carstens 2015-01-29  13   * can be easily distinguished from a hotpatch generated instruction.
> d5caa4db Heiko Carstens 2015-01-29  14   */
> 11276d53 Peter Zijlstra 2015-07-24  15  static __always_inline bool arch_static_branch(struct static_key *key, bool branch)
> 5373db88 Jan Glauber    2011-03-16  16  {
> d5caa4db Heiko Carstens 2015-01-29 @17  	asm_volatile_goto("0:	brcl 0,"__stringify(JUMP_LABEL_NOP_OFFSET)"\n"
> 5373db88 Jan Glauber    2011-03-16  18  		".pushsection __jump_table, \"aw\"\n"
> 5a79859a Heiko Carstens 2015-02-12  19  		".balign 8\n"
> 5a79859a Heiko Carstens 2015-02-12  20  		".quad 0b, %l[label], %0\n"
> 5373db88 Jan Glauber    2011-03-16  21  		".popsection\n"
> 11276d53 Peter Zijlstra 2015-07-24  22  		: : "X" (&((char *)key)[branch]) : : label);
> 11276d53 Peter Zijlstra 2015-07-24  23  
> 11276d53 Peter Zijlstra 2015-07-24  24  	return false;
> 11276d53 Peter Zijlstra 2015-07-24 @25  label:
> 11276d53 Peter Zijlstra 2015-07-24  26  	return true;
> 11276d53 Peter Zijlstra 2015-07-24  27  }
> 11276d53 Peter Zijlstra 2015-07-24  28  
> 
> :::::: The code at line 17 was first introduced by commit
> :::::: d5caa4dbf9bd2ad8cd7f6be0ca76722be947182b s390/jump label: use different nop instruction
> 
> :::::: TO: Heiko Carstens <heiko.carstens@de.ibm.com>
> :::::: CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
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
