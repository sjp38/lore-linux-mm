Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDA06B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 09:46:50 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n23-v6so15092602otl.2
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 06:46:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12-v6sor720203oic.154.2018.10.01.06.46.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 06:46:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180929013611.163130-1-jannh@google.com> <201809291116.emGRuKoB%fengguang.wu@intel.com>
In-Reply-To: <201809291116.emGRuKoB%fengguang.wu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 1 Oct 2018 15:46:22 +0200
Message-ID: <CAG48ez1kXs9_YZkqFJUpoLTH9DdLOd614NJJ+adgmh7rbGZcqQ@mail.gmail.com>
Subject: Re: [PATCH] mm/vmstat: fix outdated vmstat_text
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkp@intel.com
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, guro@fb.com, kemi.wang@intel.com, Kees Cook <keescook@chromium.org>, Christopher Lameter <cl@linux.com>

On Sat, Sep 29, 2018 at 5:07 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Jann,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.19-rc5 next-20180928]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Jann-Horn/mm-vmstat-fix-outdated-vmstat_text/20180929-102147
> config: i386-randconfig-x005-201838 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from include/linux/export.h:45:0,
>                     from include/linux/linkage.h:7,
>                     from include/linux/fs.h:5,
>                     from mm/vmstat.c:12:
>    mm/vmstat.c: In function 'vmstat_start':
> >> include/linux/compiler.h:358:38: error: call to '__compiletime_assert_1664' declared with attribute error: BUILD_BUG_ON failed: stat_items_size != ARRAY_SIZE(vmstat_text) * sizeof(unsigned long)

Nice. Looks like the 0day test bot indeed found another mismatch:

#ifdef CONFIG_DEBUG_TLBFLUSH
#ifdef CONFIG_SMP
       "nr_tlb_remote_flush",
       "nr_tlb_remote_flush_received",
#endif /* CONFIG_SMP */
       "nr_tlb_local_flush_all",
       "nr_tlb_local_flush_one",
#endif /* CONFIG_DEBUG_TLBFLUSH */

vs

#ifdef CONFIG_DEBUG_TLBFLUSH
               NR_TLB_REMOTE_FLUSH,    /* cpu tried to flush others' tlbs */
               NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
               NR_TLB_LOCAL_FLUSH_ALL,
               NR_TLB_LOCAL_FLUSH_ONE,
#endif /* CONFIG_DEBUG_TLBFLUSH */

So if you build with CONFIG_VM_EVENT_COUNTERS=y &&
CONFIG_DEBUG_TLBFLUSH=y && CONFIG_SMP=n, vmstat output is bogus.

I like having my decisions to add asserts immediately validated by the
0day test bot. ^^

I'll send a v2 with that fixed up.
