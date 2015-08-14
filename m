Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 65CA36B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 06:28:46 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so14031941pac.1
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 03:28:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pw17si7503404pab.79.2015.08.14.03.28.45
        for <linux-mm@kvack.org>;
        Fri, 14 Aug 2015 03:28:45 -0700 (PDT)
Date: Fri, 14 Aug 2015 18:31:20 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 7943/8276] mm/early_ioremap.c:235:31: sparse:
 incorrect type in argument 1 (different address spaces)
Message-ID: <201508141818.9mVfllP2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   84db9c17966188a15e1f2266e6ef80b353114c21
commit: 37c651e39edd43099b840daeed4ccf3331ba8def [7943/8276] mm: add utility for early copy from unmapped ram
reproduce:
  # apt-get install sparse
  git checkout 37c651e39edd43099b840daeed4ccf3331ba8def
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/early_ioremap.c:235:31: sparse: incorrect type in argument 1 (different address spaces)
   mm/early_ioremap.c:235:31:    expected void [noderef] <asn:2>*addr
   mm/early_ioremap.c:235:31:    got char *[assigned] p

vim +235 mm/early_ioremap.c

   219	}
   220	
   221	#define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
   222	
   223	void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
   224	{
   225		unsigned long slop, clen;
   226		char *p;
   227	
   228		while (size) {
   229			slop = src & ~PAGE_MASK;
   230			clen = size;
   231			if (clen > MAX_MAP_CHUNK - slop)
   232				clen = MAX_MAP_CHUNK - slop;
   233			p = early_memremap(src & PAGE_MASK, clen + slop);
   234			memcpy(dest, p + slop, clen);
 > 235			early_iounmap(p, clen + slop);
   236			dest += clen;
   237			src += clen;
   238			size -= clen;
   239		}
   240	}
   241	
   242	#else /* CONFIG_MMU */
   243	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
