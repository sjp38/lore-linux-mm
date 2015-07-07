Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7786B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 15:19:51 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so197680050wid.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 12:19:50 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id r5si44054wix.25.2015.07.07.12.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 12:19:49 -0700 (PDT)
Received: by wgck11 with SMTP id k11so176720703wgc.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 12:19:49 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 7 Jul 2015 12:19:48 -0700
Message-ID: <CAOvWMLakCarg_4V9qPrG-TSUdqqBCBXMhJ3gHUXKNWf0Ym7YGQ@mail.gmail.com>
Subject: Filebench failure on ramdisk with Ext4-DAX
From: Andiry Xu <andiry@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andiry Xu <andiry.xu@gmail.com>

Hi,

I am running into failures when run filebench on ramdisk(/dev/ram0)
with Ext4-DAX.
The kernel version is 4.0, and I also verified it occurs on 4.2-rc1.

The issue reproduction steps:

// Set ramdisk size to 2GB
# mkfs.ext4 /dev/ram0
# mount -o dax /dev/ram0 /mnt/ramdisk
# filebench
filebench> load fileserver
filebench> set $dir=/mnt/ramdisk
filebench> run 30

And filebench fails in a few seconds like this:

8163: 22.992: Failed to pre-allocate file
/mnt/ramdisk/bigfileset/00000001/00000006/00000001/00000024/00000005/00000002/00000006:
No such file or directory on line 128
 8163: 22.992: Failed to create filesets on line 128

Or like this:

8141: 16.372: Failed to write 51967 bytes on fd 23: Success
 8151: 16.372: Failed to write 136735 bytes on fd 18: Success
 8148: 16.372: Failed to write 123317 bytes on fd 31: Success
 8141: 16.381: filereaderthread-36: flowop wrtfile1-1 failed
 8151: 16.381: filereaderthread-46: flowop wrtfile1-1 failed
 8148: 16.381: filereaderthread-43: flowop wrtfile1-1 failed
 8098: 16.521: Run took 1 seconds...
 8098: 16.521: NO VALID RESULTS! Filebench run terminated prematurely on line 65
 8098: 16.521: Shutting down processes

Sometimes it succeeds, but the chance is low. The failure rate is 80%+.

Note:
The issues does not occur with normal Ext4.
The issues does not occur with Ext4-DAX on pmem driver (from 01org/prd).

The only significant difference between brd.c and pmem.c is that brd.c
uses alloc_page() and pmem.c reserved memory range and uses ioremap()
to get virtual address. I assume that the memcpy
operation(copy_from/to_user) directly between user buffer and page by
alloc_page() does not work correctly somehow. I wonder if this is a
bug? If it is, how to fix it? Thanks.

Thanks,
Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
