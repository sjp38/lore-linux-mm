Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 3201A6B01AE
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 14:25:05 -0500 (EST)
Received: by ghbf13 with SMTP id f13so500462ghb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 11:25:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111212191531.GA23874@tiehlicka.suse.cz>
References: <1323466526.27746.29.camel@joe2Laptop> <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
 <20111212132616.GB15249@tiehlicka.suse.cz> <20111212191531.GA23874@tiehlicka.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 12 Dec 2011 14:24:43 -0500
Message-ID: <CAHGf_=o2C6YniR4+3FAVVZNYb+D=9brkdLgzoRVH95ppPQCgtQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

>> Why have you removed this guard? Previously we had pprev==NULL and
>> returned mm->mmap.
>> This seems like a semantic change without any explanation. Could you
>> clarify?
>
> Scratch that. I have misread the code. find_vma will return mm->mmap if
> the given address is bellow all vmas. Sorry about noise.
>
> The only concern left would be the caching. Are you sure this will not
> break some workloads which benefit from mmap_cache usage and would
> interfere with find_vma_prev callers now? Anyway this could be fixed
> trivially.

Here is callers list.

find_vma_prev     115 arch/ia64/mm/fault.c      vma =
find_vma_prev(mm, address, &prev_vma);
find_vma_prev     183 arch/parisc/mm/fault.c    vma =
find_vma_prev(mm, address, &prev_vma);
find_vma_prev     229 arch/tile/mm/hugetlbpage.c                vma =
find_vma_prev(mm, addr, &prev_vma);
find_vma_prev     336 arch/x86/mm/hugetlbpage.c                 if
(!(vma = find_vma_prev(mm, addr, &prev_vma)))
find_vma_prev     388 mm/madvise.c      vma =
find_vma_prev(current->mm, start, &prev);
find_vma_prev     642 mm/mempolicy.c    vma = find_vma_prev(mm, start, &prev);
find_vma_prev     388 mm/mlock.c        vma =
find_vma_prev(current->mm, start, &prev);
find_vma_prev     265 mm/mprotect.c     vma =
find_vma_prev(current->mm, start, &prev);

In short, find_find_prev() is only used from page fault, madvise, mbind, mlock
and mprotect. And page fault is only performance impact callsite because other
don't used frequently on regular workload.

So, I wouldn't say, this patch has zero negative impact, but I think
it is enough
small and benefit is enough much.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
