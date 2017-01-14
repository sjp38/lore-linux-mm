Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31AE66B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 19:13:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so161854836pfb.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 16:13:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si14129858pfj.202.2017.01.13.16.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 16:13:35 -0800 (PST)
Date: Fri, 13 Jan 2017 16:13:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2 linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-Id: <20170113161334.54b60e832af9fb0c51307806@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1701131559360.2443@eggly.anvils>
References: <20170113082608.GA3548@mwanda>
	<alpine.LSU.2.11.1701131559360.2443@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, 13 Jan 2017 16:02:37 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> On Fri, 13 Jan 2017, Dan Carpenter wrote:
> 
> > kunmap_atomic() and kunmap() take different pointers.  People often get
> > these mixed up.
> > 
> > Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > v2: I was also unmapping the wrong pointer because I had a typo.
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 6012a05..aca8ef6 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
> >  				(const void __user *)(src + i * PAGE_SIZE),
> >  				PAGE_SIZE);
> >  		if (allow_pagefault)
> > -			kunmap(page_kaddr);
> > +			kunmap(page_kaddr + i);
> >  		else
> >  			kunmap_atomic(page_kaddr);
> 
> I think you need to look at that again.
> 

um, yup.

--- a/mm/memory.c~userfaultfd-hugetlbfs-fix-__mcopy_atomic_hugetlb-retry-error-processing-fix-fix
+++ a/mm/memory.c
@@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct pag
 				(const void __user *)(src + i * PAGE_SIZE),
 				PAGE_SIZE);
 		if (allow_pagefault)
-			kunmap(page_kaddr + i);
+			kunmap(dst_page + i);
 		else
 			kunmap_atomic(page_kaddr);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
