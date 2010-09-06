Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 305C26B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 00:49:44 -0400 (EDT)
Received: from out.poczta.wp.pl (HELO localhost) ([212.77.101.240])
          (envelope-sender <zenblu@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with SMTP
          for <linux-mm@kvack.org>; 6 Sep 2010 06:49:41 +0200
Date: Mon, 06 Sep 2010 06:49:41 +0200
From: "zenek blus" <zenblu@wp.pl>
Subject: Calling vm_ops->open from a driver / reusing vma memory with
 vm_ops in other drivers
Message-ID: <4c8472e5c36922.92225774@wp.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,
I have the following problem:

Driver A has a custom mmap() implementation and assigns own vm_ops to a 
created vma.
The process which called mmap() passes the resulting userspace address 
to another
driver, driver B.

Driver B would then like to increment usage count on that memory for a 
duration of
some operation, i.e. call vm_ops->open(). It can find_vma() for the 
userspace address
it was given and call vm_ops->open() on found vma. It can then call 
vm_ops->close()
when finished.

The problem here though is that the found vm_area_struct (and the 
userspace address
for that matter) might not be valid anymore by the time driver B wants 
to call close().
There can be three possibilities here:

a) vm_area_struct used for open() is still present and can be reused for 
close()
- that looks ok, but storing a pointer to that vma is risky, driver B 
has no way to
know whether the pointer is still valid.

b) some other vm_area_structs are still present, but driver B has no 
knowledge
about them - so it does not have anything to pass to close().

c) no vm_area_structs remain, but since we called open() before, driver 
A is still
waiting for driver B to call close(); driver B does not have anything to 
pass to
close() and there is nothing in the system that could be passed to it 
anyway.

I don't suppose copying aside the whoe vm_area_struct used for open() 
call and passing
it back to close() is a good idea. Is there any way to do this? Or maybe 
I have it all
wrong?

Thank you,
Zenek


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
