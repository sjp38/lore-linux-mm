Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 01B876B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:47:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1513528pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:47:35 -0800 (PST)
Date: Thu, 15 Nov 2012 13:47:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 05/11] thp: change_huge_pmd(): keep huge zero page
 write-protected
In-Reply-To: <20121115084635.GC9676@otc-wbsnb-06>
Message-ID: <alpine.DEB.2.00.1211151344100.27188@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-6-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1211141512400.22537@chino.kir.corp.google.com> <20121115084635.GC9676@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, 15 Nov 2012, Kirill A. Shutemov wrote:

> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index d767a7c..05490b3 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -1259,6 +1259,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> > >  		pmd_t entry;
> > >  		entry = pmdp_get_and_clear(mm, addr, pmd);
> > >  		entry = pmd_modify(entry, newprot);
> > > +		if (is_huge_zero_pmd(entry))
> > > +			entry = pmd_wrprotect(entry);
> > >  		set_pmd_at(mm, addr, pmd, entry);
> > >  		spin_unlock(&vma->vm_mm->page_table_lock);
> > >  		ret = 1;
> > 
> > Nack, this should be handled in pmd_modify().
> 
> I disagree. It means we will have to enable hzp per arch. Bad idea.
> 

pmd_modify() only exists for those architectures with thp support already, 
so you've already implicitly enabled for all the necessary architectures 
with your patchset.

> What's wrong with the check?
> 

Anybody using pmd_modify() to set new protections in the future perhaps 
without knowledge of huge zero page can incorrectly make the huge zero 
page writable, which can never be allowed to happen.  It's better to make 
sure it can never happen with the usual interface to modify protections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
