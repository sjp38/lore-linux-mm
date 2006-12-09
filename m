Received: by an-out-0708.google.com with SMTP id b38so172410ana
        for <linux-mm@kvack.org>; Sat, 09 Dec 2006 04:53:33 -0800 (PST)
Message-ID: <45a44e480612090453j5fe92b9cx23fb2c28ad5f57@mail.gmail.com>
Date: Sat, 9 Dec 2006 07:53:33 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Deleting PTEs for deferred IO for framebuffers
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm experimenting with trying to do some deferred IO for framebuffers.
This is associated with trying to support the hecubafb/E-Ink driver.
http://marc.theaimsgroup.com/?l=linux-fbdev-devel&m=116357495806415&w=2
The usage scenario is like this:
- userspace app mmaps framebuffer
- driver handles and sets up a nopage handler
- app tries to write to mmaped vaddress
- get pagefault and reaches driver's nopage handler
- driver's nopage handler saves vma and vaddress, finds and returns
physical page ( not actual framebuffer )
- also schedules a workqueue task
- app continues writing to that page
- the workqueue task comes in and unmaps the page, then completes the
slow work associated with updating the framebuffer
- app tries to write to the previously mapped address (that has now
been unmapped)
- get pagefault and the above sequence occurs again
The desire is to allow bursty framebuffer updates to all occur. Then
when things are quiet, we go and update the framebuffer. This is
helpful for specific types of framebuffers and possibly other devices
where only the final result in memory is desired and IO is slow or
expensive in terms of power usage or both.

My question in trying to implement above is how to delete pte-s. Is
there a recommended way to delete a pte from code outside linux/mm? I
have the app's vma and the vaddress from when it initially faults
through a nopage. I think i could do work similar to
remove_migration_pte(). That is, spin_lock(vma->lock),
pgd/pud/pmd/pte_offset and then pte_unmap. then unlock.
I may be quite stupid so I might be missing the simple proper way to
do this. I'd appreciate any help or feedback.

Thanks,
jayakumar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
