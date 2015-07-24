Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBEA9003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 05:35:52 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so20582491wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 02:35:51 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id j8si13785161wjn.105.2015.07.24.02.35.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 02:35:50 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so19825114wib.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 02:35:50 -0700 (PDT)
Date: Fri, 24 Jul 2015 12:35:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mmotm:master 371/385] mm/nommu.c:1248:30: error: 'vm_flags'
 redeclared as different kind of symbol
Message-ID: <20150724093546.GA22732@node.dhcp.inet.fi>
References: <201507240605.wGSz9Yxl%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507240605.wGSz9Yxl%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 06:46:09AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
> commit: b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73 [371/385] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
> config: microblaze-nommu_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73
>   # save the attached .config to linux build tree
>   make.cross ARCH=microblaze 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/nommu.c: In function 'do_mmap':
> >> mm/nommu.c:1248:30: error: 'vm_flags' redeclared as different kind of symbol
>      unsigned long capabilities, vm_flags, result;
>                                  ^
>    mm/nommu.c:1241:15: note: previous definition of 'vm_flags' was here
>        vm_flags_t vm_flags,
>                   ^
> 

This should fix the issue:

diff --git a/mm/nommu.c b/mm/nommu.c
index 530eea5af989..af2196e35013 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1245,7 +1245,7 @@ unsigned long do_mmap(struct file *file,
        struct vm_area_struct *vma;
        struct vm_region *region;
        struct rb_node *rb;
-       unsigned long capabilities, vm_flags, result;
+       unsigned long capabilities, result;
        int ret;
 
        *populate = 0;
@@ -1263,7 +1263,7 @@ unsigned long do_mmap(struct file *file,
 
        /* we've determined that we can make the mapping, now translate what we
         * now know into VMA flags */
-       vm_flags = determine_vm_flags(file, prot, flags, capabilities);
+       vm_flags |= determine_vm_flags(file, prot, flags, capabilities);
 
        /* we're going to need to record the mapping */
        region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
