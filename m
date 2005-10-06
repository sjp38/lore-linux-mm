Received: from e4.ny.us.ibm.com ([9.56.232.144])
	by bldfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id j96FTGUV009458
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 11:29:17 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j96FNFtJ029790
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 11:23:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j96FNBXV088170
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 11:23:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j96FN1gh029263
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 11:23:01 -0400
Subject: Re: [PATCH 0/3] Demand faulting for huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0509291420150.27691@goblin.wat.veritas.com>
References: <1127939141.26401.32.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0509291420150.27691@goblin.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 06 Oct 2005 10:22:49 -0500
Message-Id: <1128612169.10109.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "David Gibson david"@gibson.dropbear.id.au, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 14:32 +0100, Hugh Dickins wrote:
> On Wed, 28 Sep 2005, Adam Litke wrote:
> 
> > Hi Andrew.  Can we give hugetlb demand faulting a spin in the mm tree?
> > And could people with alpha, sparc, and ia64 machines give them a good
> > spin?  I haven't been able to test those arches yet.
> 
> It's going to be a little confusing if these go in while I'm moving
> the page_table_lock inwards.  My patches don't make a big difference
> to hugetlb (I've not attempted splitting the lock at all for hugetlb -
> there would be per-arch implementation issues and very little point -
> though more point if we do move to hugetlb faulting).  But I'm ill at
> ease with changing the locking at one end while it's unclear whether
> it's right at the other end.
> 
> Currently Adam's patches don't include my hugetlb changes already in
> -mm; and I don't see any attention in his patches to the issue of
> hugetlb file truncation, which I was fixing up in those.
> 
> The current hugetlb_prefault guards against this with i_sem held:
> which _appears_ to be a lock ordering violation, but may not be,
> since the official lock ordering is determined by the possibility
> of fault within write, whereas hugetlb mmaps were never faulting.
> 
> Presumably on-demand hugetlb faulting would entail truncate_count
> checking like do_no_page, and corresponding code in hugetlbfs.
> 
> I've no experience of hugetlb use.  Personally, I'd be very happy with
> a decision to disallow truncation of hugetlb files (seems odd to allow
> ftruncate when read and write are not allowed, and the size normally
> determined automatically by mmap size); but I have to assume that it's
> been allowed for good reason.

If I were to spend time coding up a patch to remove truncation support
for hugetlbfs, would it be something other people would want to see
merged as well?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
