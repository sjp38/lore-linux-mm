Message-Id: <200505200310.j4K3Aqg07353@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Thu, 19 May 2005 20:10:52 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <17036.56626.994129.265926@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>
Cc: =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Thursday, May 19, 2005 11:39 AM
> I do certainly see that the algorithm isn't perfect in every case
> however for the test case Ingo sent me (Ingo, did you verify the
> timing?)  my patch performed as well as Ingo's original solution.  I
> assume that Ingo's test was requesting same map sizes for every thread
> so the results would be a bit biased in my favour... ;-)


While working on porting the munmap free area coalescing patch on top of
2.6.12-rc4-mm2 Kernel, this change from wolfgang looked very strange:

> @@ -1209,8 +1218,14 @@ void arch_unmap_area(struct vm_area_stru
>          * Is this a new hole at the lowest possible address?
>          */
>         if (area->vm_start >= TASK_UNMAPPED_BASE &&
> -                       area->vm_start < area->vm_mm->free_area_cache)
> -               area->vm_mm->free_area_cache = area->vm_start;
> +           area->vm_start < area->vm_mm->free_area_cache) {
> +               unsigned area_size = area->vm_end-area->vm_start;
> +
> +               if (area->vm_mm->cached_hole_size < area_size)
> +                       area->vm_mm->cached_hole_size = area_size;
> +               else
> +                       area->vm_mm->cached_hole_size = ~0UL;
> +       }
>  }


First, free_area_cache won't get moved on munmap.  OK fine. Secondly,
if area that we just unmapped is smaller than cached_hole_size, instead
of doing nothing (the condition of largest know hole size below current
cache pointer still holds at this time), the new code will reset hole
size to ~0UL, which will trigger a full scan next time for any mmap
request.

Wolfgang, did you tweak this area?  Or this is just a simple typo or
something?  AFAWICS, this patch will trigger a lot more innocent full scan
than what people claim it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
