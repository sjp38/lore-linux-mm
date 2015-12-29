Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1DC6B0279
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 06:27:26 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so7830368wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 03:27:26 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id ee2si103526364wjd.88.2015.12.29.03.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 03:27:24 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id f206so38435640wmf.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 03:27:24 -0800 (PST)
Date: Tue, 29 Dec 2015 13:27:22 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] mm: stop __munlock_pagevec_fill() if THP enounted
Message-ID: <20151229112722.GA6260@node.shutemov.name>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20151228152235.e756a78f4553ce38ca0e0b4d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151228152235.e756a78f4553ce38ca0e0b4d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Mon, Dec 28, 2015 at 03:22:35PM -0800, Andrew Morton wrote:
> On Thu, 24 Dec 2015 14:51:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > THP is properly handled in munlock_vma_pages_range().
> > 
> > It fixes crashes like this:
> >  http://lkml.kernel.org/r/565C5C38.3040705@oracle.com
> > 
> > ...
> >
> > --- a/mm/mlock.c
> > +++ b/mm/mlock.c
> > @@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
> >  		if (!page || page_zone_id(page) != zoneid)
> >  			break;
> >  
> > +		/*
> > +		 * Do not use pagevec for PTE-mapped THP,
> > +		 * munlock_vma_pages_range() will handle them.
> > +		 */
> > +		if (PageTransCompound(page))
> > +			break;
> > +
> >  		get_page(page);
> >  		/*
> >  		 * Increase the address that will be returned *before* the
> 
> I'm trying to work out approximately which patch this patch fixes, and
> it ain't easy.  Help?

"thp: allow mlocked THP again", I think.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
