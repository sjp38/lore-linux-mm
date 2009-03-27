Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4715A6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:53:48 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2RFACxi012856
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFABTp4116714
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:11 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFAB2l015187
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:11 +0100
Message-Id: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:05 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/6] Guest page hinting version 7.
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Greetings,
the circus is back in town -- another version of the guest page hinting
patches. The patches differ from version 6 only in the kernel version,
they apply against 2.6.29. My short sniff test showed that the code
is still working as expected.

To recap (you can skip this if you read the boiler plate of the last
version of the patches):
The main benefit for guest page hinting vs. the ballooner is that there
is no need for a monitor that keeps track of the memory usage of all the
guests, a complex algorithm that calculates the working set sizes and for
the calls into the guest kernel to control the size of the balloons.
The host just does normal LRU based paging. If the host picks one of the
pages the guest can recreate, the host can throw it away instead of writing
it to the paging device. Simple and elegant.
The main disadvantage is the added complexity that is introduced to the
guests memory management code to do the page state changes and to deal
with discard faults.


Right after booting the page states on my 256 MB z/VM guest looked like
this (r=resident, p=preserved, z=zero, S=stable, U=unused,
P=potentially volatile, V=volatile):

<state>|--tot--|---r---|---p---|---z---|
    S  |  19719|  19673|      0|     46|
    U  | 235416|   2734|      0| 232682|
    P  |      1|      1|      0|      0|
    V  |   7008|   7008|      0|      0|
tot->  | 262144|  29416|      0| 232728|

about 25% of the pages are in voltile state. After grepping through the
linux source tree this picture changes:

<state>|--tot--|---r---|---p---|---z---|
    S  |  43784|  43744|      0|     40|
    U  |  78631|   2397|      0|  76234|
    P  |      2|      2|      0|      0|
    V  | 139727| 139727|      0|      0|
tot->  | 262144| 185870|      0|  76274|

about 75% of the pages are now volatile. Depending on the workload you
will get different results.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
