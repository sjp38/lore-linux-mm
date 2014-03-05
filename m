Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 53F8D6B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 18:00:35 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1756545pab.13
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 15:00:34 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id pi6si1118209pbb.130.2014.03.05.15.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Mar 2014 15:00:33 -0800 (PST)
Message-ID: <5317AC8E.1060405@codeaurora.org>
Date: Wed, 05 Mar 2014 15:00:30 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [gbefb] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap()
References: <20140305133821.GA11657@localhost>
In-Reply-To: <20140305133821.GA11657@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <rmk@dyn-67.arm.linux.org.uk>

On 3/5/2014 5:38 AM, Fengguang Wu wrote:
> Greetings,
>
> I got the below dmesg and the first bad commit is
>
> commit c060f943d0929f3e429c5d9522290584f6281d6e
> Author:     Laura Abbott <lauraa@codeaurora.org>
> AuthorDate: Fri Jan 11 14:31:51 2013 -0800
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Fri Jan 11 14:54:55 2013 -0800
>
>      mm: use aligned zone start for pfn_to_bitidx calculation
>
>
> [    7.951495] gbefb: couldn't allocate framebuffer memory
> [    7.952974] ------------[ cut here ]------------
> [    7.952974] ------------[ cut here ]------------
> [    7.954307] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap+0x126/0x702()
>
> git bisect start v3.8 v3.7 --
> git bisect good 8d91a42e54eebc43f4d8f6064751ccba73528275  # 12:16     30+     10  Merge tag 'omap-late-cleanups' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
> git bisect  bad 910ffdb18a6408e14febbb6e4b6840fd2c928c82  # 12:21      0-     11  ptrace: introduce signal_wake_up_state() and ptrace_signal_wake_up()
> git bisect good bfbbd96c51b441b7a9a08762aa9ab832f6655b2c  # 12:29     30+     12  audit: fix auditfilter.c kernel-doc warnings
> git bisect  bad a6d3bd274b85218bf7dda925d14db81e1a8268b3  # 12:35      0-     22  Merge tag 'arm64-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64
> git bisect  bad 3441f0d26d02ec8073ea9ac7d1a4da8a9818ad59  # 12:41      0-      2  Merge tag 'driver-core-3.8-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
> git bisect  bad c727b4c63c9bf33c65351bbcc738161edb444b24  # 12:45      0-      4  Merge branch 'akpm' (incoming fixes from Andrew)
> git bisect good 47ecfcb7d01418fcbfbc75183ba5e28e98b667b2  # 12:54     30+     12  mm: compaction: Partially revert capture of suitable high-order page
> git bisect good 52b820d917c7c8c1b2ddec2f0ac165b67267feec  # 12:58     30+      9  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux
> git bisect good 93ccb3910ae3dbff6d224aecd22d8eece3d70ce9  # 13:01     30+     16  Merge tag 'nfs-for-3.8-3' of git://git.linux-nfs.org/projects/trondmy/linux-nfs
> git bisect  bad 1b963c81b14509e330e0fe3218b645ece2738dc5  # 13:08      0-      5  lockdep, rwsem: provide down_write_nest_lock()
> git bisect good c0232ae861df679092c15960b6cd9f589d9b7177  # 13:23     30+      9  mm: memblock: fix wrong memmove size in memblock_merge_regions()
> git bisect  bad c060f943d0929f3e429c5d9522290584f6281d6e  # 13:26      0-     10  mm: use aligned zone start for pfn_to_bitidx calculation
> git bisect good 6d92d4f6a74766cc885b18218268e0c47fbca399  # 13:31     30+      8  fs/exec.c: work around icc miscompilation
> # first bad commit: [c060f943d0929f3e429c5d9522290584f6281d6e] mm: use aligned zone start for pfn_to_bitidx calculation
> git bisect good 6d92d4f6a74766cc885b18218268e0c47fbca399  # 13:36     90+     52  fs/exec.c: work around icc miscompilation
> git bisect  bad 0964c4d936f53872725d96bb04d490a70aa1165a  # 13:37      0-     17  0day head guard for 'devel-hourly-2014022108'
> git bisect  bad dbf1b162bc9a01d93fa2d2ab3e8e064528575516  # 13:41     76-     14  Revert "mm: use aligned zone start for pfn_to_bitidx calculation"
> git bisect  bad d158fc7f36a25e19791d25a55da5623399a2644f  # 13:45      2-      7  Merge tag 'pci-v3.14-fixes-1' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
> git bisect  bad 12f1d94f0c8b256c04cb9b6b5dd989c32e44f11b  # 13:46      0-      8  Add linux-next specific files for 20140220
>
> Thanks,
> Fengguang
>


I'm not sure how much that tells you, that patch was known to have a bug 
which was fixed by 7c45512df987c5619db041b5c9b80d281e26d3db ( mm: fix 
pageblock bitmap allocation)

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
