From: bsuparna@in.ibm.com
Message-ID: <CA256A55.0030926D.00@d73mta02.au.ibm.com>
Date: Wed, 23 May 2001 14:06:10 +0530
Subject: Re: About swapper_page_dir and processes' page directory
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hji@netscreen.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I didn't notice any replies to this post on the mailing list, so just
mentioning the rough idea I have ...
In earlier versions of the kernel, when vmalloc made changes to the
page_dir (in the init_mm reference pgd), it used to propagate the changes
to the page_dir entries for the tasks in the task list (traversing the
entire list).
However, this approach has now given way to a lazy updation technique,
where the page_dir entries for tasks get refereshed from the reference mm
structure only on demand. In this case, whenever a vmalloced area is
accessed, and the current task's corresponding page_dir entry hasn't been
updated, a page fault would occur. The kernel would recognize this as a
vmalloc related fault and refresh the entry from the reference page table
at this point. Thus, it is sufficient for vmalloc to update the reference
page dir entry.
Does this answer your question ?

Regards
Suparna

>List:     linux-mm
>Subject:  About swapper_page_dir and processes' page directory
>From:     Hua Ji <hji@netscreen.com>
>Date:     2001-05-18 17:47:48
>[Download message RAW]
>
>Folks,
>
>Get a question today. Thanks in advance.
>
>As we know, vmalloc and other memory allocation/de-allocation will
>change/update
>the swapper_page_dir maintain by the kernel.
>
>I am wondering when/how the kernel synchronzie the change to user level
>processes' page
>directory entries from the 768th to the 1023th.
>
>Those entries get copied from swapper_page_dir when a user process get
>forked/created. Does the kernel
>frequently update this information every time when the swapper_page_dir
get
>changed?
>



>Regards,
>
>Mike

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux.eu.org/Linux-MM/

[prev in list] [next in list] [prev in thread] [next in thread]


  Suparna Bhattacharya
  IBM Software Lab, India
  E-mail : bsuparna@in.ibm.com
  Phone : 91-80-5267117, Extn : 2525


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
