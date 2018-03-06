Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 020CD6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:54:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z14so12915579wrh.1
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:54:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p54sor249972edc.22.2018.03.06.00.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:54:28 -0800 (PST)
Date: Tue, 6 Mar 2018 11:54:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Message-ID: <20180306085412.vkgheeya24dze53t@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:07:16AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> > +{
> > +	int i;
> > +	void *v;
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		v = kmap_atomic_keyid(page, keyid + i);
> > +		/* See comment in prep_encrypt_page() */
> > +		clflush_cache_range(v, PAGE_SIZE);
> > +		kunmap_atomic(v);
> > +	}
> > +}
> 
> Have you measured how slow this is?

No, I have not.

> It's an optimization, but can we find a way to only do this dance when
> we *actually* change the keyid?  Right now, we're doing mapping at alloc
> and free, clflushing at free and zeroing at alloc.  Let's say somebody does:
> 
> 	ptr = malloc(PAGE_SIZE);
> 	*ptr = foo;
> 	free(ptr);
> 
> 	ptr = malloc(PAGE_SIZE);
> 	*ptr = bar;
> 	free(ptr);
> 
> And let's say ptr is in encrypted memory and that we actually munmap()
> at free().  We can theoretically skip the clflush, right?

Yes we can. Theoretically. We would need to find a way to keep KeyID
around after the page is removed from rmap. That's not so trivial as far
as I can see.

I will look into optimization after I'll got functionality in place.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
