Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB5B6B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 10:02:30 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so371366eei.14
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 07:02:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 45si27122748eeh.153.2014.04.29.07.02.28
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 07:02:29 -0700 (PDT)
Date: Tue, 29 Apr 2014 16:02:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] vmacache: change vmacache_find() to always check
	->vm_mm
Message-ID: <20140429140216.GA16816@redhat.com>
References: <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net> <CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com> <20140428161120.4cad719dc321e3c837db3fd6@linux-foundation.org> <CA+55aFwLSW3V76Y_O37Y8r_yaKQ+y0VMk=6SEEBpeFfGzsJUKA@mail.gmail.com> <1398730319.25549.40.camel@buesod1.americas.hpqcorp.net> <535F78A8.80403@linux.vnet.ibm.com> <20140429125255.GA13934@redhat.com> <535FA488.8020405@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535FA488.8020405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>

On 04/29, Srivatsa S. Bhat wrote:
>
> On 04/29/2014 06:22 PM, Oleg Nesterov wrote:
> > On 04/29, Srivatsa S. Bhat wrote:
> >>
> >> I guess I'll hold off on testing this fix until I get to reproduce
> >> the bug more reliably..
> >
> > perhaps the patch below can help a bit?
> >
> > -------------------------------------------------------------------------------
> > Subject: [PATCH] vmacache: change vmacache_find() to always check ->vm_mm
> >
> > If ->vmacache was corrupted it would be better to detect and report
> > the problem asap, check vma->vm_mm before vm_start/vm_end.
> >
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > ---
> >  mm/vmacache.c |    5 +++--
> >  1 files changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/vmacache.c b/mm/vmacache.c
> > index d4224b3..952a324 100644
> > --- a/mm/vmacache.c
> > +++ b/mm/vmacache.c
> > @@ -81,9 +81,10 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
> >  	for (i = 0; i < VMACACHE_SIZE; i++) {
> >  		struct vm_area_struct *vma = current->vmacache[i];
> >
> > -		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
> > +		if (vma) {
> >  			BUG_ON(vma->vm_mm != mm);
> > -			return vma;
> > +			if (vma->vm_start <= addr && vma->vm_end > addr)
> > +				return vma;
> >  		}
> >  	}
> >
>
> IIUC, this is similar to commit 50f5aa8a9b2 (mm: don't pointlessly use
> BUG_ON() for sanity check).

Yes, I see this commit after git-pull ;)

Please ignore then.

> But even with that commit included I was
> not able to reproduce the bug again, as reported here:
>
> https://lkml.org/lkml/2014/4/29/187

Thanks...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
