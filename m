Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6177F6B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 23:06:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q78so52817585pfj.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 20:06:21 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id i11si3570319pgn.298.2017.06.16.20.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 20:06:20 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id f185so27500697pgc.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 20:06:20 -0700 (PDT)
Date: Sat, 17 Jun 2017 13:06:08 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [mmotm:master 38/317] warning: (MN10300 && ..) selects
 HAVE_NMI_WATCHDOG which has unmet direct dependencies (HAVE_NMI)
Message-ID: <20170617130608.08f794bb@roar.ozlabs.ibm.com>
In-Reply-To: <201706170807.xkDnmZ42%fengguang.wu@intel.com>
References: <201706170807.xkDnmZ42%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Don Zickus <dzickus@redhat.com>, Babu Moger <babu.moger@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 17 Jun 2017 08:14:09 +0800
kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8c91e2a1ea04c0c1e29415c62f151e77de2291f8
> commit: 590b165eb905ab322bb91f04f9708deb8c80f75e [38/317] kernel/watchdog: split up config options
> config: mn10300-asb2364_defconfig (attached as .config)
> compiler: am33_2.0-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 590b165eb905ab322bb91f04f9708deb8c80f75e
>         # save the attached .config to linux build tree
>         make.cross ARCH=mn10300 
> 
> All warnings (new ones prefixed by >>):
> 
> warning: (MN10300 && HAVE_HARDLOCKUP_DETECTOR_ARCH) selects HAVE_NMI_WATCHDOG which has unmet direct dependencies (HAVE_NMI)

Hmm, the arch is not supposed to have HAVE_HARDLOCKUP_DETECTOR_ARCH
without explicitly selecting it. An it does not in the attached .config.
I guess this is Kconfig being helpful...

arch/Kconfig:

config HAVE_NMI_WATCHDOG
        bool
        help
          The arch provides a low level NMI watchdog. It provides
          asm/nmi.h, and defines its own arch_touch_nmi_watchdog().

config HAVE_HARDLOCKUP_DETECTOR_ARCH
        bool
        select HAVE_NMI_WATCHDOG
        help
          The arch chooses to provide its own hardlockup detector, which is
          a superset of the HAVE_NMI_WATCHDOG. It also conforms to config
          interfaces and parameters provided by hardlockup detector subsystem.

Idea was to have arch select HAVE_HARDLOCKUP_DETECTOR_ARCH and it would
get HAVE_NMI_WATCHDOG. Would it be better to make it depend on
HAVE_NMI_WATCHDOG and require the arch select both?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
