Date: Thu, 26 Oct 2006 13:59:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
In-Reply-To: <000001c6f933$b75bc190$ff0da8c0@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0610261225250.3011@schroedinger.engr.sgi.com>
References: <000001c6f933$b75bc190$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2006, Chen, Kenneth W wrote:

> One performance fix I have in mind is to only use the mutex when system is down to 1
> free hugetlb page. That is the real reason why mutex got introduced. I'm implementing
> it right now and hope it will restore most if not all of the performance we lost.

Right. Its a heavily special case that brings down performance for 
everyone else. Maybe setup a boundary via /proc/sys/vm/nr_hugepages_xxx 
below which this is checked? 

> Christoph, the shared page table for hugetlb also need your advice here in the path
> of allocating page table page. It takes a per inode spin lock in order to find
> shareable page table page.  Do you think it will cause problem?  I hope not.

Well it depends on how huge pages are used. If you use one file per 
process then there is no issue.

Even if we have a common huge file spanning multiple nodes: If you just 
take the inode lock to find the page then I think its fine. We have the 
same issues with the page lock for regular pages. But please avoid locks 
while zeroing a huge page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
