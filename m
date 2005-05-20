From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17037.55922.293504.352477@gargle.gargle.HOWL>
Date: Fri, 20 May 2005 08:39:14 -0400
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505200310.j4K3Aqg07353@unix-os.sc.intel.com>
References: <17036.56626.994129.265926@gargle.gargle.HOWL>
	<200505200310.j4K3Aqg07353@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:
 > While working on porting the munmap free area coalescing patch on top of
 > 2.6.12-rc4-mm2 Kernel, this change from wolfgang looked very strange:
 > 
 > > @@ -1209,8 +1218,14 @@ void arch_unmap_area(struct vm_area_stru
 > >          * Is this a new hole at the lowest possible address?
 > >          */
 > >         if (area->vm_start >= TASK_UNMAPPED_BASE &&
 > > -                       area->vm_start < area->vm_mm->free_area_cache)
 > > -               area->vm_mm->free_area_cache = area->vm_start;
 > > +           area->vm_start < area->vm_mm->free_area_cache) {
 > > +               unsigned area_size = area->vm_end-area->vm_start;
 > > +
 > > +               if (area->vm_mm->cached_hole_size < area_size)
 > > +                       area->vm_mm->cached_hole_size = area_size;
 > > +               else
 > > +                       area->vm_mm->cached_hole_size = ~0UL;
 > > +       }
 > >  }
 > 
 > 
 > First, free_area_cache won't get moved on munmap.  OK fine. Secondly,
 > if area that we just unmapped is smaller than cached_hole_size, instead
 > of doing nothing (the condition of largest know hole size below current
 > cache pointer still holds at this time), the new code will reset hole
 > size to ~0UL, which will trigger a full scan next time for any mmap
 > request.
 > 
 > Wolfgang, did you tweak this area?  Or this is just a simple typo or
 > something?  AFAWICS, this patch will trigger a lot more innocent full scan
 > than what people claim it is.

Thanks for checking Ken. I believe that this logic becomes mostly
obsolete with your munmap patch anyhow.

You are perfectly right that the reset to ~0UL is not strictly
required however since the munmapped area can be joined with 
neightborings hole to form something larger (which size *I* cannot
determine at this time) I wanted to be better safe and restart any
search request from base.  

If the unmapped area sits between base and free_area_cache we
can then increase the cached_hole_size to the area_size if it
is indeed larger than the current cached_hole_size.

In both cases it would be nice to just calculate the real cached
hole size with some vma_find calls instead...

              Wolfgang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
