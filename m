Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7A94A6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 08:14:21 -0500 (EST)
Date: Mon, 7 Nov 2011 13:14:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111107131413.GA18279@suse.de>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <20111104235603.GT18879@redhat.com>
 <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
 <20111105013317.GU18879@redhat.com>
 <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Sat, Nov 05, 2011 at 10:00:52AM +0800, Nai Xia wrote:
> > <SNIP>
> > The only safe way to do it is to have _two_ different vmas, with two
> > different ->vm_pgoff. Then it will work. And by always creating a new
> > vma we'll always have it queued at the end, and it'll be safe for the
> > same reasons fork is safe.
> >
> > Always allocate a new vma, and then after the whole vma copy is
> > complete, look if we can merge and free some vma. After the fact, so
> > it means we can't use vma_merge anymore. vma_merge assumes the
> > new_range is "virtual" and no vma is mapped there I think. Anyway
> > that's an implementation issue. In some unlikely case we'll allocate 1
> > more vma than before, and we'll free it once mremap is finished, but
> > that's small problem compared to solving this once and for all.
> >
> > And that will fix it without ordering games and it'll fix the *vmap=
> > new_vma case too. That case really tripped on me as I was assuming
> > *that* was correct.
> 
> Yes. "Allocating a new vma, copy first and merge later " seems
> another solution without the tricky reordering. But you know,
> I now share some of Hugh's feeling that maybe we are too
> desperate using racing in places where locks are simpler
> and guaranteed to be safe.
> 

I'm tending to agree. The number of cases that must be kept in mind
is getting too tricky. Taking the anon_vma lock may be slower but at
the risk of sounding chicken, it's easier to understand.

> But I think Mel indicated that anon_vma_locking might be
> harmful to JVM SMP performance.
> How severe you expect this to be, Mel ?
> 

I would only expect it to be a problem during garbage collection when
there is a greater likelihood that mremap is heavily used. While it
would have been nice to avoid additional overhead in mremap, I don't
think the JVM GC case on its own is sufficient justification to avoid
taking the anon_vma lock.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
