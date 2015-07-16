Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 44D902802FF
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:06:49 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so56517146qkd.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:06:49 -0700 (PDT)
Date: Thu, 16 Jul 2015 21:05:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [mmotm:master 140/321] fs/built-in.o:undefined reference to
	`filemap_page_mkwrite'
Message-ID: <20150716190503.GA22146@redhat.com>
References: <201507160919.VRGXvreQ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507160919.VRGXvreQ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Benjamin LaHaise <bcrl@kvack.org>, Jeff Moyer <jmoyer@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Thanks!

On 07/16, kbuild test robot wrote:
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   6102e3c755ac0084fdce65f69a7a149fc51a8a86
> commit: db5e4748f77b7cefa37e61324cc440f8670213c2 [140/321] mm: move ->mremap() from file_operations to vm_operations_struct
> config: sh-rsk7269_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout db5e4748f77b7cefa37e61324cc440f8670213c2
>   # save the attached .config to linux build tree
>   make.cross ARCH=sh

doesn't work for me...

> All error/warnings (new ones prefixed by >>):
>
> >> fs/built-in.o:(.rodata+0x1090): undefined reference to `filemap_page_mkwrite'

but the problem looks clear: CONFIG_MMU is not set, so we need
a dummy filemap_page_mkwrite() along with generic_file_mmap() and
generic_file_readonly_mmap().

I'll send the fix, but...

Benjamin, Jeff, shouldn't AIO depend on MMU? Or it can actually work even
if CONFIG_MMU=n?

Oleg.

--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1558,6 +1558,7 @@ config SHMEM
 
 config AIO
 	bool "Enable AIO support" if EXPERT
+	depends on MMU
 	default y
 	help
 	  This option enables POSIX asynchronous I/O which may by used

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
