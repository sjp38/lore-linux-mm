Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0656B0039
	for <linux-mm@kvack.org>; Thu, 29 May 2014 05:06:26 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so53387pbc.26
        for <linux-mm@kvack.org>; Thu, 29 May 2014 02:06:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tu2si23075pbc.173.2014.05.29.02.06.24
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 02:06:25 -0700 (PDT)
Date: Thu, 29 May 2014 02:04:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: dont call mmu_notifier_invalidate_page during
 munlock
Message-Id: <20140529020443.974b0d1b.akpm@linux-foundation.org>
In-Reply-To: <CALYGNiN4v4b_AJW10wVyy1XnapzwLk8Pod89sb3E-b3c81SoVw@mail.gmail.com>
References: <20140528075955.20300.22758.stgit@zurg>
	<20140528160948.489fde6e0285885d13f7c656@linux-foundation.org>
	<CALYGNiN4v4b_AJW10wVyy1XnapzwLk8Pod89sb3E-b3c81SoVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 29 May 2014 11:19:27 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> On Thu, May 29, 2014 at 3:09 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 28 May 2014 11:59:55 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> >
> >> try_to_munlock() searches other mlocked vmas, it never unmaps pages.
> >> There is no reason for invalidation because ptes are left unchanged.
> >>
> >> ...
> >>
> >> --- a/mm/rmap.c
> >> +++ b/mm/rmap.c
> >> @@ -1225,7 +1225,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >>
> >>  out_unmap:
> >>       pte_unmap_unlock(pte, ptl);
> >> -     if (ret != SWAP_FAIL)
> >> +     if (ret != SWAP_FAIL && TTU_ACTION(flags) != TTU_MUNLOCK)
> >>               mmu_notifier_invalidate_page(mm, address);
> >>  out:
> >>       return ret;
> >
> > The patch itself looks reasonable but there is no such thing as
> > try_to_munlock().  I rewrote the changelog thusly:
> 
> Wait, what? I do have function with this name in my sources. It calls rmap_walk
> with callback try_to_unmap_one and action TTU_MUNLOCK. This is the place
> where TTU_MUNLOCK is used, I've mentioned it as entry point of this logic.

Ah OK, I obviously misgrepped.

> >
> > : In its munmap mode, try_to_unmap_one() searches other mlocked vmas, it
> > : never unmaps pages.  There is no reason for invalidation because ptes are
> > : left unchanged.
> >
> > Also, the name try_to_unmap_one() is now pretty inaccurate/incomplete.
> > Perhaps if someone is feeling enthusiastic they might think up a better
> > name for the various try_to_unmap functions and see if we can
> > appropriately document try_to_unmap_one().
> 
> I thought about moving mlock part out of try_to_unmap_one() into
> separate function,
> but normal unmap needs this part too...

try_to_unmap_one() does appear to have enough in common with the
munlock operation to justify using common code.  But doing so makes the
name wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
