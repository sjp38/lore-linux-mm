Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 482066B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 18:14:43 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id ar1so764031iec.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 15:14:43 -0800 (PST)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id h8si310073icd.19.2015.01.06.15.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 15:14:42 -0800 (PST)
Received: by mail-ie0-f169.google.com with SMTP id y20so782377ier.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 15:14:41 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 6 Jan 2015 15:14:41 -0800
Message-ID: <CAOvWMLZkisXOcxwo6AvKnwG_pEybmB27ZHUiUppcHNGM=c_cDg@mail.gmail.com>
Subject: MAP_POPULATE does not work with XIP on ramdisk
From: Andiry Xu <andiry@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>
Cc: Andiry Xu <andiry.xu@gmail.com>

Hi,

I'm testing mmap() performance on a ramdisk. The kernel is 3.19-rc3.

The device driver is brd, and the file system is ext2. Normal mmap()
does not make sense on a ramdisk because it adds additional memory
copy, so XIP is enabled to map the pages directly into application's
address space.

With XIP, MAP_POPULATE flag does not work. i.e. prefault fails.
Basically it fails in vm_normal_page(), where it's supposed to find
the struct page from pfn, but the vma has flag VM_MIXEDMAP and the
method returns NULL.

As I understand, VM_MIXEDMAP means the memory may not contain a struct
page backing, so the code logic is reasonable. However brd driver does
provide struct page for each memory page. If I modify the
__get_user_pages() and let the prefault runs for all the pages,
MAP_POPULATE works as expected.

My question is, is there any elegant way to workaround this? I do want
to make MAP_POPULATE works with XIP. This is because as the device is
memory and access latency is pretty low, page fault as well as the
mode switch play an important part in the software overhead. In my
experiment, MAP_POPULATE provides a 3x improvement on latency when
access a big file for the first time.

Thanks,
Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
