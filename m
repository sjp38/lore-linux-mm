Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C2C946B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 11:33:03 -0400 (EDT)
Received: by wijp15 with SMTP id p15so27443168wij.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 08:33:03 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id d13si13530577wjs.119.2015.08.06.08.33.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 08:33:02 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so27593262wib.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 08:33:01 -0700 (PDT)
Date: Thu, 6 Aug 2015 18:33:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page-flags behavior on compound pages: a worry
Message-ID: <20150806153259.GA2834@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 05, 2015 at 09:15:57PM -0700, Hugh Dickins wrote:
> Hi Kirill,
> 
> I had a nasty thought this morning.
 
Tough day.

I'm trying to wrap my head around this mail and not sure if I succeed
much. :-|

> Andrew had prodded me gently to re-examine my concerns with your
> page-flags rework in mmotm.  I still dislike the bloat (my mm/built-in.o
> text goes up from 478513 to 490183 bytes on a non-DEBUG_VM build); but I
> was hoping to set that aside, to let us move forward.
> 
> But looking into the bloat led me to what seems a more serious issue
> with it.  I'd tacked a little function on to the end of mm/filemap.c:
> 
> bool page_is_locked(struct page *page)
> {
> 	return !!PageLocked(page);
> }
> 
> which came out as:
> 
> 0000000000003a60 <page_is_locked>:
>     3a60:	48 8b 07             	mov    (%rdi),%rax
>     3a63:	55                   	push   %rbp
>     3a64:	48 89 e5             	mov    %rsp,%rbp
> 
> [instructions above same as without your patches; those below added by them]
> 
>     3a67:	f6 c4 80             	test   $0x80,%ah
>     3a6a:	74 10                	je     3a7c <page_is_locked+0x1c>
>     3a6c:	48 8b 47 30          	mov    0x30(%rdi),%rax
>     3a70:	48 8b 17             	mov    (%rdi),%rdx
>     3a73:	80 e6 80             	and    $0x80,%dh
>     3a76:	48 0f 44 c7          	cmove  %rdi,%rax
>     3a7a:	eb 03                	jmp    3a7f <page_is_locked+0x1f>
>     3a7c:	48 89 f8             	mov    %rdi,%rax
>     3a7f:	48 8b 00             	mov    (%rax),%rax
> 
> [instructions above added by your patches; those below same as before]
> 
>     3a82:	5d                   	pop    %rbp
>     3a83:	83 e0 01             	and    $0x1,%eax
>     3a86:	c3                   	retq   
> 
> The "and $0x80,%dh" looked superfluous at first, but of course it isn't:
> it's from the smp_rmb() in David's 668f9abbd433 "mm: close PageTail race"
> (a later commit refactors compound_head() but doesn't change the story).
> 
> And it's that race, or a worse race of that kind, that now worries me.
> Relying on smp_wmb() and smp_rmb() may be all that was needed in the
> case that David was fixing; and (I dare not look at them to audit!)
> all uses of compound_head() in our current v4.2-rc tree may well be
> safe, for this or that contingent reason in each place that it's used.
> 
> But there is no locking within compound_head(page) to make it safe
> everywhere, yet your page-flags rework is changing a large number
> of PageWhatever()s and SetPageWhatever()s and ClearPageWhatever()s
> now to do a hidden compound_head(page) beneath the covers.
> 
> To be more specific: if preemption, or an interrupt, or entry to SMM
> mode, or whatever, delays this thread somewhere in that compound_head()
> sequence of instructions, how can we be sure that the "head" returned
> by compound_head() is good?  We know the page was PageTail just before
> looking up page->first_page, and we know it was PageTail just after,
> but we don't know that it was PageTail throughout, and we don't know
> whether page->first_page is even a good page pointer, or something
> else from the private/ptl/slab_cache union.

That looks like a very valid worry to me. For current -mm tree.

But let's take my refcounting rework into picture.

One thing it simplifies is protection against splitting. Once you've got a
reference to a page, it cannot be split under you. It makes PageTail() and
->first_page stable for most callsites.

We can access the page's flags under ptl, without having reference the
page. And that's fine: ptl protects against splitting too.

Fast GUP also have a way to protect against split.

IIUC, the only potentially problematic callsites left are physical memory
scanners. This code requires audit. I'll do that.
 
Do I miss something else?

> Of course it would be very rare for it to go wrong; and most callsites
> will obviously be safe for this or that reason; though, sadly, none of
> them safe from holding a reference to the tail page in question, since
> its count is frozen at 0 and cannot be grabbed by get_page_unless_zero.

Do you mean that grabbing head page's ->_count is not enough to protect
against splitting and freeing tail page under you?

I know a patchset which solves this! ;)

> But I don't see how it can be safe to rely on compound_head() inside
> a general purpose page-flag function, that we're all accustomed to
> think of as a simple bitop, that can be applied without great care.
> 
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
