Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B106B6B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 19:10:21 -0400 (EDT)
Received: by weys10 with SMTP id s10so68252wey.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 16:10:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com> <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 7 Sep 2012 16:09:59 -0700
Message-ID: <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, Sep 7, 2012 at 3:42 PM, Suresh Siddha <suresh.b.siddha@intel.com> wrote:
> -       unsigned long start;
> -       unsigned long off;
> -       u32 len;
> +       resource_size_t start, off;
> +       unsigned long len;

So since the oops is on x86-64, I don't think it's the "unsigned long"
-> "resource_size_t" part (which can be an issue on 32-bit
architectures, though).

The "u32 len" -> "unsigned long len" thing *might* make a difference, though.

I also think your patch is incomplete even on 32-bit, because this:

>         if (mtd->type == MTD_RAM || mtd->type == MTD_ROM) {
>                 off = vma->vm_pgoff << PAGE_SHIFT;

is still wrong. It probably should be

    off = vma->vm_pgoff;
    off <<= PAGE_SHIFT;

because vm_pgoff may be a 32-bit type, while "resource_size_t" may be
64-bit. Shifting the 32-bit type without a cast (implicit or explicit)
isn't going to help.

That said, we have absolutely *tons* of bugs with this particular
pattern. Just do

    git grep 'vm_pgoff.*<<.*PAGE_SHIFT'

and there are distressingly few casts in there (there's a few, mainly
in fs/proc).

Now, I suspect many of them are fine just because most users probably
are size-limited anyway, but it's a bit distressing stuff. And I
suspect it means we might want to introduce a helper function like

    static inline u64 vm_offset(struct vm_area_struct *vma)
    {
        return (u64)vma->vm_pgoff << PAGE_SHIFT;
    }

or something. Maybe add the "vm_length()" helper while at it too,
since the whole "vma->vm_end - vma->vm_start" thing is so common.

Anyway, since Sasha's oops is clearly not 32-bit, the above issues
don't matter, and it would be interesting to hear if it's the 32-bit
'len' thing that triggers this problem. Still, I can't see how it
would - as far as I can tell, a truncated 'len' would at most result
in spurious early "return -EINVAL", not any real problem.

What are we missing?

Sasha, since you can apparently reproduce it, can you replace the
"BUG_ON()" with just a

 if (start >= end) {
    printf("bogus range %llx - %llx\n", start, end);
    return -EINVAL;
  }

or something.

I'm starting to suspect that maybe it's actually that the length is
*zero*, and start == end, and that we should just return zero for that
case. But let's see what Sasha finds..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
