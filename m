Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD326B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:17:48 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so25321816lbc.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:17:48 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id u73si9020840lfd.133.2016.06.16.03.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:17:47 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id w130so5171909lfd.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:17:47 -0700 (PDT)
Date: Thu, 16 Jun 2016 13:17:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9-rebased2 11/37] mm: introduce do_set_pmd()
Message-ID: <20160616101744.GC18137@node.shutemov.name>
References: <050201d1c7ae$9dbf9370$d93eba50$@alibaba-inc.com>
 <050301d1c7af$9cbe81b0$d63b8510$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <050301d1c7af$9cbe81b0$d63b8510$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 16, 2016 at 05:15:22PM +0800, Hillf Danton wrote:
> > +
> > +static int do_set_pmd(struct fault_env *fe, struct page *page)
> > +{
> > +	struct vm_area_struct *vma = fe->vma;
> > +	bool write = fe->flags & FAULT_FLAG_WRITE;
> > +	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
> > +	pmd_t entry;
> > +	int i, ret;
> > +
> > +	if (!transhuge_vma_suitable(vma, haddr))
> > +		return VM_FAULT_FALLBACK;
> > +
> > +	ret = VM_FAULT_FALLBACK;
> > +	page = compound_head(page);
> > +
> > +	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
> > +	if (unlikely(!pmd_none(*fe->pmd)))
> > +		goto out;
> 
> Can we reply to the caller that fault is handled correctly(by
> resetting ret to zero before jump)?

It's non necessary handled. It's handled only if the pmd if huge. If it
points to pte table, we need to check relevant pte entry.

If pmd is huge it will caught by pte_alloc_one_map() later.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
