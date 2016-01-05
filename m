Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id DAE1F6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 15:58:15 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so47892450wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 12:58:15 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id ci1si154652187wjc.27.2016.01.05.12.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 12:58:14 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id u188so38112247wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 12:58:14 -0800 (PST)
Date: Tue, 5 Jan 2016 22:58:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Does vm_operations_struct require a .owner field?
Message-ID: <20160105205812.GA24738@node.shutemov.name>
References: <Pine.LNX.4.44L0.1601051024110.1666-100000@iolanthe.rowland.org>
 <Pine.LNX.4.44L0.1601051108300.1666-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1601051108300.1666-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, David Laight <David.Laight@ACULAB.COM>, "'Steinar H. Gunderson'" <sesse@google.com>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>

On Tue, Jan 05, 2016 at 11:27:45AM -0500, Alan Stern wrote:
> Hello:
> 
> Question: The vm_operations_struct structure contains lots of callback
> pointers.  Is there any mechanism to prevent the callback routines and
> the structure itself being unloaded from memory (if they are built into
> modules) while the relevant VMAs are still in use?
> 
> Consider a simple example: A user program calls mmap(2) on a device
> file.  Later on, the file is closed and the device driver's module is
> unloaded.  But until munmap(2) is called or the user program exits, the
> memory mapping and the corresponding VMA will remain in existence.  
> (The man page for munmap specifically says "closing the file descriptor
> does not unmap the region".)  Thus when the user program does do an
> munmap(), the callback to vma->vm_ops->close will reference nonexistent
> memory and cause an oops.
> 
> Normally this sort of thing is prevented by try_module_get(...->owner).  
> But vm_operations_struct doesn't include a .owner field.
> 
> Am I missing something here?

mmap(2) takes reference of the file, therefore the file is not closed from
kernel POV until vma is gone and you cannot unload relevant module.
See get_file() in mmap_region().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
