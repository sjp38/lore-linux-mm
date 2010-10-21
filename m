Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C5BE45F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 11:36:26 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1P8ww0-0006iK-TF
	for linux-mm@kvack.org; Thu, 21 Oct 2010 17:20:04 +0200
Received: from notekemper36.informatik.tu-muenchen.de ([131.159.16.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 17:20:04 +0200
Received: from tneumann by notekemper36.informatik.tu-muenchen.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 17:20:04 +0200
From: Thomas Neumann <tneumann@users.sourceforge.net>
Subject: Linux fork performance degrades
Date: Thu, 21 Oct 2010 17:14:46 +0200
Message-ID: <i9pld7$2mt$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have some problems with fork performance in large processes. This can be 
observed quite easily, simply allocate some chunk of memory, write to it (to 
make sure that the pages are really allocated), and then fork repeatedly and 
measure the runtime.
On a 64GB 8 core system I observe the following fork times depending on the 
process size:

  409MB   7ms
 4096MB  34ms
40960MB 344ms

which means that we spend nearly have a second forking a large process. And 
we are currently starting to use a machine with 512GB main memory, which 
means that we expect to spend multiple seconds for a fork!

The reason for this growth is the page table, of course, which is copied 
during the fork. One way around this is to use large pages (which brings 
down fork duration back to acceptable levels), but this is highly 
inconvenient for a number of reasons: First, large pages have to be pre-
registered with the system, which is a pain. Second, we use fork for a 
reason, and using large pages means that we copy 2MB pages around at every 
new write, which is bad. And finally, the user code gets much more 
complicated when having to deal with different kinds of memory.

I think a much better approach would be to avoid copying the whole page 
table, as most of the pages will be shared between the processes anyway 
(i.e., to extend copy-on-write to the page table itself). Dave McCracken has 
worked on this in the past, but his patches are unfortunately very old (in 
particular the ones that can handle private, anonymous memory).
Therefore I ask the list, is someone currently working on a similar 
mechanism or has perhaps a different idea how to solve this issue?

Thomas




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
