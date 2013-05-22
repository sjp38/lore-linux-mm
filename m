Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 077126B00D8
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:11:36 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBB-LdPFpC-V07FYKEH7OXMwDgVr4RASqcrvPmcaKv+P5w@mail.gmail.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBB-LdPFpC-V07FYKEH7OXMwDgVr4RASqcrvPmcaKv+P5w@mail.gmail.com>
Subject: Re: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130522151401.E69EDE0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 18:14:01 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > @@ -3316,17 +3361,25 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >                 if (unlikely(anon_vma_prepare(vma)))
> >                         return VM_FAULT_OOM;
> >
> > -               cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> > +               cow_page = alloc_fault_page_vma(vma, address, flags);
> >                 if (!cow_page)
> > -                       return VM_FAULT_OOM;
> > +                       return VM_FAULT_OOM | VM_FAULT_FALLBACK;
> >
> 
> Fallback makes sense with !thp ?

No, it's nop. handle_pte_fault() will notice only VM_FAULT_OOM. That's
what we need.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
