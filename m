Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC64E6B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 16:00:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r81-v6so4058264pfk.11
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 13:00:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m16-v6si2220841pgd.48.2018.10.03.13.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Oct 2018 13:00:50 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:00:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Message-ID: <20181003200003.GA9965@bombadil.infradead.org>
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux@armlinux.org.uk, miguel.ojeda.sandonis@gmail.com, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, m.szyprowski@samsung.com, keescook@chromium.org, treding@nvidia.com, mhocko@suse.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, mark.rutland@arm.com, aryabinin@virtuozzo.com, dvyukov@google.com, kstewart@linuxfoundation.org, tchibo@google.com, riel@redhat.com, minchan@kernel.org, peterz@infradead.org, ying.huang@intel.com, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, arnd@arndb.de, cpandya@codeaurora.org, hannes@cmpxchg.org, joe@perches.com, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, linux-mm@kvack.org

On Thu, Oct 04, 2018 at 12:28:54AM +0530, Souptick Joarder wrote:
> These are the approaches which could have been taken to handle
> this scenario -
> 
> *  Replace vm_insert_page with vmf_insert_page and then write few
>    extra lines of code to convert VM_FAULT_CODE to errno which
>    makes driver users more complex ( also the reverse mapping errno to
>    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
>    not preferred to introduce anything similar again)
> 
> *  Maintain both vm_insert_page and vmf_insert_page and use it in
>    respective places. But it won't gurantee that vm_insert_page will
>    never be used in #PF context.
> 
> *  Introduce a similar API like vm_insert_page, convert all non #PF
>    consumer to use it and finally remove vm_insert_page by converting
>    it to vmf_insert_page.
> 
> And the 3rd approach was taken by introducing vm_insert_kmem_page().
> 
> In short, vmf_insert_page will be used in page fault handlers
> context and vm_insert_kmem_page will be used to map kernel
> memory to user vma outside page fault handlers context.

As far as I can tell, vm_insert_kmem_page() is line-for-line identical
with vm_insert_page().  Seriously, here's a diff I just did:

-static int insert_page(struct vm_area_struct *vma, unsigned long addr,
-                       struct page *page, pgprot_t prot)
+static int insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
+               struct page *page, pgprot_t prot)
-       /* Ok, finally just insert the thing.. */
-int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
+int vm_insert_kmem_page(struct vm_area_struct *vma, unsigned long addr,
-       return insert_page(vma, addr, page, vma->vm_page_prot);
+       return insert_kmem_page(vma, addr, page, vma->vm_page_prot);
-EXPORT_SYMBOL(vm_insert_page);
+EXPORT_SYMBOL(vm_insert_kmem_page);

What on earth are you trying to do?
