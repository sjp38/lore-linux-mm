Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 54A1B6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 11:45:00 -0400 (EDT)
Received: by pawq9 with SMTP id q9so5783998paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 08:45:00 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id oq6si1816731pac.156.2015.08.19.08.44.58
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 08:44:59 -0700 (PDT)
Message-ID: <55D4A462.3070505@internode.on.net>
Date: Thu, 20 Aug 2015 01:14:34 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and 4.2.0-rc7
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Hi, I've found that the Linus' git head kernel has had some unwelcome 
behaviour where chromium browser would exhaust all swap space in the 
course of a few hours. The behaviour appeared before the release of 
4.2.0-rc7.

This does not happen with kernel 4.2.0-rc6.

When I tried a git-bisect, the results where not conclusive due to the 
problem taking over an hour to appear after booting, the closest I came 
was around this commit (the actual problem may be a few commits either 
side):

git bisect good
4f258a46346c03fa0bbb6199ffaf4e1f9f599660 is the first bad commit
commit 4f258a46346c03fa0bbb6199ffaf4e1f9f599660
Author: Martin K. Petersen <martin.petersen@oracle.com>
Date:   Tue Jun 23 12:13:59 2015 -0400

     sd: Fix maximum I/O size for BLOCK_PC requests

     Commit bcdb247c6b6a ("sd: Limit transfer length") clamped the maximum
     size of an I/O request to the MAXIMUM TRANSFER LENGTH field in the 
BLOCK
     LIMITS VPD. This had the unfortunate effect of also limiting the 
maximum
     size of non-filesystem requests sent to the device through sg/bsg.

     Avoid using blk_queue_max_hw_sectors() and set the max_sectors queue
     limit directly.

     Also update the comment in blk_limits_max_hw_sectors() to clarify that
     max_hw_sectors defines the limit for the I/O controller only.

     Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>
     Reported-by: Brian King <brking@linux.vnet.ibm.com>
     Tested-by: Brian King <brking@linux.vnet.ibm.com>
     Cc: stable@vger.kernel.org # 3.17+
     Signed-off-by: James Bottomley <JBottomley@Odin.com>

:040000 040000 fbd0519d9ee0a8f92a7dab9a9c6d7b7868974fba 
b4cf554c568813704993538008aed5b704624679 M      block
:040000 040000 f2630c903cd36ede2619d173f9d1ea0d725ea111 
ff6b6f732afbf6f4b6b26a827c463de50f0e356c M      drivers

Has anyone seen a similar problem?
I can supply .config and other information if requested.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
