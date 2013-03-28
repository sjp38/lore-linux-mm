Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5FFA36B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 11:07:07 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514CA182.7050906@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-18-git-send-email-kirill.shutemov@linux.intel.com>
 <514CA182.7050906@sr71.net>
Subject: Re: [PATCHv2, RFC 17/30] thp: wait_split_huge_page(): serialize over
 i_mmap_mutex too
Content-Transfer-Encoding: 7bit
Message-Id: <20130328150828.A847FE0085@blue.fi.intel.com>
Date: Thu, 28 Mar 2013 17:08:28 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -113,11 +113,20 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
> >  			__split_huge_page_pmd(__vma, __address,		\
> >  					____pmd);			\
> >  	}  while (0)
> > -#define wait_split_huge_page(__anon_vma, __pmd)				\
> > +#define wait_split_huge_page(__vma, __pmd)				\
> >  	do {								\
> >  		pmd_t *____pmd = (__pmd);				\
> > -		anon_vma_lock_write(__anon_vma);			\
> > -		anon_vma_unlock_write(__anon_vma);			\
> > +		struct address_space *__mapping =			\
> > +					vma->vm_file->f_mapping;	\
> > +		struct anon_vma *__anon_vma = (__vma)->anon_vma;	\
> > +		if (__mapping)						\
> > +			mutex_lock(&__mapping->i_mmap_mutex);		\
> > +		if (__anon_vma) {					\
> > +			anon_vma_lock_write(__anon_vma);		\
> > +			anon_vma_unlock_write(__anon_vma);		\
> > +		}							\
> > +		if (__mapping)						\
> > +			mutex_unlock(&__mapping->i_mmap_mutex);		\
> >  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
> >  		       pmd_trans_huge(*____pmd));			\
> >  	} while (0)
> 
> That thing was pretty ugly _before_. :)  Any chance this can get turned
> in to a function?

Cyclic headers dependencies... :(

> What's the deal with the i_mmap_mutex operation getting split up?  I'm
> blanking on what kind of pages would have both anon_vmas and a valid
> mapping.

anon_vma_lock protects all anon pages on vma against splitting.
i_mmap_mutex protects shared pages. None pages can be on both sides, but
MAP_PRIVATE file vma can have both anon and shared pages.

As an option we can lookup for struct page with pmd_page(), check
PageAnon() and serialize only relevant lock, but...

Original macro, in fact, guarantees that *all* pages on the vma is not
splitting, not only the pages pmd is poinging on. PageAnon() check will
change semantics a bit. It shouldn't be a problem, but who knows.

Do you want me to add the check?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
