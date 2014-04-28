Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 21C306B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 17:20:50 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so8658748veb.8
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:20:49 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id t5si3982788vcp.40.2014.04.28.14.20.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 14:20:49 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq16so6518426vcb.11
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:20:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <535EA976.1080402@linux.vnet.ibm.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
Date: Mon, 28 Apr 2014 14:20:49 -0700
Message-ID: <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <davidlohr@hp.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, Apr 28, 2014 at 12:18 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
>
> I hit this during boot on v3.15-rc3, just once so far.
> Subsequent reboots went fine, and a few quick runs of multi-
> threaded ebizzy also didn't recreate the problem.
>
> The kernel I was running was v3.15-rc3 + some totally
> unrelated cpufreq patches.
>
> The BUG_ON triggered from the following code:
>
>  74 struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
>  84                 if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
>  85                         BUG_ON(vma->vm_mm != mm);
>  86                         return vma;
>  87                 }

Hmm. Andrew, Davidlohr, I thought we agreed that he non-current mm
case can actually happen, and that the BUG_ON() was wrong and we
should compare the mm pointer. But the patch that got merged obviously
has the BUG_ON(), so my memory must be wrong.

Regardless, I absolutely *detest* random BUG_ON() calls that turn a
debuggability problem totally unnecessarily into a hard failure, so
that BUG_ON() really needs to go away. I *know* I suggested using
WARN_ON_ONCE() when the discussion was about whether the condition
could happen or not, and the fact that it got turned into a BUG_ON()
is a damn shame.

Andrew, I think I blame you for that particular BUG_ON() addition,
because I don't see it in the original patch. There is *no* excuse for
a BUG_ON(), when a

   if (WARN_ON_ONCE(vma->vm_mm != mm))
      return NULL;

would have worked equally well without killing the box and making
things harder to debug.

This BUG_ON() insanity needs to stop. The thing is a f*cking menace,
and it's not the first time we hit a BUG_ON() that damn well shouldn't
have been a BUG_ON() to begin with.

That said, the bug does seem to be that some path doesn't invalidate
the vmacache sufficiently, or something inserts a vmacache entry into
the current process when looking up a remote process or whatever.
Davidlohr, ideas?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
