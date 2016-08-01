Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBF336B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 12:40:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so85757295wme.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 09:40:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rg17si32259072wjb.35.2016.08.01.09.39.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 09:39:59 -0700 (PDT)
Date: Mon, 1 Aug 2016 18:39:37 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [linux-next:master 12268/12761] include/linux/ratelimit.h:61:3:
 error: 'DRIVER_NAME' undeclared
Message-ID: <20160801163937.GA28119@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201608012050.XZyUj6hM%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-fbdev@vger.kernel.org

On Mon, Aug 01, 2016 at 08:53:52PM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   c24c1308a5b274bbd90db927cb18efddc95340c7
> commit: f207be0388d86d4ed049fbbec2650a2688b5b0f7 [12268/12761] ratelimit: extend to print suppressed messages on release
> config: blackfin-allyesconfig (attached as .config)
> compiler: bfin-uclinux-gcc (GCC) 4.6.3
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout f207be0388d86d4ed049fbbec2650a2688b5b0f7
>         # save the attached .config to linux build tree
>         make.cross ARCH=blackfin 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/device.h:27:0,
>                     from include/linux/i2c.h:30,
>                     from include/uapi/linux/fb.h:5,
>                     from include/linux/fb.h:5,
>                     from drivers/video/fbdev/bfin_adv7393fb.c:23:
>    include/linux/ratelimit.h: In function 'ratelimit_state_exit':
> >> include/linux/ratelimit.h:61:3: error: 'DRIVER_NAME' undeclared (first use in this function)
>    include/linux/ratelimit.h:61:3: note: each undeclared identifier is reported only once for each function it appears in
> >> include/linux/ratelimit.h:61:3: error: expected ')' before string constant

Hmm, so I get a different build error with this:

arch/blackfin/mach-common/arch_checks.c:24:3: error: #error "Sclk value selected is less than minimum. Please select a proper value for SCLK multiplier"
arch/blackfin/mach-common/arch_checks.c:28:3: error: #error "ANOMALY 05000273, please make sure CCLK is at least 2x SCLK"
arch/blackfin/mach-common/arch_checks.c:51:3: error: #error the MPU will not function safely while Anomaly 05000263 applies
make[1]: *** [arch/blackfin/mach-common/arch_checks.o] Error 1
make: *** [arch/blackfin/mach-common] Error 2
make: *** Waiting for unfinished jobs....

If I checkout the next commit:

  e8a10ce9a9fd ("printk: add kernel parameter to control writes to /dev/kmsg")

and build printk.c which is the only user of ratelimit_state_exit(), it
builds fine-ish (blackfin compiler can't follow the if (write) thing but
that's a different issue):

$ ~/bin/make.cross ARCH=blackfin kernel/printk/printk.o
make CROSS_COMPILE=/home/boris/opt/gcc-4.6.3-nolibc/bfin-uclinux/bin/bfin-uclinux- --jobs=8 ARCH=blackfin kernel/printk/printk.o
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/bounds.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
<stdin>:1268:2: warning: #warning syscall accept4 not implemented [-Wcpp]
<stdin>:1298:2: warning: #warning syscall userfaultfd not implemented [-Wcpp]
<stdin>:1301:2: warning: #warning syscall membarrier not implemented [-Wcpp]
<stdin>:1304:2: warning: #warning syscall mlock2 not implemented [-Wcpp]
<stdin>:1307:2: warning: #warning syscall copy_file_range not implemented [-Wcpp]
<stdin>:1310:2: warning: #warning syscall preadv2 not implemented [-Wcpp]
<stdin>:1313:2: warning: #warning syscall pwritev2 not implemented [-Wcpp]
  CC      kernel/printk/printk.o
kernel/printk/printk.c: In function 'devkmsg_sysctl_set_loglvl':
kernel/printk/printk.c:184:16: warning: 'old' may be used uninitialized in this function [-Wuninitialized]

Hmm, I can trigger it this way:

$ ~/bin/make.cross ARCH=blackfin drivers/video/fbdev/bfin_adv7393fb.o
make CROSS_COMPILE=/home/boris/opt/gcc-4.6.3-nolibc/bfin-uclinux/bin/bfin-uclinux- --jobs=8 ARCH=blackfin drivers/video/fbdev/bfin_adv7393fb.o
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/bounds.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
<stdin>:1268:2: warning: #warning syscall accept4 not implemented [-Wcpp]
<stdin>:1298:2: warning: #warning syscall userfaultfd not implemented [-Wcpp]
<stdin>:1301:2: warning: #warning syscall membarrier not implemented [-Wcpp]
<stdin>:1304:2: warning: #warning syscall mlock2 not implemented [-Wcpp]
<stdin>:1307:2: warning: #warning syscall copy_file_range not implemented [-Wcpp]
<stdin>:1310:2: warning: #warning syscall preadv2 not implemented [-Wcpp]
<stdin>:1313:2: warning: #warning syscall pwritev2 not implemented [-Wcpp]
  CC      drivers/video/fbdev/bfin_adv7393fb.o
In file included from include/linux/device.h:27:0,
                 from include/linux/i2c.h:30,
                 from include/uapi/linux/fb.h:5,
                 from include/linux/fb.h:5,
                 from drivers/video/fbdev/bfin_adv7393fb.c:23:
include/linux/ratelimit.h: In function 'ratelimit_state_exit':
include/linux/ratelimit.h:61:3: error: 'DRIVER_NAME' undeclared (first use in this function)
include/linux/ratelimit.h:61:3: note: each undeclared identifier is reported only once for each function it appears in
include/linux/ratelimit.h:61:3: error: expected ')' before string constant
drivers/video/fbdev/bfin_adv7393fb.c: At top level:
drivers/video/fbdev/bfin_adv7393fb.c:323:12: warning: 'proc_output' defined but not used [-Wunused-function]
scripts/Makefile.build:289: recipe for target 'drivers/video/fbdev/bfin_adv7393fb.o' failed
make[1]: *** [drivers/video/fbdev/bfin_adv7393fb.o] Error 1
Makefile:1628: recipe for target 'drivers/video/fbdev/bfin_adv7393fb.o' failed
make: *** [drivers/video/fbdev/bfin_adv7393fb.o] Error 2

And of course it won't build. Here's a fix.

---
From: Borislav Petkov <bp@suse.de>
Date: Mon, 1 Aug 2016 18:34:42 +0200
Subject: [PATCH] fbdev/bfin_adv7393fb: Move DRIVER_NAME before its first use

Move the DRIVER_NAME macro definition before the first usage site and
fix build error.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: linux-fbdev@vger.kernel.org
---
 drivers/video/fbdev/bfin_adv7393fb.c | 2 ++
 drivers/video/fbdev/bfin_adv7393fb.h | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/video/fbdev/bfin_adv7393fb.c b/drivers/video/fbdev/bfin_adv7393fb.c
index 8fe41caac38e..e2d7d039ce3b 100644
--- a/drivers/video/fbdev/bfin_adv7393fb.c
+++ b/drivers/video/fbdev/bfin_adv7393fb.c
@@ -10,6 +10,8 @@
  * TODO: Code Cleanup
  */
 
+#define DRIVER_NAME "bfin-adv7393"
+
 #define pr_fmt(fmt) DRIVER_NAME ": " fmt
 
 #include <linux/module.h>
diff --git a/drivers/video/fbdev/bfin_adv7393fb.h b/drivers/video/fbdev/bfin_adv7393fb.h
index cd591b5152a5..afd0380e19e1 100644
--- a/drivers/video/fbdev/bfin_adv7393fb.h
+++ b/drivers/video/fbdev/bfin_adv7393fb.h
@@ -59,8 +59,6 @@ enum {
 	BLANK_OFF,
 };
 
-#define DRIVER_NAME "bfin-adv7393"
-
 struct adv7393fb_modes {
 	const s8 name[25];	/* Full name */
 	u16 xres;		/* Active Horizonzal Pixels  */
-- 
2.8.4

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
