Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5E1830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 19:35:21 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id z8so2863798igl.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:35:21 -0700 (PDT)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id pq8si1574180obb.16.2016.04.21.16.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 16:35:20 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com> <571844A1.5080703@hpe.com>
 <20160421070625.GB29068@linux.intel.com>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <571963B5.7050009@hpe.com>
Date: Thu, 21 Apr 2016 19:35:17 -0400
MIME-Version: 1.0
In-Reply-To: <20160421070625.GB29068@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 4/21/2016 3:06 AM, Matthew Wilcox wrote:
> On Wed, Apr 20, 2016 at 11:10:25PM -0400, Toshi Kani wrote:
>> How about moving the function (as is) to mm/huge_memory.c, rename it to
>> get_hugepage_unmapped_area(), which is defined to NULL in huge_mm.h
>> when TRANSPARENT_HUGEPAGE is unset?
> Great idea.  Perhaps it should look something like this?

Yes, it looks good! I will use it. :-)

>
> unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
>                  unsigned long len, unsigned long pgoff, unsigned long flags)
> {
>          loff_t off, off_end, off_pmd;
>          unsigned long len_pmd, addr_pmd;
>
>          if (addr)
>                  goto out;
>          if (IS_DAX(filp->f_mapping->host) && !IS_ENABLED(CONFIG_FS_DAX_PMD))
>                  goto out;
>          /* Kirill, please fill in the right condition here for THP pagecache */
>
>          off = (loff_t)pgoff << PAGE_SHIFT;
>          off_end = off + len;
>          off_pmd = round_up(off, PMD_SIZE);      /* pmd-aligned start offset */
>
>          if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))
>                  goto out;
>
>          len_pmd = len + PMD_SIZE;
>          if ((off + len_pmd) < off)
>                  goto out;
>
>          addr_pmd = current->mm->get_unmapped_area(filp, NULL, len_pmd,
>                                                  pgoff, flags);
>          if (!IS_ERR_VALUE(addr_pmd)) {
>                  addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
>                  return addr_pmd;
>          }
>   out:
>          return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
> }
>
>   - I deleted the check for filp == NULL.  It can't be NULL ... this is a
>     file_operation ;-)

Right.

>   - Why is len_pmd len + PMD_SIZE instead of round_up(len, PMD_SIZE)?

The length is padded with an extra-PMD size so that any assigned address 
'addr_pmd'
can be aligned by PMD.  IOW, it does not make an assumption that 
addr_pmd is aligned
by the length.

>   - I'm still in two minds about passing 'addr' to the first call to
>     get_unmapped_area() instead of NULL.

When 'addr' is specified, we need to use 'len' since user may be 
managing free VMA
range by itself.  So, I think falling back with the original args is 
correct.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
