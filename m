Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 71E456B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 01:06:56 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so2245954ywm.26
        for <linux-mm@kvack.org>; Wed, 27 May 2009 22:07:01 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 May 2009 17:07:01 +1200
Message-ID: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
Subject: Inconsistency (bug) of vm_insert_page with high order allocations
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

Hi,
I have the following issue. I need to allocate a big chunk of
contiguous memory and then transfer it to user mode applications to
let them operate with given buffers.

To allocate memory I use standard function alloc_apges(gfp_mask,
order) which asks buddy allocator to give a chunk of memory of given
"order".
Allocator returns page and also sets page count to 1 but for page of
high order. I.e. pages 2,3 etc inside high order allocation will have
page->_count==0.
If I try to mmap allocated area to user space vm_insert_page will
return error as pages 2,3, etc are not refcounted.

The issue could be workaround if to set-up refcount to 1 manually for
each page. But this workaround is not very good, because page refcount
is used inside mm subsystem only.

While searching a driver with the similar solutions in kernel tree it
was found a driver which suffers from exactly the same
problem("poch"). So it is not single problem.

What you could suggest to workaround the problem except hacks with page count?
May be it makes sence to introduce wm_insert_pages function?

In this case users would have the following picture:
zero order page: alloc_page <-> vm_instert_page
non zero order  : alloc_pages(..., order) <-> vm_instert_pages(...., order)

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
