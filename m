Message-ID: <3910E40B.25FBEED4@sgi.com>
Date: Wed, 03 May 2000 19:44:27 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005031828520.950-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> Ok,
>  there's a pre7-4 out there that does the swapout with the page locked.
> I've given it some rudimentary testing, but certainly nothing really
> exotic. Please comment..

One quick comment: Looking at this part of the diff to mm/vmscan.c:

----------
@@ -138,6 +139,7 @@
                flush_tlb_page(vma, address);
                vmlist_access_unlock(vma->vm_mm);
                error = swapout(page, file);
+               UnlockPage(page);
                if (file) fput(file);
                if (!error)
                        goto out_free_success;
-----------------

Didn't you mean the UnlockPage() to go before swapout(...)?
For example, one of the swapout routines, filemap_write_page()
expects the page to be unlocked. If called with page locked,
I'd expect a "double-trip" dead-lock. Right?

Like you said in an  earlier mail, most of the code in
try_to_swap_out expects the page to be unlocked. Now,
of course, the reverse is true ... need to watch out!

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
