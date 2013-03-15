Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B8AFE6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 03:44:51 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id n12so3088592oag.27
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 00:44:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-26-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-26-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 15:44:50 +0800
Message-ID: <CAJd=RBBPdKfc7i5bkMAzOTtyfUX2FrbYgRAc2c45D04AhZv+eg@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 25/30] thp, mm: basic huge_fault implementation for generic_file_vm_ops
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static int filemap_huge_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +       struct file *file = vma->vm_file;
> +       struct address_space *mapping = file->f_mapping;
> +       struct inode *inode = mapping->host;
> +       pgoff_t size, offset = vmf->pgoff;
> +       unsigned long address = (unsigned long) vmf->virtual_address;
> +       struct page *page;
> +       int ret = 0;
> +
> +       BUG_ON(((address >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
> +                       (offset & HPAGE_CACHE_INDEX_MASK));
> +
> +retry:
> +       page = find_get_page(mapping, offset);
> +       if (!page) {
> +               gfp_t gfp_mask = mapping_gfp_mask(mapping) | __GFP_COLD;
> +               page = alloc_pages(gfp_mask, HPAGE_PMD_ORDER);
s/pages/pages_vma/ ?

> +               if (!page) {
> +                       count_vm_event(THP_FAULT_FALLBACK);
> +                       return VM_FAULT_OOM;
> +               }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
