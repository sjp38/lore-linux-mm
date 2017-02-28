Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63BA76B0391
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:07:03 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 40so5803260uau.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 01:07:03 -0800 (PST)
Received: from mail-ua0-x22d.google.com (mail-ua0-x22d.google.com. [2607:f8b0:400c:c08::22d])
        by mx.google.com with ESMTPS id s4si436906uae.224.2017.02.28.01.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 01:07:02 -0800 (PST)
Received: by mail-ua0-x22d.google.com with SMTP id 72so6401713uaf.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 01:07:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170228031227.tm7flsxl7t7klspf@wfg-t540p.sh.intel.com>
References: <20170228031227.tm7flsxl7t7klspf@wfg-t540p.sh.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Feb 2017 10:06:41 +0100
Message-ID: <CACT4Y+YJQ8jdiFKnrESuw433QWpm7BMLvoKNm5gtN7YRWpRA4g@mail.gmail.com>
Subject: Re: [mm/kasan] 80a9201a59 BUG: kernel reboot-without-warning in
 early-boot stage, last printk: Booting the kernel.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>

On Tue, Feb 28, 2017 at 4:12 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Hi Alexander,
>
> FYI, we find an old bug that's still alive in linux-next. The attached
> reproduce-* script may help debug the problem.


Hi Fengguang,

KASAN works fine for us all that time in qemu and on real machines. Do
you have any idea as to what's relevant to the hang in all these qemu
flags and command line flags? One idea is that 512MB may not be enough
for KASAN. Does increasing amount of memory help?


> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>
> commit 80a9201a5965f4715d5c09790862e0df84ce0614
> Author:     Alexander Potapenko <glider@google.com>
> AuthorDate: Thu Jul 28 15:49:07 2016 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Thu Jul 28 16:07:41 2016 -0700
>
>      mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
>
>      For KASAN builds:
>       - switch SLUB allocator to using stackdepot instead of storing the
>         allocation/deallocation stacks in the objects;
>       - change the freelist hook so that parts of the freelist can be put
>         into the quarantine.
>
>      [aryabinin@virtuozzo.com: fixes]
>        Link: http://lkml.kernel.org/r/1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com
>      Link: http://lkml.kernel.org/r/1468347165-41906-3-git-send-email-glider@google.com
>      Signed-off-by: Alexander Potapenko <glider@google.com>
>      Cc: Andrey Konovalov <adech.fo@gmail.com>
>      Cc: Christoph Lameter <cl@linux.com>
>      Cc: Dmitry Vyukov <dvyukov@google.com>
>      Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
>      Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>      Cc: Kostya Serebryany <kcc@google.com>
>      Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>      Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>      Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> c146a2b98e  mm, kasan: account for object redzone in SLUB's nearest_obj()
> 80a9201a59  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
> +--------------------------------------------------------------------------------------+------------+------------+
> |                                                                                      | c146a2b98e | 80a9201a59 |
> +--------------------------------------------------------------------------------------+------------+------------+
> | boot_successes                                                                       | 740        | 48         |
> | boot_failures                                                                        | 0          | 142        |
> | BUG:kernel_reboot-without-warning_in_early-boot_stage,last_printk:Booting_the_kernel | 0          | 131        |
> | BUG:kernel_in_stage                                                                  | 0          | 11         |
> +--------------------------------------------------------------------------------------+------------+------------+
>
>
> Decompressing Linux... Parsing ELF... done.
> Booting the kernel.
>
>
> git bisect start v4.8 v4.7 --
> git bisect  bad e6e7214fbbdab1f90254af68e0927bdb24708d22  # 20:07      0-      1  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect  bad ba929b6646c5b87c7bb15cd8d3e51617725c983b  # 21:11      0-      2  Merge branch 'for-linus-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
> git bisect good 5f22004ba9b4cf740773777ea7b74586743f6051  # 22:41    190+      0  Merge branch 'x86-timers-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect good 124a3d88fa20e1869fc229d7d8c740cc81944264  # 23:01    182+      0  Disable "frame-address" warning
> git bisect  bad 20d00ee829428ea6aab77fa3acca048a6f57d3bc  # 23:35      0-      1  Revert "vfs: add lookup_hash() helper"
> git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 00:20    183+      0  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vkoul/slave-dma
> git bisect  bad e55884d2c6ac3ae50e49a1f6fe38601a91181719  # 00:53      0-      3  Merge tag 'vfio-v4.8-rc1' of git://github.com/awilliam/linux-vfio
> git bisect  bad d94ba9e7d8d5c821d0442f13b30b0140c1109c38  # 01:46      0-      2  Merge tag 'pinctrl-v4.8-1' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl
> git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 01:58      0-      1  Merge branch 'akpm' (patches from Andrew)
> git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 03:16    181+      0  mm, vmstat: remove zone and node double accounting by approximating retries
> git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 08:58    190+      0  mm: fix memcg stack accounting for sub-page stacks
> git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 11:50    183+      0  mm/memblock.c: fix index adjustment error in __next_mem_range_rev()
> git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 12:09      0-      2  mm, page_alloc: set alloc_flags only once in slowpath
> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 12:51    180+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
> git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 13:19      0-      1  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
> git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 13:34      0-      1  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
> # first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 15:16    550+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
> # extra tests on HEAD of linux-devel/devel-spot-201702260211
> git bisect  bad 494b6947f72e0d28eb229387a0dc27e95d79b605  # 15:16      0-     15  0day head guard for 'devel-spot-201702260211'
> # extra tests on tree/branch linus/master
> git bisect  bad e5d56efc97f8240d0b5d66c03949382b6d7e5570  # 15:28      0-      1  Merge tag 'watchdog-for-linus-v4.11' of git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging
> # extra tests on tree/branch linux-next/master
> git bisect  bad ed7b11e565c736828f0b793f596a4ca20efee747  # 15:40      0-      3  Add linux-next specific files for 20170227
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20170228031227.tm7flsxl7t7klspf%40wfg-t540p.sh.intel.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
