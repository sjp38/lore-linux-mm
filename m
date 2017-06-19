Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0A66B03CA
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:31:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o21so70059330qtb.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 07:31:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n66si9228541qka.349.2017.06.19.07.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 07:31:16 -0700 (PDT)
Date: Mon, 19 Jun 2017 10:31:13 -0400
From: Don Zickus <dzickus@redhat.com>
Subject: Re: [mmotm:master 38/317] warning: (MN10300 && ..) selects
 HAVE_NMI_WATCHDOG which has unmet direct dependencies (HAVE_NMI)
Message-ID: <20170619143113.vcnvfed2lrxmiwmt@redhat.com>
References: <201706170807.xkDnmZ42%fengguang.wu@intel.com>
 <20170617130608.08f794bb@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170617130608.08f794bb@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, dhowells@redhat.com
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Babu Moger <babu.moger@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

(adding David H.)

On Sat, Jun 17, 2017 at 01:06:08PM +1000, Nicholas Piggin wrote:
> On Sat, 17 Jun 2017 08:14:09 +0800
> kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   8c91e2a1ea04c0c1e29415c62f151e77de2291f8
> > commit: 590b165eb905ab322bb91f04f9708deb8c80f75e [38/317] kernel/watchdog: split up config options
> > config: mn10300-asb2364_defconfig (attached as .config)
> > compiler: am33_2.0-linux-gcc (GCC) 6.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 590b165eb905ab322bb91f04f9708deb8c80f75e
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=mn10300 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> > warning: (MN10300 && HAVE_HARDLOCKUP_DETECTOR_ARCH) selects HAVE_NMI_WATCHDOG which has unmet direct dependencies (HAVE_NMI)

Hmm, MN10300 selects HAVE_NMI_WATCHDOG if MN10300_WD_TIMER is set.  However,
HAVE_NMI_WATCHDOG depends on HAVE_NMI which is not selected for arch
mn10300.  So I am scratching my head how this ever worked, regardless of
this patchset.

Hi David,

Does mn10300 have an NMI entry point (it seemed like you copied an old i386
nmi snapshot during the initial port)?

Cheers,
Don


> 
> Hmm, the arch is not supposed to have HAVE_HARDLOCKUP_DETECTOR_ARCH
> without explicitly selecting it. An it does not in the attached .config.
> I guess this is Kconfig being helpful...
> 
> arch/Kconfig:
> 
> config HAVE_NMI_WATCHDOG
>         bool
>         help
>           The arch provides a low level NMI watchdog. It provides
>           asm/nmi.h, and defines its own arch_touch_nmi_watchdog().
> 
> config HAVE_HARDLOCKUP_DETECTOR_ARCH
>         bool
>         select HAVE_NMI_WATCHDOG
>         help
>           The arch chooses to provide its own hardlockup detector, which is
>           a superset of the HAVE_NMI_WATCHDOG. It also conforms to config
>           interfaces and parameters provided by hardlockup detector subsystem.
> 
> Idea was to have arch select HAVE_HARDLOCKUP_DETECTOR_ARCH and it would
> get HAVE_NMI_WATCHDOG. Would it be better to make it depend on
> HAVE_NMI_WATCHDOG and require the arch select both?
> 
> Thanks,
> Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
