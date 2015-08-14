Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 795A86B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 20:56:38 -0400 (EDT)
Received: by obbhe7 with SMTP id he7so50626422obb.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 17:56:38 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id v4si2893408oif.133.2015.08.13.17.56.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 17:56:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [mmotm:master 301/497] include/linux/mm_types.h:371:22: error:
 'HUGE_MAX_HSTATE' undeclared here (not in a function)
Date: Fri, 14 Aug 2015 00:55:10 +0000
Message-ID: <20150814005510.GA6196@hori1.linux.bs1.fc.nec.co.jp>
References: <201508140757.EXwaVITo%fengguang.wu@intel.com>
In-Reply-To: <201508140757.EXwaVITo%fengguang.wu@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <ABF035A2A7467C49ACFAE2F055BAFAF3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Aug 14, 2015 at 07:43:58AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f6a6014bf6b3c724cff30194681f219ac230c898
> commit: b1e17e02f94bd2dec7547553e3cc5330f497193c [301/497] mm: hugetlb: p=
roc: add HugetlbPages field to /proc/PID/status
> config: sh-sh7785lcr_32bit_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/pla=
in/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout b1e17e02f94bd2dec7547553e3cc5330f497193c
>   # save the attached .config to linux build tree
>   make.cross ARCH=3Dsh=20
>=20
> All error/warnings (new ones prefixed by >>):
>=20
>    In file included from include/linux/mm.h:16:0,
>                     from arch/sh/kernel/asm-offsets.c:13:
> >> include/linux/mm_types.h:371:22: error: 'HUGE_MAX_HSTATE' undeclared h=
ere (not in a function)
>    make[2]: *** [arch/sh/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
>=20
> vim +/HUGE_MAX_HSTATE +371 include/linux/mm_types.h
>=20
>    365	struct mm_rss_stat {
>    366		atomic_long_t count[NR_MM_COUNTERS];
>    367	};
>    368=09
>    369	#ifdef CONFIG_HUGETLB_PAGE
>    370	struct hugetlb_usage {
>  > 371		atomic_long_t count[HUGE_MAX_HSTATE];

When HUGE_MAX_HSTATE is defined in arch-specific code, it's included before
including mm_types.h, so build passes. But if HUGE_MAX_HSTATE is defined in
common code, it's defined in hugetlb.h which is included after mm.h (or
mm_types.h), so this build error happens.

So the fix is simply to move the common definition into mm_types.h.

Thanks,
Naoya Horiguchi
---
Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date:   Fri Aug 14 09:35:21 2015 +0900

    move HUGE_MAX_HSTATE definition into include/linux/mm_types.h

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 64aa4db01f48..99ea2c651106 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -330,10 +330,6 @@ int __init alloc_bootmem_huge_page(struct hstate *h);
 void __init hugetlb_add_hstate(unsigned order);
 struct hstate *size_to_hstate(unsigned long size);
=20
-#ifndef HUGE_MAX_HSTATE
-#define HUGE_MAX_HSTATE 1
-#endif
-
 extern struct hstate hstates[HUGE_MAX_HSTATE];
 extern unsigned int default_hstate_idx;
=20
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e95c5fe1eb7d..27333cdb8b46 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -365,6 +365,10 @@ struct mm_rss_stat {
 };
=20
 #ifdef CONFIG_HUGETLB_PAGE
+
+#ifndef HUGE_MAX_HSTATE
+#define HUGE_MAX_HSTATE	1
+#endif
 struct hugetlb_usage {
 	atomic_long_t count[HUGE_MAX_HSTATE];
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
