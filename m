Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 62D3D6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 11:27:47 -0500 (EST)
Received: by mail-qk0-f177.google.com with SMTP id q19so87048000qke.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:27:47 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id a192si25758281qkb.70.2016.01.05.08.27.46
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 08:27:46 -0800 (PST)
Date: Tue, 5 Jan 2016 11:27:45 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Does vm_operations_struct require a .owner field?
In-Reply-To: <Pine.LNX.4.44L0.1601051024110.1666-100000@iolanthe.rowland.org>
Message-ID: <Pine.LNX.4.44L0.1601051108300.1666-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel development list <linux-kernel@vger.kernel.org>, David Laight <David.Laight@ACULAB.COM>, "'Steinar H. Gunderson'" <sesse@google.com>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>

Hello:

Question: The vm_operations_struct structure contains lots of callback
pointers.  Is there any mechanism to prevent the callback routines and
the structure itself being unloaded from memory (if they are built into
modules) while the relevant VMAs are still in use?

Consider a simple example: A user program calls mmap(2) on a device
file.  Later on, the file is closed and the device driver's module is
unloaded.  But until munmap(2) is called or the user program exits, the
memory mapping and the corresponding VMA will remain in existence.  
(The man page for munmap specifically says "closing the file descriptor
does not unmap the region".)  Thus when the user program does do an
munmap(), the callback to vma->vm_ops->close will reference nonexistent
memory and cause an oops.

Normally this sort of thing is prevented by try_module_get(...->owner).  
But vm_operations_struct doesn't include a .owner field.

Am I missing something here?

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
