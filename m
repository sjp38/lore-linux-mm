Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 647168D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 15:56:50 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p11GcJnu016039
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 11:38:57 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 67E4D4DE803F
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 15:56:14 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p11KulLD167572
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 15:56:47 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11KulRE025551
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 18:56:47 -0200
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110201203936.GB16981@random.random>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201153857.GA18740@random.random> <1296580547.27022.3370.camel@nimitz>
	 <20110201203936.GB16981@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 01 Feb 2011 12:56:41 -0800
Message-ID: <1296593801.27022.3920.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 21:39 +0100, Andrea Arcangeli wrote:
> So now the speedup
> from hugepages needs to also offset the cost of the more frequent
> split/collapse events that didn't happen before.

My concern here is the downward slope.  I interpret that as saying that
we'll eventually have _zero_ THPs.  Plus, the benefits are decreasing
constantly, even though the scanning overhead is fixed (or increasing
even).

> So I guess considering the time is of the order of 2/3 hours and there
> are "only" 88G of memory, speeding up khugepaged is going to be
> beneficial considering how big boost hugepages gives to the guest with
> NPT/EPT and even bigger boost for regular shadow paging, but it also
> depends on guest. In short khugepaged by default is tuned in a way
> that can't run in the way of the CPU. 

I guess we could also try and figure out whether the khugepaged CPU
overhead really comes from the scanning or the collapsing operations
themselves.  Should be as easy as some oprofiling.

If it really is the scanning, I bet we could be a lot more efficient
with khugepaged as well.  In the case of KVM guests, we're going to have
awfully fixed virtual addresses and processes where collapsing can take
place.

It might make sense to just have split_huge_page() stick the vaddr and
the mm in a queue.  khugepaged could scan those addresses first instead
of just going after the system as a whole.

For cases where the page got split, but wasn't modified, should we have
a non-copying, non-allocating fastpath to re-merge it?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
