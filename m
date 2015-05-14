Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E19F86B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 15:52:30 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so99456229pdb.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 12:52:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pj8si22881186pdb.46.2015.05.14.12.52.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 12:52:29 -0700 (PDT)
Date: Thu, 14 May 2015 12:52:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 120/255] include/asm-generic/pgtable.h:206:2:
 warning: (near initialization for '(anonymous).pmd')
Message-Id: <20150514125228.4acd45b5576d7109de10fe17@linux-foundation.org>
In-Reply-To: <201505141007.XJqGCdko%fengguang.wu@intel.com>
References: <201505141007.XJqGCdko%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 14 May 2015 10:20:08 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   e55a38145ac0946f090895afc5c8ba0717790908
> commit: add8ee4dd125729fb48d5cc73b194f28f1a6eccb [120/255] mm/thp: split out pmd collapse/flush into separate functions
> config: m68k-multi_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout add8ee4dd125729fb48d5cc73b194f28f1a6eccb
>   # save the attached .config to linux build tree
>   make.cross ARCH=m68k 
> 
> All warnings:
> 
>    In file included from arch/m68k/include/asm/pgtable_mm.h:172:0,
>                     from arch/m68k/include/asm/pgtable.h:4,
>                     from include/linux/mm.h:53,
>                     from include/linux/scatterlist.h:6,
>                     from include/linux/dmaengine.h:24,
>                     from include/linux/netdevice.h:38,
>                     from net/batman-adv/main.h:168,
>                     from net/batman-adv/bat_iv_ogm.c:18:
>    include/asm-generic/pgtable.h: In function 'pmdp_collapse_flush':
>    include/asm-generic/pgtable.h:206:2: warning: missing braces around initializer [-Wmissing-braces]
>      return __pmd(0);

hm, yes, there is no requirement for the architecture to implement
__pmd() and it shouldn't be used in include/linux.

Will this work?

--- a/include/asm-generic/pgtable.h~mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions-fix-2
+++ a/include/asm-generic/pgtable.h
@@ -203,7 +203,7 @@ static inline pmd_t pmdp_collapse_flush(
 					pmd_t *pmdp)
 {
 	BUILD_BUG();
-	return __pmd(0);
+	return *pmdp;
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
