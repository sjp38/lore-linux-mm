Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 11E316B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 10:42:44 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2fv1g2dRLh72gtaCYkNC6+Pp4h=R0q-taR51tejpL1gnw@mail.gmail.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-21-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2f2frTktfUusWGcaqZtTmQS8FSY0HqwXCas44EW7Q5Xsw@mail.gmail.com>
 <CACz4_2de=zm2-VtE=dFTfYjrdma4QFX1S-ukQ_7J4DZ32q1JQQ@mail.gmail.com>
 <CACz4_2fv1g2dRLh72gtaCYkNC6+Pp4h=R0q-taR51tejpL1gnw@mail.gmail.com>
Subject: Re: [PATCH 20/23] thp: handle file pages in split_huge_page()
Content-Transfer-Encoding: 7bit
Message-Id: <20130809144601.159CAE0090@blue.fi.intel.com>
Date: Fri,  9 Aug 2013 17:46:01 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> I just tried, and it seems working fine now without the deadlock anymore. I
> can run some big internal test with about 40GB files in sysv shm. Just move
> the line before the locking happens in vma_adjust, something as below, the
> line number is not accurate because my patch is based on another tree right
> now.

Looks okay to me. Could you prepare real patch (description, etc.). I'll
add it to my patchset.

> 
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -581,6 +581,8 @@ again:                      remove_next = 1 + (end >
> next->vm_end);
>                 }
>         }
> 
> +       vma_adjust_trans_huge(vma, start, end, adjust_next);
> +
>         if (file) {
>                 mapping = file->f_mapping;
>                 if (!(vma->vm_flags & VM_NONLINEAR))
> @@ -597,8 +599,6 @@ again:                      remove_next = 1 + (end >
> next->vm_end);
>                 }
>         }
> 
> -       vma_adjust_trans_huge(vma, start, end, adjust_next);
> -
>         anon_vma = vma->anon_vma;
>         if (!anon_vma && adjust_next)
>                 anon_vma = next->anon_vma;
> 
> 
> Best wishes,
> -- 
> Ning Qu (ae?2a(R)?) | Software Engineer | quning@google.com | +1-408-418-6066

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
