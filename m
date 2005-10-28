Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9SChTh8024770
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 08:43:29 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9SChTuX120752
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 08:43:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9SChS9M013696
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 08:43:29 -0400
Message-ID: <43621CFE.5080900@de.ibm.com>
Date: Fri, 28 Oct 2005 14:43:42 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: Fwd: Re: VM_XIP Request for comments
References: <200510281155.03466.christian@borntraeger.net>
In-Reply-To: <200510281155.03466.christian@borntraeger.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, cotte@de.ibm.com
List-ID: <linux-mm.kvack.org>

> I can't find CONFIG_XIP.  But I assume you are talking about
> filemap_xip.c and Documentation/filesystems/xip.txt.
Actually the thing consists of three parts:
- a block device that does implement the direct_access method. so far
  the only driver that does that is drivers/s390/block/dcssblk.c. We
  are aware that this one needs cleanup ;-).
- extension to good old ext2 filesystem that does implement get_xip_page
  address space operation. Uses direct_access block device operation.
- the stuff in mm/filemap_xip.c which actually does the job (read,write,
  mmap etc.) by calling get_xip_page address space operation.

> I don't know. The code and discussions about it looked very big-iron
> DSCC specific but now on second pass it was meant to more generic.  If
> I can learn this infrastructure then maybe this will work.
The only part that is architecture specific is the block device driver.
Both the ext2 extensions and filemap_xip are architecture independent.

> So I'm supposed to create a function in the target fs that gets
> plugged into get_xip_page().  Then I call that function to create an
> proper XIP'ed page in my mmap() and fread() calls.  I could use the
> first arg of get_xip_page() to pass in the start address of the cramfs
> volume and the second the offset of the page in the file I want to
> map.
> 
> Is that about right?
The first step would be to write a block device driver that allows to
mount your memory backed storage thing [flash chip?]. The block device
driver needs to implement the direct_access method. Now you can mount
ext2 filesystems with -o xip.

Ext2 does not support compression, and all files are xip once you
select -o xip. Would be interresting to have a filesystem that can do
both xip and compression on a per-file basis, but as far as I can tell
the basic layering should also work fine with such filesystem: should
work with any block device, file operations in filemap_xip.c can be
used for those files that are xip [and not compressed].
-- 

Carsten Otte
IBM Linux technology center
ARCH=s390

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
