Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E232C6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:07:41 -0400 (EDT)
Date: Tue, 02 Apr 2013 10:07:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364911655-wel87i2g-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CABOkKT0uceznvR0bKx79GB5HSEbWA2vp0G5dAjg6V23O3anS7w@mail.gmail.com>
References: <1364836882-9713-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364836882-9713-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CABOkKT0uceznvR0bKx79GB5HSEbWA2vp0G5dAjg6V23O3anS7w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] hugetlbfs: stop setting VM_DONTDUMP in
 initializing vma(VM_HUGETLB)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Apr 02, 2013 at 08:32:33PM +0900, HATAYAMA Daisuke wrote:
> 2013/4/2 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> > Currently we fail to include any data on hugepages into coredump,
> > because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> > introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> > mm->reserved_vm counter". This looks to me a serious regression,
> > so let's fix it.
> >
> > ChangeLog v2:
> >  - add 'return 0' in hugepage memory check
> >
> <cut>
> 
> > @@ -1137,6 +1137,7 @@ static unsigned long vma_dump_size(struct
> > vm_area_struct *vma,
> >                         goto whole;
> >                 if (!(vma->vm_flags & VM_SHARED) &&
> > FILTER(HUGETLB_PRIVATE))
> >                         goto whole;
> > +               return 0;
> >         }
> >
> 
> You should split this part into another patch. This fix is orthogonal to
> the bug this patch tries to fix.

Fair enough, thanks.

> The bug you're trying to fix implicitly here is the filtering behaviour
> that doesn't follow
> the description in Documentation/filesystems/proc.txt that:
> 
>   Note bit 0-4 doesn't effect any hugetlb memory. hugetlb memory are only
>   effected by bit 5-6.
> 
> Right?

Right. Without this return, we will go into the subsequent flag checks
of bit 0-4 for vma(VM_HUGETLB).

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
