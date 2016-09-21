Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91FAB28024E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:13:57 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l91so110611513qte.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:13:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w186si14755680ywe.184.2016.09.21.09.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 09:13:57 -0700 (PDT)
Date: Wed, 21 Sep 2016 18:13:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [xiaolong.ye@intel.com: [mm] 0331ab667f: kernel BUG at
 mm/mmap.c:327!]
Message-ID: <20160921161354.GC4716@redhat.com>
References: <20160920134638.GJ4716@redhat.com>
 <CANN689EwtyO7NvUnmfeo+0ugFhWZhDex8Wovc0Q5VvtPJYH+ZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689EwtyO7NvUnmfeo+0ugFhWZhDex8Wovc0Q5VvtPJYH+ZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 20, 2016 at 05:49:01PM -0700, Michel Lespinasse wrote:
> Hi Andrea, nice hearing from you :)

Same from my part :)

> It sounds like the gaps get temporarily out of sync, which is not an actual
> problem as long as they get fixed before releasing the appropriate locks
> (which you can verify by checking if the validate_mm() call at the end of
> vma_adjust() still passes).

Ok I did this change to test it. It reports zero problems with the
patch applied that skips "next" instead of "vma" in the case that sets
next->vm_start = vma->vm_start.

diff --git a/mm/mmap.c b/mm/mmap.c
index 0c5f6f7..62b7273 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -915,9 +915,10 @@ again:
 			end = next->vm_end;
 			goto again;
 		}
-		else if (next)
+		else if (next) {
 			vma_gap_update(next);
-		else
+			validate_mm(mm);
+		} else
 			mm->highest_vm_end = end;
 	}
 	if (insert && file)

the validate_mm is always executed in case 8 that removes "vma"
instead of "next".

So I think this is definitive confirmation there was no bug and this
was a false positive from DEBUG_VM_RR, that is fully corrected by the
incremental patch I sent yesterday.

> I'm guessing that for the update you're doing, the validate_mm_rb call
> within vma_rb_erase may need to ignore vma->next rather than vma itself.

Exactly, that's what the patch below does. Because vma->next->vm_start
was reduced to vma->vm_start and vma is still in the tree (I'm calling
the vma_rb_erase precisely to remove "vma").

> I haven't looked in enough detail, but this seems workable. The important
> part is that validate_mm must pass at the end up the update. Any other
> intermediate checks are secondary - don't feel bad about overriding them if
> they get in the way :)

I didn't shut off any check to correct the validation code after my
changes: I only shifted the "ignore" parameter from "vma" to "next"
like you suggested above.

> >         struct vm_area_struct *next;
> >
> > -       vma_rb_erase(vma, &mm->mm_rb);
> > +       if (has_prev)
> > +               vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
> > +       else
> > +               vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
> >         next = vma->vm_next;
> >         if (has_prev)
> >                 prev->vm_next = next;
> >
> 
> You seem to have the same function call on both sides of the if ???

Never mind, that was a leftover, but the code was still correct. I
already sent a cleanup follow up patch to deduplicate the above if.

> 
> 
> > @@ -626,13 +650,7 @@ static inline void __vma_unlink_prev(struct mm_struct
> > *mm,
> >                                      struct vm_area_struct *vma,
> >                                      struct vm_area_struct *prev)
> >  {
> > -       __vma_unlink_common(mm, vma, prev, true);
> > -}
> > -
> > -static inline void __vma_unlink(struct mm_struct *mm,
> > -                               struct vm_area_struct *vma)
> > -{
> > -       __vma_unlink_common(mm, vma, NULL, false);
> > +       __vma_unlink_common(mm, vma, prev, true, vma);
> >  }
> >
> >  /*
> >
> 
> confused as to why some of the __vma_unlink_common parameters change, other
> than just adding the ignore parameter

That changes __vma_unlink_prev, it's just the patch that is
confusing. I just dropped __vma_unlink enterely and I call
__vma_unlink_common directly now, in order to pass the different
"ignore" parameter to it.

The real change to __unlink_vma_prev is this:

> > -       __vma_unlink_common(mm, vma, prev, true);
> > +       __vma_unlink_common(mm, vma, prev, true, vma)

Which only adds the "same" ignore parameter.

In case8 when I remove "vma" instead of "next", I have no prev for
vma, and vma->vm_prev in fact may be null. So I can't call
__vma_unlink_prev, I got to call the common version directly that is
capable of doing an unlink without a prev guaranteed not-null.

> Sorry this is not a full review - but I do agree on the general principle
> of working around the intermediate checks in any way you need as long as
> validate_mm passes when you're done modifying the vma structures :)

Thanks a lot for the quick review, and yes validate_mm passes if put
immediately after the vma_gap_update(next) as shown at the top of the
email, so it should be all good with this change that passes "next" as
"ignore" parameter, instead of "vma" when next->vm_start is reduced
(instead of vma->vm_end increased in all other cases).

And so there is no bug in the fix in -mm, this was just a false
positive debug check that needed an update to the validation code to
cope with the new code.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
