Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 4DCDF6B01B1
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 14:34:08 -0500 (EST)
Received: by qadc16 with SMTP id c16so987908qad.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 11:34:07 -0800 (PST)
Message-ID: <4EE65729.9030706@gmail.com>
Date: Mon, 12 Dec 2011 14:34:01 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
References: <1323466526.27746.29.camel@joe2Laptop> <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com> <20111212132616.GB15249@tiehlicka.suse.cz> <20111212191531.GA23874@tiehlicka.suse.cz> <CAHGf_=o2C6YniR4+3FAVVZNYb+D=9brkdLgzoRVH95ppPQCgtQ@mail.gmail.com>
In-Reply-To: <CAHGf_=o2C6YniR4+3FAVVZNYb+D=9brkdLgzoRVH95ppPQCgtQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

(12/12/11 2:24 PM), KOSAKI Motohiro wrote:
>>> Why have you removed this guard? Previously we had pprev==NULL and
>>> returned mm->mmap.
>>> This seems like a semantic change without any explanation. Could you
>>> clarify?
>>
>> Scratch that. I have misread the code. find_vma will return mm->mmap if
>> the given address is bellow all vmas. Sorry about noise.
>>
>> The only concern left would be the caching. Are you sure this will not
>> break some workloads which benefit from mmap_cache usage and would
>> interfere with find_vma_prev callers now? Anyway this could be fixed
>> trivially.
>
> Here is callers list.
>
> find_vma_prev     115 arch/ia64/mm/fault.c      vma =
> find_vma_prev(mm, address,&prev_vma);
> find_vma_prev     183 arch/parisc/mm/fault.c    vma =
> find_vma_prev(mm, address,&prev_vma);
> find_vma_prev     229 arch/tile/mm/hugetlbpage.c                vma =
> find_vma_prev(mm, addr,&prev_vma);
> find_vma_prev     336 arch/x86/mm/hugetlbpage.c                 if
> (!(vma = find_vma_prev(mm, addr,&prev_vma)))
> find_vma_prev     388 mm/madvise.c      vma =
> find_vma_prev(current->mm, start,&prev);
> find_vma_prev     642 mm/mempolicy.c    vma = find_vma_prev(mm, start,&prev);
> find_vma_prev     388 mm/mlock.c        vma =
> find_vma_prev(current->mm, start,&prev);
> find_vma_prev     265 mm/mprotect.c     vma =
> find_vma_prev(current->mm, start,&prev);
>
> In short, find_find_prev() is only used from page fault, madvise, mbind, mlock
> and mprotect. And page fault is only performance impact callsite because other
> don't used frequently on regular workload.
>
> So, I wouldn't say, this patch has zero negative impact, but I think
> it is enough
> small and benefit is enough much.

In addition, other callsite (i.e. madvise, mbind, mlock and mprotect) are
used from syscall. then, an optimal behavior depend on syscall argument.
IOW, we and the kernel can't know it on ahead.

Therefore, this change may increase some applications performance a bit 
and may decrease another some applications. I can reasonably guess the
former are much than latter because many app have locality. but I can't
prove it.

Anyway, the impact is enough small, I think. They are rare than page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
