Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C8BDB6B00B3
	for <linux-mm@kvack.org>; Wed, 22 May 2013 08:56:24 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id g12so2533158oah.12
        for <linux-mm@kvack.org>; Wed, 22 May 2013 05:56:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 22 May 2013 20:56:23 +0800
Message-ID: <CAJd=RBB-LdPFpC-V07FYKEH7OXMwDgVr4RASqcrvPmcaKv+P5w@mail.gmail.com>
Subject: Re: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> @@ -3316,17 +3361,25 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>                 if (unlikely(anon_vma_prepare(vma)))
>                         return VM_FAULT_OOM;
>
> -               cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +               cow_page = alloc_fault_page_vma(vma, address, flags);
>                 if (!cow_page)
> -                       return VM_FAULT_OOM;
> +                       return VM_FAULT_OOM | VM_FAULT_FALLBACK;
>

Fallback makes sense with !thp ?

>                 if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
>                         page_cache_release(cow_page);
> -                       return VM_FAULT_OOM;
> +                       return VM_FAULT_OOM | VM_FAULT_FALLBACK;
>                 }
>         } else
>                 cow_page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
