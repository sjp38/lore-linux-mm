Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8F36B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 16:31:11 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so198803878qgf.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 13:31:11 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id t37si65527323qgt.88.2016.01.05.13.31.10
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 13:31:10 -0800 (PST)
Date: Tue, 5 Jan 2016 16:31:09 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Does vm_operations_struct require a .owner field?
In-Reply-To: <20160105205812.GA24738@node.shutemov.name>
Message-ID: <Pine.LNX.4.44L0.1601051619200.1350-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, David Laight <David.Laight@ACULAB.COM>, "'Steinar H. Gunderson'" <sesse@google.com>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>

On Tue, 5 Jan 2016, Kirill A. Shutemov wrote:

> On Tue, Jan 05, 2016 at 11:27:45AM -0500, Alan Stern wrote:
> > Hello:
> > 
> > Question: The vm_operations_struct structure contains lots of callback
> > pointers.  Is there any mechanism to prevent the callback routines and
> > the structure itself being unloaded from memory (if they are built into
> > modules) while the relevant VMAs are still in use?
> > 
> > Consider a simple example: A user program calls mmap(2) on a device
> > file.  Later on, the file is closed and the device driver's module is
> > unloaded.  But until munmap(2) is called or the user program exits, the
> > memory mapping and the corresponding VMA will remain in existence.  
> > (The man page for munmap specifically says "closing the file descriptor
> > does not unmap the region".)  Thus when the user program does do an
> > munmap(), the callback to vma->vm_ops->close will reference nonexistent
> > memory and cause an oops.
> > 
> > Normally this sort of thing is prevented by try_module_get(...->owner).  
> > But vm_operations_struct doesn't include a .owner field.
> > 
> > Am I missing something here?
> 
> mmap(2) takes reference of the file, therefore the file is not closed from
> kernel POV until vma is gone and you cannot unload relevant module.
> See get_file() in mmap_region().

Thank you.  So it looks like I was worried about nothing.

Steinar, you can remove the try_module_get/module_put lines from your
patch.  Also, the list_del() and comment in usbdev_release() aren't 
needed -- at that point we know the memory_list has to be empty since 
there can't be any outstanding URBs or VMA references.  If you take 
those things out then the patch should be ready for merging.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
