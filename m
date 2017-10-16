Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C14AE6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 11:01:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so7281965pgu.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:01:18 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q10si4584593pll.319.2017.10.16.08.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 08:01:17 -0700 (PDT)
Date: Mon, 16 Oct 2017 18:01:14 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [mmotm:master 112/209] mm/debug.c:137:21: warning: passing
 argument 1 of 'mm_pgtables_bytes' discards 'const' qualifier from pointer
 target type
Message-ID: <20171016150113.ikfxy3e7zzfvsr4w@black.fi.intel.com>
References: <201710141547.41n3nN1Y%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710141547.41n3nN1Y%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Oct 14, 2017 at 07:38:55AM +0000, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   cc4a10c92b384ba2b80393c37639808df0ebbf56
> commit: ae7f37f07ee1eb08dd1eaaf79182ce9aa6ef7c09 [112/209] mm: consolidate page table accounting
> config: blackfin-allmodconfig (attached as .config)
> compiler: bfin-uclinux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout ae7f37f07ee1eb08dd1eaaf79182ce9aa6ef7c09
>         # save the attached .config to linux build tree
>         make.cross ARCH=blackfin 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/kernel.h:13:0,
>                     from mm/debug.c:8:
>    mm/debug.c: In function 'dump_mm':
> >> mm/debug.c:137:21: warning: passing argument 1 of 'mm_pgtables_bytes' discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
>       mm_pgtables_bytes(mm),
>                         ^
>    include/linux/printk.h:295:35: note: in definition of macro 'pr_emerg'
>      printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
>                                       ^~~~~~~~~~~
>    In file included from mm/debug.c:9:0:
>    include/linux/mm.h:1671:29: note: expected 'struct mm_struct *' but argument is of type 'const struct mm_struct *'
>     static inline unsigned long mm_pgtables_bytes(struct mm_struct *mm)

Andrew, could you please take this fixup:

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a7e50c464021..d3c4b1f19da4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1668,7 +1668,7 @@ static inline void mm_dec_nr_ptes(struct mm_struct *mm)
 #else
 
 static inline void mm_pgtables_bytes_init(struct mm_struct *mm) {}
-static inline unsigned long mm_pgtables_bytes(struct mm_struct *mm)
+static inline unsigned long mm_pgtables_bytes(const struct mm_struct *mm)
 {
 	return 0;
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
