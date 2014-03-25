Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD88F6B0069
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 22:28:40 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so6163165pdj.9
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 19:28:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zm8si10486846pac.358.2014.03.24.19.28.39
        for <linux-mm@kvack.org>;
        Mon, 24 Mar 2014 19:28:39 -0700 (PDT)
Date: Tue, 25 Mar 2014 10:28:33 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 463/499] mm/mprotect.c:46:14: sparse: context
 imbalance in 'lock_pte_protection' - different lock contexts for basic block
Message-ID: <20140325022833.GA19661@localhost>
References: <532e4cc1.umGiNE2YJiL9Z2iq%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1403241559390.29809@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1403241559390.29809@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Mon, Mar 24, 2014 at 04:00:32PM -0500, Christoph Lameter wrote:
> On Sun, 23 Mar 2014, kbuild test robot wrote:
> 
> > >> mm/mprotect.c:46:14: sparse: context imbalance in 'lock_pte_protection' - different lock contexts for basic block
> > >> arch/x86/include/asm/paravirt.h:699:9: sparse: context imbalance in 'change_pte_range' - unexpected unlock
> > --
> > >> fs/ntfs/super.c:3100:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3102:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3104:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3105:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3107:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3108:1: sparse: directive in argument list
> > >> fs/ntfs/super.c:3110:1: sparse: directive in argument list
> 
> Looked through these and I am a bit puzzled how they related to raw cpu
> ops patch.

Ah yes, this is false positive and is because the compilation on the
previous commit failed, so the sparse errors in fs/ntfs/super.c show
up as "new" ones in commit 6a9ad050.

wfg@bee ~/linux% git checkout 6a9ad050c521ac607a30a691042f2a5d24109b07~
...
HEAD is now at 1b1dc6d... arm: move arm_dma_limit to setup_dma_zone

wfg@bee ~/linux/obj-compiletest% make C=1 fs/ntfs/super.o
...
  HOSTLD  scripts/mod/modpost
In file included from /c/wfg/linux/include/linux/mm.h:897:0,
                 from /c/wfg/linux/include/linux/suspend.h:8,
                 from /c/wfg/linux/arch/x86/kernel/asm-offsets.c:12:
/c/wfg/linux/include/linux/vmstat.h: In function a??__count_vm_eventa??:
/c/wfg/linux/include/linux/vmstat.h:36:2: error: implicit declaration of function a??raw_cpu_inca?? [-Werror=implicit-function-declaration]
/c/wfg/linux/include/linux/vmstat.h: In function a??__count_vm_eventsa??:
/c/wfg/linux/include/linux/vmstat.h:46:2: error: implicit declaration of function a??raw_cpu_adda?? [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors
make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
make[1]: *** [prepare0] Error 2
make: *** [sub-make] Error 2
make: Leaving directory `/c/wfg/linux'

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
