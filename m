Received: from sgi.com (sgi.SGI.COM [192.48.153.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA03244
	for <linux-mm@kvack.org>; Tue, 1 Jun 1999 17:25:12 -0400
Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id OAA06991
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Tue, 1 Jun 1999 14:25:06 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: from google.engr.sgi.com (google.engr.sgi.com [192.48.174.30])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id OAA17005
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Tue, 1 Jun 1999 14:25:05 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: (from kanoj@localhost) by google.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) id OAA94606 for linux-mm@kvack.org; Tue, 1 Jun 1999 14:25:05 -0700 (PDT)
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906012125.OAA94606@google.engr.sgi.com>
Subject: Is expand_stack buggy wrt locked_vm?
Date: Tue, 1 Jun 1999 14:25:05 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think there might be a problem with the way expand_stack
updates locked_vm. 

Assume the kernel is trying to copyout some amount(512b) of 
data into the user's stack, and the underlying pages are not 
yet allocated, and the stack is marked VM_LOCKED. The page 
fault will trigger an expand_stack, which will update the 
locked_vm by an amount depending on where the kernel is trying 
to write out the data. Back in the fault handling code, 
handle_mm_fault will allocate just one page and be done. So,
although the process has incremented its number of locked pages
by 1, expand_stack has updated locked_vm by a possibly bigger
amount.

I think the right fix is for expand_stack to fault in all the
intermediate pages, by something like

	if (vma->vm_flags & VM_LOCKED) {
		make_pages_present(address, old vma->vm_start);
	}

Comments?

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
