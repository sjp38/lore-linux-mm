Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 04C5C6B0038
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 14:02:37 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so14932182wgg.35
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 11:02:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o3si43712459wic.59.2014.12.26.11.02.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Dec 2014 11:02:35 -0800 (PST)
Date: Fri, 26 Dec 2014 20:01:50 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] blackfin: bf533-stamp: add linux/delay.h
Message-ID: <20141226190150.GA15032@redhat.com>
References: <201412252014.vyXxH1Bh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412252014.vyXxH1Bh%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Steven Miao <realmz6@gmail.com>, Mike Frysinger <vapier@gentoo.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 12/25, kbuild test robot wrote:
>
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   53262d12d1658669029ab39a63e3d314108abe66
> commit: a1fd3e24d8a484b3265a6d485202afe093c058f3 percpu_rw_semaphore: reimplement to not block the readers unnecessarily
> date:   2 years ago
> config: blackfin-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout a1fd3e24d8a484b3265a6d485202afe093c058f3
>   # save the attached .config to linux build tree
>   make.cross ARCH=blackfin
>
> All error/warnings:
>
>    arch/blackfin/mach-bf533/boards/stamp.c: In function 'net2272_init':
> >> arch/blackfin/mach-bf533/boards/stamp.c:834:2: error: implicit declaration of function 'mdelay' [-Werror=implicit-function-declaration]
>    cc1: some warnings being treated as errors

That commit removed linux/delay.h from percpu-rwsem.h. But stamp.c
obviously should not rely on percpu-rwsem.h, and in fact fs.h includes
it by mistake (this needs another patch).

I think mach-bf533/boards/stamp.c needs the trivial fix.




> vim +/mdelay +834 arch/blackfin/mach-bf533/boards/stamp.c
>
> 9be8631b Mike Frysinger 2011-05-04  818  		gpio_free(GPIO_PF0);
> 9be8631b Mike Frysinger 2011-05-04  819  		return ret;
> 9be8631b Mike Frysinger 2011-05-04  820  	}
> 9be8631b Mike Frysinger 2011-05-04  821
> 9be8631b Mike Frysinger 2011-05-04  822  	ret = gpio_request(GPIO_PF11, "net2272");
> 9be8631b Mike Frysinger 2011-05-04  823  	if (ret) {
> 9be8631b Mike Frysinger 2011-05-04  824  		gpio_free(GPIO_PF0);
> 9be8631b Mike Frysinger 2011-05-04  825  		gpio_free(GPIO_PF1);
> 9be8631b Mike Frysinger 2011-05-04  826  		return ret;
> 9be8631b Mike Frysinger 2011-05-04  827  	}
> 9be8631b Mike Frysinger 2011-05-04  828
> 9be8631b Mike Frysinger 2011-05-04  829  	gpio_direction_output(GPIO_PF0, 0);
> 9be8631b Mike Frysinger 2011-05-04  830  	gpio_direction_output(GPIO_PF1, 1);
> 9be8631b Mike Frysinger 2011-05-04  831
> 9be8631b Mike Frysinger 2011-05-04  832  	/* Reset the USB chip */
> 9be8631b Mike Frysinger 2011-05-04  833  	gpio_direction_output(GPIO_PF11, 0);
> 9be8631b Mike Frysinger 2011-05-04 @834  	mdelay(2);
> 9be8631b Mike Frysinger 2011-05-04  835  	gpio_set_value(GPIO_PF11, 1);
> 9be8631b Mike Frysinger 2011-05-04  836  #endif
> 9be8631b Mike Frysinger 2011-05-04  837
> 9be8631b Mike Frysinger 2011-05-04  838  	return 0;
> 9be8631b Mike Frysinger 2011-05-04  839  }
> 9be8631b Mike Frysinger 2011-05-04  840
> 1394f032 Bryan Wu       2007-05-06  841  static int __init stamp_init(void)
> 1394f032 Bryan Wu       2007-05-06  842  {
>
> :::::: The code at line 834 was first introduced by commit
> :::::: 9be8631b8a7d11fa6d206fcf0a7a2005ed39f41b Blackfin: net2272: move pin setup to boards files
>
> :::::: TO: Mike Frysinger <vapier@gentoo.org>
> :::::: CC: Mike Frysinger <vapier@gentoo.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
