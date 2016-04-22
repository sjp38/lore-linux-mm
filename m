Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29AE0830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 20:59:42 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m2so235774588ioa.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:59:42 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id b9si1653766oia.127.2016.04.21.17.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 17:59:41 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com> <571844A1.5080703@hpe.com>
 <20160421070625.GB29068@linux.intel.com> <57193658.9020803@oracle.com>
 <571965AB.9070707@hpe.com> <20160422002236.GE29068@linux.intel.com>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <5719777A.4050400@hpe.com>
Date: Thu, 21 Apr 2016 20:59:38 -0400
MIME-Version: 1.0
In-Reply-To: <20160422002236.GE29068@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>


On 4/21/2016 8:22 PM, Matthew Wilcox wrote:
> On Thu, Apr 21, 2016 at 07:43:39PM -0400, Toshi Kani wrote:
>> On 4/21/2016 4:21 PM, Mike Kravetz wrote:
>>> Might want to keep the future possibility of PUD_SIZE THP in mind?
>> Yes, this is why the func name does not say 'pmd'. It can be extended to
>> support
>> PUD_SIZE in future.
> Sure ... but what does that look like?  I think it should look a little
> like this:

Yes, I had something similar in mind, too.  Do you want me to use this 
version without the call with PUD_SIZE?

>
> unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
>                          loff_t off, unsigned long flags, unsigned long size);
> {
>          unsigned long addr;
>          loff_t off_end = off + len;
>          loff_t off_align = round_up(off, size);
>          unsigned long len_size;
>
>          if ((off_end <= off_align) || ((off_end - off_align) < size))
>                  return NULL;
>
>          len_size = len + size;
>          if ((len_size < len) || (off + len_size) < off)
>                  return NULL;
>
>          addr = current->mm->get_unmapped_area(filp, NULL, len_size,
>                                                  off >> PAGE_SHIFT, flags);
>          if (IS_ERR_VALUE(addr))
>                  return NULL;
>   
>          addr += (off - addr) & (size - 1);
>          return addr;
> }
>
> unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
>                  unsigned long len, unsigned long pgoff, unsigned long flags)
> {
>          loff_t off = (loff_t)pgoff << PAGE_SHIFT;
>
>          if (addr)
>                  goto out;
>          if (IS_DAX(filp->f_mapping->host) && !IS_ENABLED(CONFIG_FS_DAX_PMD))
>                  goto out;
>          /* Kirill, please fill in the right condition here for THP pagecache */
>
>          addr = __thp_get_unmapped_area(filp, len, off, flags, PUD_SIZE);
>          if (addr)
>                  return addr;
>          addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
>          if (addr)
>                  return addr;
>
>   out:
>          return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
> }
>
> By the way, I added an extra check here, when we add len and size
> (PMD_SIZE in the original), we need to make sure that doesn't wrap.
> NB: I'm not even compiling these suggestions, just throwing them out
> here as ideas to be criticised.

Yes, I agree with the extra check.  Thanks for pointing this out.

>
> Also, len_size is a stupid name, but I can't think of a better one.

How about len_pad?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
