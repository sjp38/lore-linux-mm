Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0CJn1In012744
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 14:49:01 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0CJn0BB095968
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 14:49:01 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0CJn0XA006434
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 14:49:00 -0500
Subject: RE: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <200601121907.k0CJ7og16283@unix-os.sc.intel.com>
References: <200601121907.k0CJ7og16283@unix-os.sc.intel.com>
Content-Type: text/plain
Date: Thu, 12 Jan 2006 13:48:59 -0600
Message-Id: <1137095339.17956.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-01-12 at 11:07 -0800, Chen, Kenneth W wrote:
> Sorry, I don't think patch 1 by itself is functionally correct.  It opens
> a can of worms with race window all over the place.  It does more damage
> than what it is trying to solve.  Here is one case:
> 
> 1 thread fault on hugetlb page, allocate a non-zero page, insert into the
> page cache, then proceed to zero it.  While in the middle of the zeroing,
> 2nd thread comes along fault on the same hugetlb page.  It find it in the
> page cache, went ahead install a pte and return to the user.  User code
> modify some parts of the hugetlb page while the 1st thread is still
> zeroing.  A potential silent data corruption.

I don't think the above case is possible because of find_lock_page().
The second thread would wait on the page to be unlocked by the thread
zeroing it before it could proceed.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
