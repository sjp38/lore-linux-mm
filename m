Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 8B1A66B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 06:39:24 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 27 Aug 2012 11:39:22 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7RAdDu229360224
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 10:39:13 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7RAdJXu009600
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 04:39:19 -0600
Date: Mon, 27 Aug 2012 12:39:17 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC patch 3/7] thp: make MADV_HUGEPAGE check for mm->def_flags
Message-ID: <20120827123917.3313dfda@thinkpad>
In-Reply-To: <CAJd=RBBJa934R53AHYVhkxE+2e=RiKU1zJXsLMCBFw_NHZE0oQ@mail.gmail.com>
References: <20120823171733.595087166@de.ibm.com>
	<20120823171854.580076595@de.ibm.com>
	<CAJd=RBBJa934R53AHYVhkxE+2e=RiKU1zJXsLMCBFw_NHZE0oQ@mail.gmail.com>
Reply-To: gerald.schaefer@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Sat, 25 Aug 2012 20:47:37 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Fri, Aug 24, 2012 at 1:17 AM, Gerald Schaefer
> <gerald.schaefer@de.ibm.com> wrote:
> > This adds a check to hugepage_madvise(), to refuse MADV_HUGEPAGE
> > if VM_NOHUGEPAGE is set in mm->def_flags. On System z, the VM_NOHUGEPAGE
> > flag will be set in mm->def_flags for kvm processes, to prevent any
> > future thp mappings. In order to also prevent MADV_HUGEPAGE on such an
> > mm, hugepage_madvise() should check mm->def_flags.
> >
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > ---
> >  mm/huge_memory.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1464,6 +1464,8 @@ out:
> >  int hugepage_madvise(struct vm_area_struct *vma,
> >                      unsigned long *vm_flags, int advice)
> >  {
> > +       struct mm_struct *mm = vma->vm_mm;
> > +
> >         switch (advice) {
> >         case MADV_HUGEPAGE:
> >                 /*
> > @@ -1471,6 +1473,8 @@ int hugepage_madvise(struct vm_area_stru
> >                  */
> >                 if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
> >                         return -EINVAL;
> > +               if (mm->def_flags & VM_NOHUGEPAGE)
> > +                       return -EINVAL;
> 
> Looks ifdefinery needed for s390 to wrap the added check, and
> a brief comment?

Hmm, architecture #ifdefs in common code are ugly. I'd rather keep
the check even if it is redundant right now for other architectures
than s390. It is not a performance critical path, and there may be
other users of that in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
