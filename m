Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 288A86B0099
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:14:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so987713pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 00:14:19 -0800 (PST)
Date: Thu, 15 Nov 2012 00:14:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 03/11] thp: copy_huge_pmd(): copy huge zero page
In-Reply-To: <20121115080133.GA9676@otc-wbsnb-06>
Message-ID: <alpine.DEB.2.00.1211150013220.4410@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-4-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1211141433150.13515@chino.kir.corp.google.com> <20121115080133.GA9676@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, 15 Nov 2012, Kirill A. Shutemov wrote:

> > > @@ -778,6 +790,11 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> > >  		pte_free(dst_mm, pgtable);
> > >  		goto out_unlock;
> > >  	}
> > > +	if (is_huge_zero_pmd(pmd)) {
> > > +		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd);
> > > +		ret = 0;
> > > +		goto out_unlock;
> > > +	}
> > 
> > You said in the introduction message in this series that you still allow 
> > splitting of the pmd, so why no check for pmd_trans_splitting() before 
> > this?
> 
> pmd_trans_splitting() returns true only for pmd which points to a page
> under spliiting. It never happens with huge zero page.
> We only split a pmd to a page table without touching the page.
> mm->page_table_lock is enough to protect against that.
> 

Comment in the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
