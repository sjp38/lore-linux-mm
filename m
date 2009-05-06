Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 31F786B00A7
	for <linux-mm@kvack.org>; Wed,  6 May 2009 11:27:56 -0400 (EDT)
Message-ID: <4A01AC5E.6000906@redhat.com>
Date: Wed, 06 May 2009 18:27:26 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>
> If KSM is to behave in the usual madvise way, it'll need to be informed
> of unmaps.  And I suspect it may need to be informed of them, even if we
> let it continue to apply to empty address space.  Because even with your
> more limited unsigned int nrpages interface, the caller can specify an
> enormous range on 64-bit, and ksm.c be fully occupied just incrementing
> from one absent page to the next. 

That is a good point that i didnt think about it.
It is possible to make ksm "unmaped memory" aware by using find_vma(), 
and skipped non mapped area.
But that start to look bad... (I can make that just by every place that 
if_present_pte() fail, and then dont even hurt the scaning performence, 
beacuse i will just check it when the first virtual address is not present)

But why not go go step by step?
We can first start with this ioctl interface, later when we add swapping 
to the pages, we can have madvice, and still (probably easily) support 
the ioctls by just calling from inside ksm the madvice functions for 
that specific address)

I want to see ksm use madvice, but i believe it require some more 
changes to mm/*.c, so it probably better to start with merging it when 
it doesnt touch alot of stuff outisde ksm.c, and then to add swapping 
and after that add madvice support (when the pages are swappable, 
everyone can use it)

What you think about that?

>  mmap's vma ranges confine the space
> to be searched, and instantiated pagetables confine it further: I think
> you're either going to need to rely upon those to confine your search
> area, or else enhance your own data structures to confine it.
>
> But I do appreciate the separation you've kept so far,
> and wouldn't want to tie it all together too closely.
>
> Hugh
>
> p.s.  I wish you'd chosen different name than KSM - the kernel
> has supported shared memory for many years - and notice ksm.c itself
> says "Memory merging driver".  "Merge" would indeed have been a less
> ambiguous term than "Share", but I think too late to change that now
> - except possibly in the MADV_ flag names?
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
