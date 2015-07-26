Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id BF3C36B0253
	for <linux-mm@kvack.org>; Sun, 26 Jul 2015 09:57:29 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so31811134qkb.2
        for <linux-mm@kvack.org>; Sun, 26 Jul 2015 06:57:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 107si17309981qge.122.2015.07.26.06.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jul 2015 06:57:28 -0700 (PDT)
Date: Sun, 26 Jul 2015 15:57:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [mmotm:master 371/385] mm/nommu.c:1248:30: error: 'vm_flags'
 redeclared as different kind of symbol
Message-ID: <20150726135721.GA23533@redhat.com>
References: <201507240605.wGSz9Yxl%fengguang.wu@intel.com>
 <20150724093546.GA22732@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150724093546.GA22732@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Gortmaker <paul.gortmaker@windriver.com>

Oh. I am really sorry. I broke NOMMU again, and this time I was really stupid.

And thanks a lot Kirill!

I am travelling till the end of the next week, can't be responsive until I return :/



On 07/24, Kirill A. Shutemov wrote:
>
> On Fri, Jul 24, 2015 at 06:46:09AM +0800, kbuild test robot wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
> > commit: b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73 [371/385] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
> > config: microblaze-nommu_defconfig (attached as .config)
> > reproduce:
> >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >   chmod +x ~/bin/make.cross
> >   git checkout b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73
> >   # save the attached .config to linux build tree
> >   make.cross ARCH=microblaze 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    mm/nommu.c: In function 'do_mmap':
> > >> mm/nommu.c:1248:30: error: 'vm_flags' redeclared as different kind of symbol
> >      unsigned long capabilities, vm_flags, result;
> >                                  ^
> >    mm/nommu.c:1241:15: note: previous definition of 'vm_flags' was here
> >        vm_flags_t vm_flags,
> >                   ^
> > 
> 
> This should fix the issue:
> 
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 530eea5af989..af2196e35013 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1245,7 +1245,7 @@ unsigned long do_mmap(struct file *file,
>         struct vm_area_struct *vma;
>         struct vm_region *region;
>         struct rb_node *rb;
> -       unsigned long capabilities, vm_flags, result;
> +       unsigned long capabilities, result;
>         int ret;
>  
>         *populate = 0;
> @@ -1263,7 +1263,7 @@ unsigned long do_mmap(struct file *file,
>  
>         /* we've determined that we can make the mapping, now translate what we
>          * now know into VMA flags */
> -       vm_flags = determine_vm_flags(file, prot, flags, capabilities);
> +       vm_flags |= determine_vm_flags(file, prot, flags, capabilities);
>  
>         /* we're going to need to record the mapping */
>         region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL);
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
