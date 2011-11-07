Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0611B6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:28:16 -0500 (EST)
Date: Mon, 7 Nov 2011 16:28:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111107162808.GA3083@suse.de>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <20111104235603.GT18879@redhat.com>
 <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
 <20111105013317.GU18879@redhat.com>
 <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
 <20111107131413.GA18279@suse.de>
 <20111107154235.GE3249@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111107154235.GE3249@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nai Xia <nai.xia@gmail.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Nov 07, 2011 at 04:42:35PM +0100, Andrea Arcangeli wrote:
> On Mon, Nov 07, 2011 at 01:14:13PM +0000, Mel Gorman wrote:
> > I'm tending to agree. The number of cases that must be kept in mind
> > is getting too tricky. Taking the anon_vma lock may be slower but at
> > the risk of sounding chicken, it's easier to understand.
> > 
> > > But I think Mel indicated that anon_vma_locking might be
> > > harmful to JVM SMP performance.
> > > How severe you expect this to be, Mel ?
> > > 
> > 
> > I would only expect it to be a problem during garbage collection when
> > there is a greater likelihood that mremap is heavily used. While it
> > would have been nice to avoid additional overhead in mremap, I don't
> > think the JVM GC case on its own is sufficient justification to avoid
> > taking the anon_vma lock.
> 
> Adding one liner in the error path and a bugcheck in the *vmap case,
> doesn't seem the end of the world compared to my previous fix that you
> acked.

Note that I didn't suddenly turn that ack into a nack although

  1) A small comment on why we need to call anon_vma_moveto_tail in the
     error path would be nice

  2) It is unfortunate that we need the faulted_in_anon_vma just
     for a VM_BUG_ON check that only exists for CONFIG_DEBUG_VM
     but not earth shatting

What I said was taking the anon_vma lock may be slower but it was
generally easier to understand. I'm happy with the new patch too
particularly as it keeps the "ordering game" consistent for fork
and mremap but I previously missed move_page_tables in the error
path so was worried if there was something else I managed to miss
particularly in light of the "Allocating a new vma, copy first and
merge later" direction.

I'm also prefectly happy with my human meat brain and do not expect
to replace it with an aliens.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
