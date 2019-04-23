Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38254C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 03:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6267206BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 03:00:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6267206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797BA6B0003; Mon, 22 Apr 2019 23:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7498C6B0006; Mon, 22 Apr 2019 23:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60F4D6B0007; Mon, 22 Apr 2019 23:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAA06B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 23:00:48 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e31so13561021qtb.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 20:00:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pPcKg7SKzskbBRYTtyAPqJaynaXgzoZN3Rr5GGiuAlc=;
        b=ksC/Dti8voZKG7D4mFcyEA/zf+OGFXnZey4V7ZUpMCi9uKsP5aKPq0e2soSHc4s6+V
         hih/YrX7z7OjiwRHTnHZFO6LmiTxAyQ6TUgP510NAMZTMfhwYF/kDqakh0NowayH+xaJ
         PYtYhtS6cv9m0xj339zdAdX0Jqlw8ZTHdG/mP6bFqOD+EzS/xMzNMY2lrxJbjRIxN1bc
         vxpBfBEImqV2Xl30p4FB2wyhBPtSNMx/vMWkcHwfF8U5RN5DQ0vQriTjKS/zKKXlMoMV
         qznqhy9SPwQmVsAoMJGTIgMtyq0q0H8ZACaFRN/bfFndJ3QTSnqxNpgaidug0TxHo0UA
         u7sQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWmLwpEwIB0kGt+hfaOaJJtxoSN1RKoMecyVRUbiGns0nL6vxeT
	y3C7XuVtmA3F5tWAEdNTfgTPqizjExRmJbgilesD3tO/PeJZAU8YNp5WYpP/Gr+fVHMwbL89uy7
	HBodfHKFTvGRqHeFuxbc54niR9bYZsh0HkoEMkgpCejXiV3ixgeBFzQHV1LEcST+/9g==
X-Received: by 2002:ac8:851:: with SMTP id x17mr18627138qth.373.1555988447999;
        Mon, 22 Apr 2019 20:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHHHGVRhAHipe9iAATHX6hRrejrvI9n8s1hoCd0O6Sx4+fS0fWYHoUmv7WocMnJHUumAlj
X-Received: by 2002:ac8:851:: with SMTP id x17mr18627076qth.373.1555988446828;
        Mon, 22 Apr 2019 20:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555988446; cv=none;
        d=google.com; s=arc-20160816;
        b=IH+qPD7sGQfBbIRSI5OhxCFqzSpu4kgCzk7yY63hPx4IZO3qBYrH/eqN68k4MaAXf/
         GSEBByoGLMUblG4vO1qr2jWV5sTTildG+pH9Ab9ZlCS2aqlXSqWs49gEKxBQE+wv93Wx
         TJIfLpfWHQRwOxUDAVnZBE0urr+lAjNVkUU07vlQ2nJPNjnnb8V40uGybPh5+pOfEw2N
         rvA4ncDtzk34TerbhkcIP6B3COopwgXII1eDXlMIgtWEdofxhdqlJIbLz+qWwJxGux30
         6zkAHsOwt/Y4F+MEzJki1O7QbZ3a4hkQLHvOk1HCnpn/AnVGp8yPKPLHXkyYd1n6YTKu
         ybgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pPcKg7SKzskbBRYTtyAPqJaynaXgzoZN3Rr5GGiuAlc=;
        b=uZxub1n0mTJiUBt0P+LYMpo+YtvJkCAZlYg8khT6nQ4QkyYK7ol21Za1lVeSFpiID1
         T1fp22T6zMl1cICZoh75d9rAJjQXzcJRZZ7MwnM5eS1SSK712E3bbHF9Qku+mfazYttZ
         0NaLXKhu0ObhQ43ZBTjkQ/NkPh8L4+VXU+lTVqm5i9do/2iAz6mSP46uPaViKFrV5R47
         hzjuFA/HQs6dFV6kt11LFUVptiLouh4NkKguI12vaaHuYoLM32pK1Wmei5Hg7DJOEPbu
         Yx1ZmyIxCJ64QKWPED5v5d2ATi7mhNVqKkDMHwfhw0kV07vqqFxJ78urppw4v+nsCHR3
         +jcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e14si1026436qtg.174.2019.04.22.20.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 20:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B3009307D840;
	Tue, 23 Apr 2019 03:00:44 +0000 (UTC)
Received: from xz-x1 (ovpn-12-175.pek2.redhat.com [10.72.12.175])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 23A585C1B5;
	Tue, 23 Apr 2019 03:00:33 +0000 (UTC)
Date: Tue, 23 Apr 2019 11:00:30 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 14/28] userfaultfd: wp: handle COW properly for uffd-wp
Message-ID: <20190423030030.GA21301@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
 <20190419062650.GF13323@xz-x1>
 <20190419150253.GA3311@redhat.com>
 <20190422122010.GA25896@xz-x1>
 <20190422145402.GB3450@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190422145402.GB3450@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 23 Apr 2019 03:00:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:54:02AM -0400, Jerome Glisse wrote:
> On Mon, Apr 22, 2019 at 08:20:10PM +0800, Peter Xu wrote:
> > On Fri, Apr 19, 2019 at 11:02:53AM -0400, Jerome Glisse wrote:
> > 
> > [...]
> > 
> > > > > > +			if (uffd_wp_resolve) {
> > > > > > +				/* If the fault is resolved already, skip */
> > > > > > +				if (!pte_uffd_wp(*pte))
> > > > > > +					continue;
> > > > > > +				page = vm_normal_page(vma, addr, oldpte);
> > > > > > +				if (!page || page_mapcount(page) > 1) {
> > > > > > +					struct vm_fault vmf = {
> > > > > > +						.vma = vma,
> > > > > > +						.address = addr & PAGE_MASK,
> > > > > > +						.page = page,
> > > > > > +						.orig_pte = oldpte,
> > > > > > +						.pmd = pmd,
> > > > > > +						/* pte and ptl not needed */
> > > > > > +					};
> > > > > > +					vm_fault_t ret;
> > > > > > +
> > > > > > +					if (page)
> > > > > > +						get_page(page);
> > > > > > +					arch_leave_lazy_mmu_mode();
> > > > > > +					pte_unmap_unlock(pte, ptl);
> > > > > > +					ret = wp_page_copy(&vmf);
> > > > > > +					/* PTE is changed, or OOM */
> > > > > > +					if (ret == 0)
> > > > > > +						/* It's done by others */
> > > > > > +						continue;
> > > > > 
> > > > > This is wrong if ret == 0 you still need to remap the pte before
> > > > > continuing as otherwise you will go to next pte without the page
> > > > > table lock for the directory. So 0 case must be handled after
> > > > > arch_enter_lazy_mmu_mode() below.
> > > > > 
> > > > > Sorry i should have catch that in previous review.
> > > > 
> > > > My fault to not have noticed it since the very beginning... thanks for
> > > > spotting that.
> > > > 
> > > > I'm squashing below changes into the patch:
> > > 
> > > 
> > > Well thinking of this some more i think you should use do_wp_page() and
> > > not wp_page_copy() it would avoid bunch of code above and also you are
> > > not properly handling KSM page or page in the swap cache. Instead of
> > > duplicating same code that is in do_wp_page() it would be better to call
> > > it here.
> > 
> > Yeah it makes sense to me.  Then here's my plan:
> > 
> > - I'll need to drop previous patch "export wp_page_copy" since then
> >   it'll be not needed
> > 
> > - I'll introduce another patch to split current do_wp_page() and
> >   introduce function "wp_page_copy_cont" (better suggestion on the
> >   naming would be welcomed) which contains most of the wp handling
> >   that'll be needed for change_pte_range() in this patch and isolate
> >   the uffd handling:
> > 
> > static vm_fault_t do_wp_page(struct vm_fault *vmf)
> > 	__releases(vmf->ptl)
> > {
> > 	struct vm_area_struct *vma = vmf->vma;
> > 
> > 	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
> > 		pte_unmap_unlock(vmf->pte, vmf->ptl);
> > 		return handle_userfault(vmf, VM_UFFD_WP);
> > 	}
> > 
> > 	return do_wp_page_cont(vmf);
> > }
> > 
> > Then I can probably use do_wp_page_cont() in this patch.
> 
> Instead i would keep the do_wp_page name and do:
>     static vm_fault_t do_userfaultfd_wp_page(struct vm_fault *vmf) {
>         ... // what you have above
>         return do_wp_page(vmf);
>     }
> 
> Naming wise i think it would be better to keep do_wp_page() as
> is.

In case I misunderstood... what I've proposed will be simply:

diff --git a/mm/memory.c b/mm/memory.c
index 64bd8075f054..ab98a1eb4702 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2497,6 +2497,14 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
                return handle_userfault(vmf, VM_UFFD_WP);
        }

+       return do_wp_page_cont(vmf);
+}
+
+vm_fault_t do_wp_page_cont(struct vm_fault *vmf)
+       __releases(vmf->ptl)
+{
+       struct vm_area_struct *vma = vmf->vma;
+
        vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
        if (!vmf->page) {
                /*

And the other proposal is:

diff --git a/mm/memory.c b/mm/memory.c
index 64bd8075f054..a73792127553 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2469,6 +2469,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
        return VM_FAULT_WRITE;
 }

+static vm_fault_t do_wp_page(struct vm_fault *vmf);
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2487,7 +2489,7 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static vm_fault_t do_wp_page(struct vm_fault *vmf)
+static vm_fault_t do_userfaultfd_wp_page(struct vm_fault *vmf)
        __releases(vmf->ptl)
 {
        struct vm_area_struct *vma = vmf->vma;
@@ -2497,6 +2499,14 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
                return handle_userfault(vmf, VM_UFFD_WP);
        }

+       return do_wp_page(vmf);
+}
+
+static vm_fault_t do_wp_page(struct vm_fault *vmf)
+       __releases(vmf->ptl)
+{
+       struct vm_area_struct *vma = vmf->vma;
+
        vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
        if (!vmf->page) {
                /*
@@ -2869,7 +2879,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
        }

        if (vmf->flags & FAULT_FLAG_WRITE) {
-               ret |= do_wp_page(vmf);
+               ret |= do_userfaultfd_wp_page(vmf);
                if (ret & VM_FAULT_ERROR)
                        ret &= VM_FAULT_ERROR;
                goto out;
@@ -3831,7 +3841,7 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
                goto unlock;
        if (vmf->flags & FAULT_FLAG_WRITE) {
                if (!pte_write(entry))
-                       return do_wp_page(vmf);
+                       return do_userfaultfd_wp_page(vmf);
                entry = pte_mkdirty(entry);
        }
        entry = pte_mkyoung(entry);

I would prefer the 1st approach since it not only contains fewer lines
of changes because it does not touch callers, and also the naming in
the 2nd approach can be a bit confusing (calling
do_userfaultfd_wp_page in handle_pte_fault may let people think of an
userfault-only path but actually it covers the general path).  But if
you really like the 2nd one I can use that too.

Thanks,

-- 
Peter Xu

