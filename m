Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 829696B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:21:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g64so252274499pfb.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:21:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d63si30523230pfd.93.2016.06.06.14.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:21:29 -0700 (PDT)
Date: Mon, 6 Jun 2016 14:21:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 152/178] include/linux/kexec.h:356:9: error:
 implicit declaration of function 'phys_to_virt'
Message-Id: <20160606142128.5b0385f9cb178e5905002534@linux-foundation.org>
In-Reply-To: <20160604104243.GG1041@n2100.armlinux.org.uk>
References: <201606041044.dTOHh5q4%fengguang.wu@intel.com>
	<20160604104243.GG1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 4 Jun 2016 11:42:43 +0100 Russell King - ARM Linux <linux@armlinux.org.uk> wrote:

> On Sat, Jun 04, 2016 at 10:11:47AM +0800, kbuild test robot wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   2e0066ec9585a5074c8040d639c3c669eb4e905f
> > commit: 60c8a7d9e20b888121b304895074928bf9b69029 [152/178] kexec: allow architectures to override boot mapping
> > config: sh-sh7785lcr_32bit_defconfig (attached as .config)
> > compiler: sh4-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 60c8a7d9e20b888121b304895074928bf9b69029
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=sh 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    In file included from arch/sh/kernel/reboot.c:2:0:
> >    include/linux/kexec.h: In function 'boot_phys_to_virt':
> > >> include/linux/kexec.h:356:9: error: implicit declaration of function 'phys_to_virt' [-Werror=implicit-function-declaration]
> >      return phys_to_virt(boot_phys_to_phys(entry));
> >             ^
> 
> Is there a reason SH doesn't provide phys_to_virt()?  Isn't that a basic
> requirement for every architecture?

It's there, in arch/sh/include/asm/io.h. 
kexec-allow-architectures-to-override-boot-mapping-fix.patch fixes this
error.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: kexec-allow-architectures-to-override-boot-mapping-fix

kexec.h needs asm/io.h for phys_to_virt()

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/kexec.h |    2 ++
 1 file changed, 2 insertions(+)

diff -puN include/linux/kexec.h~kexec-allow-architectures-to-override-boot-mapping-fix include/linux/kexec.h
--- a/include/linux/kexec.h~kexec-allow-architectures-to-override-boot-mapping-fix
+++ a/include/linux/kexec.h
@@ -14,6 +14,8 @@
 
 #if !defined(__ASSEMBLY__)
 
+#include <asm/io.h>
+
 #include <uapi/linux/kexec.h>
 
 #ifdef CONFIG_KEXEC_CORE
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
