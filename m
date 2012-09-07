Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 53C276B006C
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 19:55:10 -0400 (EDT)
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
From: Suresh Siddha <suresh.b.siddha@intel.com>
Reply-To: Suresh Siddha <suresh.b.siddha@intel.com>
Date: Fri, 07 Sep 2012 16:54:05 -0700
In-Reply-To: <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
References: <1340959739.2936.28.camel@lappy>
	 <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
	 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
	 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
	 <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, 2012-09-07 at 16:09 -0700, Linus Torvalds wrote:
> The "u32 len" -> "unsigned long len" thing *might* make a difference, though.

This I believe doesn't fix the reported BUG. I was trying to address
your previous comment about broken types.

> 
> I also think your patch is incomplete even on 32-bit, because this:
> 
> >         if (mtd->type == MTD_RAM || mtd->type == MTD_ROM) {
> >                 off = vma->vm_pgoff << PAGE_SHIFT;
> 
> is still wrong. It probably should be
> 
>     off = vma->vm_pgoff;
>     off <<= PAGE_SHIFT;
> 
> because vm_pgoff may be a 32-bit type, while "resource_size_t" may be
> 64-bit. Shifting the 32-bit type without a cast (implicit or explicit)
> isn't going to help.

Agree.

> That said, we have absolutely *tons* of bugs with this particular
> pattern. Just do
> 
>     git grep 'vm_pgoff.*<<.*PAGE_SHIFT'
> 
> and there are distressingly few casts in there (there's a few, mainly
> in fs/proc).
> 
> Now, I suspect many of them are fine just because most users probably
> are size-limited anyway, but it's a bit distressing stuff. And I
> suspect it means we might want to introduce a helper function like
> 
>     static inline u64 vm_offset(struct vm_area_struct *vma)
>     {
>         return (u64)vma->vm_pgoff << PAGE_SHIFT;
>     }
> 
> or something. Maybe add the "vm_length()" helper while at it too,
> since the whole "vma->vm_end - vma->vm_start" thing is so common.

Agree.

> Anyway, since Sasha's oops is clearly not 32-bit, the above issues
> don't matter, and it would be interesting to hear if it's the 32-bit
> 'len' thing that triggers this problem. Still, I can't see how it
> would - as far as I can tell, a truncated 'len' would at most result
> in spurious early "return -EINVAL", not any real problem.
> 
> What are we missing?
> 

On Fri, 2012-09-07 at 15:42 -0700, Suresh Siddha wrote:
> -               if ((vma->vm_end - vma->vm_start + off) > len)
> +               if (off >= len || (vma->vm_end - vma->vm_start + off) > len)
>                         return -EINVAL; 

This is the relevant portion that I am thinking will address the BUG.

Essentially the user is trying to mmap at a very large offset (from the
oops it appears "vma->vm_pgoff << PAGE_SHIFT + start" ends up to
"0xfffffffffffff000").

So it appears that the condition "(vma->vm_end - vma->vm_start + off) >
len" might be false because of the wraparound? and doesn't return
-EINVAL.

Let's see what Sasha finds. Anyways the patch does indeed require your
above mentioned vm_pgoff fix for the 32-bit case.

thanks,
suresh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
