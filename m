Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB9B6B0254
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:21:48 -0400 (EDT)
Received: by igdg1 with SMTP id g1so110003846igd.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:21:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s17si26916570igr.57.2015.10.22.07.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:21:47 -0700 (PDT)
Date: Thu, 22 Oct 2015 10:21:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v11 02/14] HMM: add special swap filetype for memory
 migrated to device v2.
Message-ID: <20151022142144.GB2914@redhat.com>
References: <05ec01d10c9b$4df7ba80$e9e72f80$@alibaba-inc.com>
 <05f501d10c9e$a8562900$f9027b00$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <05f501d10c9e$a8562900$f9027b00$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Oct 22, 2015 at 03:52:53PM +0800, Hillf Danton wrote:
> > 
> > When migrating anonymous memory from system memory to device memory
> > CPU pte are replaced with special HMM swap entry so that page fault,
> > get user page (gup), fork, ... are properly redirected to HMM helpers.
> > 
> > This patch only add the new swap type entry and hooks HMM helpers
> > functions inside the page fault and fork code path.
> > 
> > Changed since v1:
> 
> But the subject line says this work is v11

This is the v11 of the whole patchset. But this particular patch only
add 2 different version (v2 at the end of subject line). I do not bump
version of patches each time i rebase this seems pointless.

> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 4bc132a..7c66513 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> 
> I find no hmm.h in 4.3-rc6

This patchset depends on patchset i posted before this one and that the
introduction mail reference namely :

https://lkml.org/lkml/2015/10/21/739

[...]

> > +static inline int hmm_mm_fork(struct mm_struct *src_mm,
> > +			      struct mm_struct *dst_mm,
> > +			      struct vm_area_struct *dst_vma,
> > +			      pmd_t *dst_pmd,
> > +			      unsigned long start,
> > +			      unsigned long end)
> > +{
> > +	BUG();
> 
> s/BUG/BUILD_BUG/ ?

I use BUG(); to keep bisectability working. The core of this function
is implemented in a latter patch but this function is reference in
this one.

[...]

> > +#ifdef CONFIG_HMM
> > +static inline swp_entry_t make_hmm_entry(void)
> > +{
> > +	/* We do not store anything inside the CPU page table entry (pte). */
> 
> pte is clear enough, no?

Yes i will remove this redundancy.

[...]

> > +static inline int is_hmm_entry_poisonous(swp_entry_t entry)
> > +{
> > +	return (swp_type(entry) == SWP_HMM) && (swp_offset(entry) == 2);
> > +}
> 
> So SWP_HMM_LOCKED and SWP_HMM_POISON should be defined.

Good point.

[...]

> > @@ -894,9 +895,11 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> >  	pte_t *orig_src_pte, *orig_dst_pte;
> >  	pte_t *src_pte, *dst_pte;
> >  	spinlock_t *src_ptl, *dst_ptl;
> > +	unsigned cnt_hmm_entry = 0;
> 
> s/cnt_hmm_entry/hmm_ptes/ ?
> 

Maybe hmm_swap_ptes is even better name in this context.

[...]

> > +	if (cnt_hmm_entry) {
> > +		int ret;
> > +
> > +		ret = hmm_mm_fork(src_mm, dst_mm, dst_vma,
> > +				  dst_pmd, start, end);
> 
> Given start, s/end/addr/, no?

No, end is the right upper limit here.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
