Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F1EA6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 01:52:06 -0400 (EDT)
Received: from epmmp2 (mailout3.samsung.com [203.254.224.33])
 by mailout1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KLM00JVULJ3I2@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 22 Jun 2009 14:49:51 +0900 (KST)
Received: from Narayanang ([107.108.214.192])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0KLM00FNULJ2GD@mmp2.samsung.com> for linux-mm@kvack.org; Mon,
 22 Jun 2009 14:49:51 +0900 (KST)
Date: Mon, 22 Jun 2009 11:20:14 +0530
From: Narayanan Gopalakrishnan <narayanan.g@samsung.com>
Subject: Performance degradation seen after using one list for hot/cold pages.
Message-id: <70875432E21A4185AD2E007941B6A792@sisodomain.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

We are facing a performance degradation of 2 MBps in kernels 2.6.25 and
above.
We were able to zero on the fact that the exact patch that has affected us
is this
(http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdi
ff;h=3dfa5721f12c3d5a441448086bee156887daa961), that changes to have one
list for hot/cold pages. 

We see the at the block driver the pages we get are not contiguous hence the
number of LLD requests we are making have increased which is the cause of
this problem.

The page allocation in our case is called from aio_read and hence it always
calls page_cache_alloc_cold(mapping) from readahead.

We have found a hack for this that is, removing the __GFP_COLD macro when
__page_cache_alloc()is called helps us to regain the performance as we see
contiguous pages in block driver.

Has anyone faced this problem or can give a possible solution for this?

Our target is OMAP2430 custom board with 128MB RAM.

Regards,

Narayanan Gopalakrishnan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
