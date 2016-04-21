Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2BB830A3
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:21:54 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id f185so179894552vkb.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 13:21:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u141si701094vkd.163.2016.04.21.13.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 13:21:53 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com> <571844A1.5080703@hpe.com>
 <20160421070625.GB29068@linux.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <57193658.9020803@oracle.com>
Date: Thu, 21 Apr 2016 13:21:44 -0700
MIME-Version: 1.0
In-Reply-To: <20160421070625.GB29068@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Toshi Kani <toshi.kani@hpe.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@ml01.01.org, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, tytso@mit.edu, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com

On 04/21/2016 12:06 AM, Matthew Wilcox wrote:
> On Wed, Apr 20, 2016 at 11:10:25PM -0400, Toshi Kani wrote:
>> How about moving the function (as is) to mm/huge_memory.c, rename it to
>> get_hugepage_unmapped_area(), which is defined to NULL in huge_mm.h
>> when TRANSPARENT_HUGEPAGE is unset?
> 
> Great idea.  Perhaps it should look something like this?
> 
> unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
>                 unsigned long len, unsigned long pgoff, unsigned long flags)
> {

Might want to keep the future possibility of PUD_SIZE THP in mind?
-- 
Mike Kravetz

>         loff_t off, off_end, off_pmd;
>         unsigned long len_pmd, addr_pmd;
> 
>         if (addr)
>                 goto out;
>         if (IS_DAX(filp->f_mapping->host) && !IS_ENABLED(CONFIG_FS_DAX_PMD))
>                 goto out;
>         /* Kirill, please fill in the right condition here for THP pagecache */
> 
>         off = (loff_t)pgoff << PAGE_SHIFT;
>         off_end = off + len;
>         off_pmd = round_up(off, PMD_SIZE);      /* pmd-aligned start offset */
> 
>         if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))
>                 goto out;
> 
>         len_pmd = len + PMD_SIZE;
>         if ((off + len_pmd) < off)
>                 goto out;
> 
>         addr_pmd = current->mm->get_unmapped_area(filp, NULL, len_pmd,
>                                                 pgoff, flags);
>         if (!IS_ERR_VALUE(addr_pmd)) {
>                 addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
>                 return addr_pmd;
>         }
>  out:
>         return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
> }
> 
>  - I deleted the check for filp == NULL.  It can't be NULL ... this is a
>    file_operation ;-)
>  - Why is len_pmd len + PMD_SIZE instead of round_up(len, PMD_SIZE)?
>  - I'm still in two minds about passing 'addr' to the first call to
>    get_unmapped_area() instead of NULL.
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
