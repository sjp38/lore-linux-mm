Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id CF56A6B006C
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 14:41:12 -0400 (EDT)
Message-ID: <4FF73106.3090802@redhat.com>
Date: Fri, 06 Jul 2012 14:40:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 04/26] mm, mpol: add MPOL_MF_NOOP
References: <20120316144028.036474157@chello.nl> <20120316144240.368911012@chello.nl>
In-Reply-To: <20120316144240.368911012@chello.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 10:40 AM, Peter Zijlstra wrote:

Reasonable idea, but we need something else than a blind
unmap and add to swap space, which requires people to run
with gigantic amounts of swap space they will likely never
use.

I suspect that Andrea's _PAGE_NUMA stuff could be implemented
using _PAGE_PROTNONE, and then we can simply call the NUMA
faulting/migration handler whenever we run into a _PAGE_PROTNONE
page in handle_mm_fault / handle_pte_fault.

This overloading of _PAGE_PROTNONE should work fine, because
do_page_fault will never call handle_mm_fault if the fault is
happening on a PROT_NONE VMA. Only if we have the correct VMA
permission will handle_mm_fault be called, at which point we
can fix the pte (and maybe migrate the page).

The same trick can be done at the pmd level for transparent
hugepages, allowing the entire THP to be migrated in one shot,
with just one fault.

Is there any reason why _PAGE_PROTNONE could not work instead
of _PAGE_NUMA or the swap cache thing?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
