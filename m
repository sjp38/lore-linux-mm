Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CC0D06B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 15:57:01 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ur14so65721494pab.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 12:57:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k18si22087119pfj.164.2015.12.18.12.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 12:57:00 -0800 (PST)
Date: Fri, 18 Dec 2015 12:56:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 7056/7206] kernel/time/timekeeping.c:1096:
 undefined reference to `stop_machine'
Message-Id: <20151218125659.c110d5259f0593b117d499d6@linux-foundation.org>
In-Reply-To: <201512182219.koK0zCrI%fengguang.wu@intel.com>
References: <201512182219.koK0zCrI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 18 Dec 2015 22:39:22 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   f7ac28a6971b43a2ee8bb47c0ef931b38f7888cf
> commit: 64dab25b058c12f935794cb239089303bda7dbc1 [7056/7206] kernel/stop_machine.c: remove CONFIG_SMP dependencies
> config: m32r-usrv_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 64dab25b058c12f935794cb239089303bda7dbc1
>         # save the attached .config to linux build tree
>         make.cross ARCH=m32r 
> 
> All errors (new ones prefixed by >>):
> 
>    kernel/built-in.o: In function `timekeeping_notify':
> >> kernel/time/timekeeping.c:1096: undefined reference to `stop_machine'
>    kernel/time/timekeeping.c:1096:(.text+0x51498): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `stop_machine'
>    mm/built-in.o: In function `build_all_zonelists':
> >> mm/page_alloc.c:4508: undefined reference to `stop_machine'
>    mm/page_alloc.c:4508:(.ref.text+0x1f4): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `stop_machine'
> 

doh.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: kernel-stop_machinec-remove-config_smp-dependencies-fix

stop_machine.o is only built if CONFIG_SMP=y, so this ifdef always
evaluates to true.

Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/stop_machine.c |    4 ----
 1 file changed, 4 deletions(-)

diff -puN kernel/stop_machine.c~kernel-stop_machinec-remove-config_smp-dependencies-fix kernel/stop_machine.c
--- a/kernel/stop_machine.c~kernel-stop_machinec-remove-config_smp-dependencies-fix
+++ a/kernel/stop_machine.c
@@ -531,8 +531,6 @@ static int __init cpu_stop_init(void)
 }
 early_initcall(cpu_stop_init);
 
-#ifdef CONFIG_HOTPLUG_CPU
-
 static int __stop_machine(cpu_stop_fn_t fn, void *data, const struct cpumask *cpus)
 {
 	struct multi_stop_data msdata = {
@@ -630,5 +628,3 @@ int stop_machine_from_inactive_cpu(cpu_s
 	mutex_unlock(&stop_cpus_mutex);
 	return ret ?: done.ret;
 }
-
-#endif	/* CONFIG_HOTPLUG_CPU */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
