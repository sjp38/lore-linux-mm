Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CABD36B0038
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 12:25:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so17091636oig.1
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 09:25:35 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id d53si8548696otd.287.2016.10.10.09.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 09:25:35 -0700 (PDT)
Subject: Re: lib/atomic64_test.c:217:9: error: implicit declaration of
 function 'atomic64_dec_if_positive'
References: <201610092211.2jMb6gqJ%fengguang.wu@intel.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <9d2d3397-bce8-3e5d-bb72-f2ba41ada8fb@synopsys.com>
Date: Mon, 10 Oct 2016 09:21:57 -0700
MIME-Version: 1.0
In-Reply-To: <201610092211.2jMb6gqJ%fengguang.wu@intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew / Peter,

On 10/09/2016 07:37 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   b66484cd74706fa8681d051840fe4b18a3da40ff
> commit: 51a021244b9d579be6b4f8c15c493a76deb2a79e atomic64: no need for CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
> date:   2 days ago
> config: frv-allmodconfig (attached as .config)
> compiler: frv-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 51a021244b9d579be6b4f8c15c493a76deb2a79e
>         # save the attached .config to linux build tree
>         make.cross ARCH=frv 
>
> All errors (new ones prefixed by >>):
>
>    In file included from include/linux/init.h:4:0,
>                     from lib/atomic64_test.c:14:
>    lib/atomic64_test.c: In function 'test_atomic64':
>    lib/atomic64_test.c:208:9: error: implicit declaration of function 'atomic64_add_unless' [-Werror=implicit-function-declaration]
>      BUG_ON(atomic64_add_unless(&v, one, v0));

FWIW, this error was not introduced by my patch. It seems on FRV atomic64 self
tests were never enabled and thus the breakage was not noticed. I took today's
upstream linus tree, reverted my patch and still see this error. There are

Should we make ATOMIC64_SELFTEST depend on !FRV - or do we prefer adding the
missing primitives to seeming orphan arch ? I took a quick look at their atomic.h
and it seems non trivial given my frv foo !

>             ^
>    include/linux/compiler.h:168:42: note: in definition of macro 'unlikely'
>     # define unlikely(x) __builtin_expect(!!(x), 0)
>                                              ^
>    lib/atomic64_test.c:208:2: note: in expansion of macro 'BUG_ON'
>      BUG_ON(atomic64_add_unless(&v, one, v0));
>      ^~~~~~
>>> lib/atomic64_test.c:217:9: error: implicit declaration of function 'atomic64_dec_if_positive' [-Werror=implicit-function-declaration]
>      BUG_ON(atomic64_dec_if_positive(&v) != (onestwos - 1));
>             ^
>    include/linux/compiler.h:168:42: note: in definition of macro 'unlikely'
>     # define unlikely(x) __builtin_expect(!!(x), 0)
>                                              ^
>    lib/atomic64_test.c:217:2: note: in expansion of macro 'BUG_ON'
>      BUG_ON(atomic64_dec_if_positive(&v) != (onestwos - 1));
>      ^~~~~~
>    lib/atomic64_test.c:230:10: error: implicit declaration of function 'atomic64_inc_not_zero' [-Werror=implicit-function-declaration]
>      BUG_ON(!atomic64_inc_not_zero(&v));
>              ^
>    include/linux/compiler.h:168:42: note: in definition of macro 'unlikely'
>     # define unlikely(x) __builtin_expect(!!(x), 0)
>                                              ^
>    lib/atomic64_test.c:230:2: note: in expansion of macro 'BUG_ON'
>      BUG_ON(!atomic64_inc_not_zero(&v));
>      ^~~~~~
>    cc1: some warnings being treated as errors
>
> vim +/atomic64_dec_if_positive +217 lib/atomic64_test.c
>
> 978e5a36 Boqun Feng    2015-11-04  202  	DEC_RETURN_FAMILY_TEST(64, v0);
> 86a89380 Luca Barbieri 2010-02-24  203  
> 978e5a36 Boqun Feng    2015-11-04  204  	XCHG_FAMILY_TEST(64, v0, v1);
> 978e5a36 Boqun Feng    2015-11-04  205  	CMPXCHG_FAMILY_TEST(64, v0, v1, v2);
> 86a89380 Luca Barbieri 2010-02-24  206  
> 86a89380 Luca Barbieri 2010-02-24  207  	INIT(v0);
> 9efbcd59 Luca Barbieri 2010-03-01 @208  	BUG_ON(atomic64_add_unless(&v, one, v0));
> 86a89380 Luca Barbieri 2010-02-24  209  	BUG_ON(v.counter != r);
> 86a89380 Luca Barbieri 2010-02-24  210  
> 86a89380 Luca Barbieri 2010-02-24  211  	INIT(v0);
> 9efbcd59 Luca Barbieri 2010-03-01  212  	BUG_ON(!atomic64_add_unless(&v, one, v1));
> 86a89380 Luca Barbieri 2010-02-24  213  	r += one;
> 86a89380 Luca Barbieri 2010-02-24  214  	BUG_ON(v.counter != r);
> 86a89380 Luca Barbieri 2010-02-24  215  
> 86a89380 Luca Barbieri 2010-02-24  216  	INIT(onestwos);
> 86a89380 Luca Barbieri 2010-02-24 @217  	BUG_ON(atomic64_dec_if_positive(&v) != (onestwos - 1));
> 86a89380 Luca Barbieri 2010-02-24  218  	r -= one;
> 86a89380 Luca Barbieri 2010-02-24  219  	BUG_ON(v.counter != r);
> 86a89380 Luca Barbieri 2010-02-24  220  
>
> :::::: The code at line 217 was first introduced by commit
> :::::: 86a8938078a8bb518c5376de493e348c7490d506 lib: Add self-test for atomic64_t
>
> :::::: TO: Luca Barbieri <luca@luca-barbieri.com>
> :::::: CC: H. Peter Anvin <hpa@zytor.com>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
