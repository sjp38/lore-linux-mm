Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6D56B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 01:56:01 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id j1so82090474ywj.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 22:56:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q141si3585050ybg.19.2017.01.13.22.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 22:56:00 -0800 (PST)
Date: Sat, 14 Jan 2017 09:55:29 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch v2 linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170114065529.GE15314@mwanda>
References: <20170113082608.GA3548@mwanda>
 <alpine.LSU.2.11.1701131559360.2443@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1701131559360.2443@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, Jan 13, 2017 at 04:02:37PM -0800, Hugh Dickins wrote:
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

Oh wow...  What absolute heck!  I can't believe how badly I'm messing
up on this.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
