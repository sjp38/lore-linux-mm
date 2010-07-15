Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A90CD6B02B0
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 12:19:27 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o6FGJOPV016366
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 16:19:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6FGJJF91208500
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 17:19:24 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o6FGJJLu002690
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 17:19:19 +0100
Message-ID: <4C3F3548.8010708@de.ibm.com>
Date: Thu, 15 Jul 2010 18:20:24 +0200
From: Carsten Otte <carsteno@de.ibm.com>
MIME-Version: 1.0
Subject: [PATCH mm/filemap_xip.c] Fix race condition in xip_file_fault
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
Cc: jaredeh@gmail.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Reported-by: David Sadler <dsadler@us.ibm.com>

This patch fixes a race condition that shows in conjunction with 
xip_file_fault
when two threads of the same user process fault on the same memory page. 
In this
case, the race winner will install the page table entry, and the unlucky 
loser
will cause an oops:
xip_file_fault calls vm_insert_pfn (via vm_insert_mixed) which drops out at
this check:
	retval = -EBUSY;
	if (!pte_none(*pte))
		goto out_unlock;
The resulting -EBUSY return value will trigger a BUG_ON() in xip_file_fault.

This fix simply considers the fault as fixed in this case, because the
race winner has successfully installed the pte.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
  mm/filemap_xip.c |    5 ++++-
  1 file changed, 4 insertions(+), 1 deletion(-)

--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -263,7 +263,10 @@ found:
  							xip_pfn);
  		if (err == -ENOMEM)
  			return VM_FAULT_OOM;
-		BUG_ON(err);
+		/* err == -EBUSY is fine, we've raced against another thread
+		   that faulted-in the same page */
+		if (err != -EBUSY)
+			BUG_ON(err);
  		return VM_FAULT_NOPAGE;
  	} else {
  		int err, ret = VM_FAULT_OOM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
