Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 814246B0009
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:34:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v21so5765588wmh.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:34:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k8sor7698062ede.40.2018.03.06.00.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:34:41 -0800 (PST)
Date: Tue, 6 Mar 2018 11:34:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 18/22] x86/mm: Handle allocation of encrypted pages
Message-ID: <20180306083425.gwt7j5cxtd6vrd3r@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
 <e2fed2a7-88db-96f0-56f5-b20b624eb665@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2fed2a7-88db-96f0-56f5-b20b624eb665@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:03:55AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > -#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
> > -	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
> >  #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
> > +#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr)			\
> > +({										\
> > +	struct page *page;							\
> > +	gfp_t gfp = movableflags | GFP_HIGHUSER;				\
> > +	if (vma_is_encrypted(vma))						\
> > +		page = __alloc_zeroed_encrypted_user_highpage(gfp, vma, vaddr);	\
> > +	else									\
> > +		page = alloc_page_vma(gfp | __GFP_ZERO, vma, vaddr);		\
> > +	page;									\
> > +})
> 
> This is pretty darn ugly and also adds a big old branch into the hottest
> path in the page allocator.
> 
> It's also really odd that you strip __GFP_ZERO and then go ahead and
> zero the encrypted page unconditionally.  It really makes me wonder if
> this is the right spot to be doing this.
> 
> Can we not, for instance do it inside alloc_page_vma()?

Yes we can.

It would require substantial change into page allocation path for
CONFIG_NUMA=n as we don't path down vma at the moment. And without vma we
don't have a way to know which KeyID to use.

I will explore how it would fit together.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
