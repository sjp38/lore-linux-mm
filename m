Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 808B89088D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 15:17:39 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1HSKjz-00022n-00
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 15:17:39 -0700
Date: Fri, 16 Mar 2007 15:17:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: ZERO_PAGE refcounting causes cache line bouncing
Message-ID: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have issues with ZERO_PAGE refcounting causing severe cacheline 
bouncing. ZERO_PAGES are mapped into multiple processes running on 
multiple nodes. Refcounter modifications therefore have to acquire a 
remote exclusive cacheline.

Could we somehow fix this? There are a couple of ways to do this:

1. No refcounting on reserved pages in the VM. ZERO_PAGEs are
   reserved and there is no point in refcounting them since they
   will not go away.

2. Having a percpu or pernode ZERO_PAGE?

   May be a simpler solution but then we still may have issues
   if the ZERO_PAGE gets "freed" from other processors/ nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
