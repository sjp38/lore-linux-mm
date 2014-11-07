Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 554256B00DD
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 21:24:11 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2519629pab.28
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 18:24:11 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m5si7527188pdp.225.2014.11.06.18.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 18:24:09 -0800 (PST)
Message-ID: <545C2CEE.5020905@huawei.com>
Date: Fri, 7 Nov 2014 10:22:38 +0800
From: hujianyang <hujianyang@huawei.com>
MIME-Version: 1.0
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com> <1413805935.7906.225.camel@sauron.fi.intel.com> <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com> <1413810719.7906.268.camel@sauron.fi.intel.com>
In-Reply-To: <1413810719.7906.268.camel@sauron.fi.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dedekind1@gmail.com
Cc: Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, "Wanli (welly)" <welly.wan@hisilicon.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>, Jijiagang <jijiagang@hisilicon.com>

Hi,

I think we found the cause of this problem. We enable CONFIG_CMA in our
config file. This feature seems to allocate a contiguous memory for caller.
If some pages in this contiguous area are used by other modules, like UBIFS,
CMA will migrate these pages to other place. This operation should be
transparent to the user of old pages. But it is *not true* for UBIFS.

> 
> 1. UBIFS wants to make sure that no one marks UBIFS-backed pages (and
> actually inodes too) as dirty directly. UBIFS wants everyone to ask
> UBIFS to mark a page as dirty.
> 
> 2. This is because for every dirty page, UBIFS needs to reserve certain
> amount of space on the flash media, because all writes are out-of-place,
> even when you are changing an existing file.
> 
> 3. There are exactly 2 places where UBIFS-backed pages may be marked as
> dirty:
> 
>   a) ubifs_write_end() [->wirte_end] - the file write path
>   b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path

line 1160, func try_to_unmap_one() in mm/rmap.c

""
        /* Move the dirty bit to the physical page now the pte is gone. */
        if (pte_dirty(pteval))
                set_page_dirty(page);
""

Here, If the pte of a page is dirty, a directly set_page_dirty() is
performed and hurt the internal logic of UBIFS.

So I have a question, why the page needs to be marked as dirty when
the pte is dirty? Can we just move the dirty bit of the old pte to the
new one without setting the dirty bit of the page? I think the dirty
bit of a page is used to mark the contents of this page is different
from it is in storage. Can we just set it without informing filesyetem?

Could any one in MM list show us some reasons of this performing or
give us some help?

> 
> 4. If anything calls 'ubifs_set_page_dirty()' directly (not through
> write_end()/mkwrite()), and the page was not dirty, UBIFS will complain
> with the assertion that you see.
> 

To Artem, I have an idea to fix this problem without changing mm files.
We can:

1) Add a .migratepage in address_space_operations and do budget in it.
2) As CMA perform set_page_dirty() before migratepage, we seems to remove
   the assert failed in ubifs_set_page_dirty().

Just some thoughts, not a clear solution.

I should say I don't want to do this because it will change some logic
in UBIFS. So I think the best way to solve this problem is to change
the MM operations.

Thanks!

Hu



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
