Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6008F6B0294
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:43:10 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id d9so143292522itc.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:43:10 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 192si17507041ioe.138.2017.01.24.10.43.03
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 10:43:03 -0800 (PST)
Date: Tue, 24 Jan 2017 18:41:59 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v3] mm: add arch-independent testcases for RODATA
Message-ID: <20170124184159.GH7572@leverpostej>
References: <20170124160434.GA23547@pjb1027-Latitude-E5410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124160434.GA23547@pjb1027-Latitude-E5410>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jinbum Park <jinb.park7@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, keescook@chromium.org, arjan@linux.intel.com, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@redhat.com, kernel-hardening@lists.openwall.com, kernel-janitors@vger.kernel.org, linux@armlinux.org.uk

On Wed, Jan 25, 2017 at 01:04:34AM +0900, Jinbum Park wrote:
> This patch makes arch-independent testcases for RODATA.
> Both x86 and x86_64 already have testcases for RODATA,
> But they are arch-specific because using inline assembly directly.
> 
> and cacheflush.h is not suitable location for rodata-test related things.
> Since they were in cacheflush.h,
> If someone change the state of CONFIG_DEBUG_RODATA_TEST,
> It cause overhead of kernel build.
> 
> To solve above issue,
> Move x86's testcases to shared location able to be called by other archs.
> and move declaration of rodata_test_data to separate header file.
> 
> Signed-off-by: Jinbum Park <jinb.park7@gmail.com>
> ---
> v3: Use probe_kernel_write() instead of put_user()
> 	Move declaration of rodata_test_data to separate header (rodata_test.h)
> 	Fix a kbuild-test-robot-error related to DEBUG_NX_TEST
> 
> v2: Restore original credit of mm/rodata_test.c
> 
>  arch/x86/Kconfig.debug            | 10 +-----
>  arch/x86/include/asm/cacheflush.h | 10 ------
>  arch/x86/kernel/Makefile          |  1 -
>  arch/x86/kernel/test_rodata.c     | 75 ---------------------------------------
>  arch/x86/mm/init_32.c             |  4 +--
>  arch/x86/mm/init_64.c             |  4 +--
>  include/linux/rodata_test.h       | 24 +++++++++++++
>  mm/Kconfig.debug                  |  7 ++++
>  mm/Makefile                       |  1 +
>  mm/rodata_test.c                  | 63 ++++++++++++++++++++++++++++++++
>  10 files changed, 98 insertions(+), 101 deletions(-)
>  delete mode 100644 arch/x86/kernel/test_rodata.c
>  create mode 100644 include/linux/rodata_test.h
>  create mode 100644 mm/rodata_test.c

> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 928d657..874b57c 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -51,6 +51,7 @@
>  #include <asm/cacheflush.h>
>  #include <asm/page_types.h>
>  #include <asm/init.h>
> +#include <linux/rodata_test.h>

> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 5fff913..663d475 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -54,6 +54,7 @@
>  #include <asm/init.h>
>  #include <asm/uv/uv.h>
>  #include <asm/setup.h>
> +#include <linux/rodata_test.h>

Rather than fixing up the include here, could we move the rodata_test()
call out into mark_readonly()? e.g.

diff --git a/init/main.c b/init/main.c
index b0c9d6f..d72a8d0 100644
--- a/init/main.c
+++ b/init/main.c
@@ -82,6 +82,7 @@
 #include <linux/proc_ns.h>
 #include <linux/io.h>
 #include <linux/cache.h>
+#include <linux/rodata_test.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -937,10 +938,12 @@ static int __init set_debug_rodata(char *str)
 #ifdef CONFIG_DEBUG_RODATA
 static void mark_readonly(void)
 {
-       if (rodata_enabled)
+       if (rodata_enabled) {
                mark_rodata_ro();
-       else
+               rodata_test();
+       } else {
                pr_info("Kernel memory protection disabled.\n");
+       }
 }
 #else
 static inline void mark_readonly(void)

... that would remove a few lines of code, and we wouldn't have to add
more in other architectures.

I've given this a go with that applied on arm64. It reported success,
and with mark_rodata_ro() hacked out it detected that .rodata was
writeable.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
