From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906212344.QAA93017@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Mon, 21 Jun 1999 16:44:34 -0700 (PDT)
In-Reply-To: <199906211846.LAA91751@google.engr.sgi.com> from "Kanoj Sarcar" at Jun 21, 99 11:46:27 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

And continuing on with the problems with swapoff ...

While forking, we copy swap handles from the parent into the child
in copy_page_range. There are of course sleep point in dup_mmap
(kmem_cache_alloc would be one, vm_ops->open could be another). 

A swapoff coming in at this point might scan the process list, not
find the nascent child, and just delete the device, leaving the
child referencing the old swap handles.

Irregardless of our current discussions about why the mmap_sem 
is needed in swapoff to protect ptes, it seems that grabbing it
in swapoff could trivially solve this fork race ... and some code
changes in exit_mmap could also fix the exit race ...

Kanoj
kanoj@engr.sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
