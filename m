Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ1i4095094
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ1Fd1933388
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ0uT016563
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Message-Id: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:20 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/6] s390 page tables on steroids ..
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Greetings,
this patch series of six patches contains three mm related changes
for the s390 architecture:
i) 1K/2K page tables. With this patch set the cheating with the
   pmd_t on s390 stops. So far a pmd contained 2/4 pointers instead
   of just one which would be correct from an architectural stand
   point. The Trouble with this is that it requires two common code
   changes to make sub-page page tables possible. This features
   is an important requirement for the kvm support on s390.
ii) Support for 4 levels of page tables. The address space limit for
   64 bit processes is now 2^53. That should be enough for anyone ?
iii) Support for different number of page table levels. The limit
   of 2^53 is nice but it slows down the tlb lookup that now has
   to walk 4 instead of 3 levels. Patch #5 make the number of page
   table levels dependent on the highest address a process is using.
   If an mmap is done that raises the limit to the next level, the
   page table gets another level. A downgrade is only done at process
   start, so that 31 bit processes get a two level page table. A
   normal 64 bit process starts with three levels.

The first three patches in the series contain the common code changes
that are needed to get all of this done. I did my best to find all the
place in the different architectures that need to be updated after the
common code changed. Please let me know if you find a place I missed.

The patches are against Linus's git tree.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
