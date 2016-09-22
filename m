Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A84C6B027C
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 15:16:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 16so175939927qtn.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:16:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v33si2251270qtd.81.2016.09.22.12.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 12:16:00 -0700 (PDT)
Date: Thu, 22 Sep 2016 21:15:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/4] mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
Message-ID: <20160922191556.GF3485@redhat.com>
References: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
 <1474492522-2261-2-git-send-email-aarcange@redhat.com>
 <002e01d214a1$6f39e100$4dada300$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002e01d214a1$6f39e100$4dada300$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'Rik van Riel' <riel@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Mel Gorman' <mgorman@techsingularity.net>

Hello Hillf,

On Thu, Sep 22, 2016 at 03:17:52PM +0800, Hillf Danton wrote:
> Hey Andrea
> > 
> > @@ -111,13 +111,16 @@ static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
> >  void vma_set_page_prot(struct vm_area_struct *vma)
> >  {
> >  	unsigned long vm_flags = vma->vm_flags;
> > +	pgprot_t vm_page_prot;
> > 
> > -	vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
> > +	vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
> >  	if (vma_wants_writenotify(vma)) {
> 
> Since vma->vm_page_prot is currently used in vma_wants_writenotify(), is 
> it possible that semantic change is introduced here with local variable? 

>From a short review I think you're right.

Writing an intermediate value with WRITE_ONCE before clearing
VM_SHARED wouldn't be correct either if the "vma" was returned by
vma_merge, so to fix this, the intermediate vm_page_prot needs to be
passed as parameter to vma_wants_writenotify(vma, vm_page_prot).

For now it's safer to drop this patch 1/4. The atomic setting of
vm_page_prot in mprotect is an orthogonal problem to the vma_merge
case8 issues in the other patches. The side effect would be the same
("next" vma ptes going out of sync with the write bit set, because
vm_page_prot was the intermediate value created with VM_SHARED still
set in vm_flags) but it's not a bug in vma_merge/vma_adjust here.

I can correct and resend this one later.

While at it, I've to say the handling of VM_SOFTDIRTY across vma_merge
also seems dubious when it's not mmap_region calling vma_merge but
that would be yet another third orthogonal problem, so especially that
one should be handled separately as it'd be specific to soft dirty
only, the atomicity issue above is somewhat more generic.

On a side note, the fix for vma_merge in -mm changes nothing in regard
of the above or soft dirty, they're orthogonal issues.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
