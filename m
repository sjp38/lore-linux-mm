From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14238.34878.790624.59746@dukat.scot.redhat.com>
Date: Wed, 28 Jul 1999 05:34:06 +0100 (BST)
Subject: [PATCH] Re: mm synchronization question
In-Reply-To: <003101bed81b$1d39dac0$30b16086@sl16es04.phil.uni-sb.de>
References: <003101bed81b$1d39dac0$30b16086@sl16es04.phil.uni-sb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ms <masp0008@stud.uni-sb.de>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 27 Jul 1999 12:30:39 +0200, "ms" <masp0008@stud.uni-sb.de> said:

> I think I found a minor bug: do_wp_page() does not call spin_unlock()
> if called with bad parameters: if "goto bad_wp_page" is executed, then
> noone unlocks the page_table_lock spinlock.

Indeed, that looks like a genuine fault.  Patch below.
 
> My second question is the mm semaphore: It seems that if in a multi
> threaded application several threads access a large mmaped file, that
> then all page-in operations are serialized (including waiting for the
> disk IO). Is that correct?  

Only partially.  The IOs are serialised, but the readahead IOs that the
page faults implicitly trigger are asynchronous to that.

> Are there any plans to change that?

Not right now afaik, but we probably could do it at some point.  It
would be very easy to do a simple solution which allowed concurrent page
faults while still barring mmap()/munmap() operations from colliding
with the fault.

--Stephen

----------------------------------------------------------------
--- mm/memory.c~	Wed Jul 28 00:52:42 1999
+++ mm/memory.c	Wed Jul 28 05:30:48 1999
@@ -846,6 +855,7 @@
 	return 1;
 
 bad_wp_page:
+	spin_unlock(&tsk->mm->page_table_lock);
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	return -1;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
