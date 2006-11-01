From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] reduce hugetlb_instantiation_mutex usage
Date: Wed, 1 Nov 2006 02:17:28 -0800
Message-ID: <000001c6fd9e$ef709230$8984030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <45483C37.6040303@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, g@ozlabs.org, Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote on Tuesday, October 31, 2006 10:19 PM
> So what does the normal page fault path do? Just invalidates the private
> page out of the page tables. A subsequent fault goes through the normal
> shared page path, which detects the truncation as it would with any
> shared fault. Right?
> 
> hugetlb seems to pretty well follow the same pattern as memory.c in this
> regard. I don't see the race?

I was originally worried about a case that one thread fault on a private
mapping and get hold of a fresh page via alloc_huge_page(). While it executes
clear_huge_page(), 2nd thread come by did a ftruncate. After first thread
finish zeroing, I thought it will happily install a pte. But no, the inode
size check will prevent that from happening.

I was mislead by the comments in hugetlb_no_page() that page lock is used to
guard against racing truncation.  Now I'm drifting back into what "racing
truncation" the comment is referring to. What race does it trying to protect
with page lock?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
