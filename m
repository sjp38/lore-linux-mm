Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 689D86B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:16:53 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id s41so86102365ioi.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:16:53 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s9si18604135plj.8.2017.02.20.05.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 05:16:52 -0800 (PST)
Date: Mon, 20 Feb 2017 21:16:03 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 5/5] mm: convert mm_struct.mm_count from atomic_t to
 refcount_t
Message-ID: <201702202139.xsH0VRdz%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Content-Disposition: inline
In-Reply-To: <1487587754-10610-6-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Elena,

[auto build test ERROR on mmotm/master]
[also build test ERROR on next-20170220]
[cannot apply to linus/master linux/master v4.10]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Elena-Reshetova/mm-subsystem-refcounter-conversions/20170220-190351
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: blackfin-BF561-EZKIT-SMP_defconfig (attached as .config)
compiler: bfin-uclinux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=blackfin 

All errors (new ones prefixed by >>):

   arch/blackfin/mach-common/smp.c: In function 'cpu_die':
>> arch/blackfin/mach-common/smp.c:426:13: error: passing argument 1 of 'atomic_dec' from incompatible pointer type [-Werror=incompatible-pointer-types]
     atomic_dec(&init_mm.mm_count);
                ^
   In file included from arch/blackfin/include/asm/atomic.h:45:0,
                    from include/linux/atomic.h:4,
                    from arch/blackfin/include/asm/spinlock.h:14,
                    from include/linux/spinlock.h:87,
                    from include/linux/seqlock.h:35,
                    from include/linux/time.h:5,
                    from include/linux/stat.h:18,
                    from include/linux/module.h:10,
                    from arch/blackfin/mach-common/smp.c:10:
   include/asm-generic/atomic.h:211:20: note: expected 'atomic_t * {aka struct <anonymous> *}' but argument is of type 'refcount_t * {aka struct refcount_struct *}'
    static inline void atomic_dec(atomic_t *v)
                       ^~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/atomic_dec +426 arch/blackfin/mach-common/smp.c

0b39db28 Graf Yang        2009-12-28  410  		return -EPERM;
0b39db28 Graf Yang        2009-12-28  411  
0b39db28 Graf Yang        2009-12-28  412  	set_cpu_online(cpu, false);
0b39db28 Graf Yang        2009-12-28  413  	return 0;
0b39db28 Graf Yang        2009-12-28  414  }
0b39db28 Graf Yang        2009-12-28  415  
13dff62d Paul Gortmaker   2013-06-18  416  int __cpu_die(unsigned int cpu)
0b39db28 Graf Yang        2009-12-28  417  {
a17b4b74 Paul E. McKenney 2015-02-26  418  	return cpu_wait_death(cpu, 5);
0b39db28 Graf Yang        2009-12-28  419  }
0b39db28 Graf Yang        2009-12-28  420  
0b39db28 Graf Yang        2009-12-28  421  void cpu_die(void)
0b39db28 Graf Yang        2009-12-28  422  {
a17b4b74 Paul E. McKenney 2015-02-26  423  	(void)cpu_report_death();
0b39db28 Graf Yang        2009-12-28  424  
afdf6066 Elena Reshetova  2017-02-20  425  	refcount_dec(&init_mm.mm_users);
0b39db28 Graf Yang        2009-12-28 @426  	atomic_dec(&init_mm.mm_count);
0b39db28 Graf Yang        2009-12-28  427  
0b39db28 Graf Yang        2009-12-28  428  	local_irq_disable();
0b39db28 Graf Yang        2009-12-28  429  	platform_cpu_die();
0b39db28 Graf Yang        2009-12-28  430  }
0b39db28 Graf Yang        2009-12-28  431  #endif

:::::: The code at line 426 was first introduced by commit
:::::: 0b39db28b953945232719e7ff6fb802aa8a2be5f Blackfin: SMP: add PM/CPU hotplug support

:::::: TO: Graf Yang <graf.yang@analog.com>
:::::: CC: Mike Frysinger <vapier@gentoo.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--5mCyUwZo2JvN/JJP
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--5mCyUwZo2JvN/JJP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
