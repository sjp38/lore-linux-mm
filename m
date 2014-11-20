Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7CADB6B0073
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 07:36:15 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so3575324wgg.36
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 04:36:15 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id el10si7121525wid.58.2014.11.20.04.36.14
        for <linux-mm@kvack.org>;
        Thu, 20 Nov 2014 04:36:14 -0800 (PST)
Date: Thu, 20 Nov 2014 14:30:11 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
Message-ID: <20141120123011.GA9716@node.dhcp.inet.fi>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
 <545C2CEE.5020905@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545C2CEE.5020905@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hujianyang <hujianyang@huawei.com>
Cc: dedekind1@gmail.com, Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, "Wanli (welly)" <welly.wan@hisilicon.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>, Jijiagang <jijiagang@hisilicon.com>

On Fri, Nov 07, 2014 at 10:22:38AM +0800, hujianyang wrote:
> Hi,
> 
> I think we found the cause of this problem. We enable CONFIG_CMA in our
> config file. This feature seems to allocate a contiguous memory for caller.
> If some pages in this contiguous area are used by other modules, like UBIFS,
> CMA will migrate these pages to other place. This operation should be
> transparent to the user of old pages. But it is *not true* for UBIFS.
> 
> > 
> > 1. UBIFS wants to make sure that no one marks UBIFS-backed pages (and
> > actually inodes too) as dirty directly. UBIFS wants everyone to ask
> > UBIFS to mark a page as dirty.
> > 
> > 2. This is because for every dirty page, UBIFS needs to reserve certain
> > amount of space on the flash media, because all writes are out-of-place,
> > even when you are changing an existing file.
> > 
> > 3. There are exactly 2 places where UBIFS-backed pages may be marked as
> > dirty:
> > 
> >   a) ubifs_write_end() [->wirte_end] - the file write path
> >   b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path
> 
> line 1160, func try_to_unmap_one() in mm/rmap.c
> 
> ""
>         /* Move the dirty bit to the physical page now the pte is gone. */
>         if (pte_dirty(pteval))
>                 set_page_dirty(page);
> ""
> 
> Here, If the pte of a page is dirty, a directly set_page_dirty() is
> performed and hurt the internal logic of UBIFS.

If the pte is dirty it must be writable too. And to make pte writable
->page_mkwrite() must be called. So it should work fine..

Could you check if the pteval is pte_write() by the time?
And could you provide what says dump_page(page) and dump_vma(vma) while
you are there?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
