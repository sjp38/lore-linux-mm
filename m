Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42JrDeO031928
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:53:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42JrDI9264312
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:53:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42JrCnM002939
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:53:13 -0400
Date: Fri, 2 May 2008 12:53:11 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 06/18] hugetlb: multi hstate proc files
Message-ID: <20080502195311.GD26273@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.311388000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.311388000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:08 +1000], npiggin@suse.de wrote:
> Convert /proc output code over to report multiple hstates
> 
> I chose to just report the numbers in a row, in the hope 
> to minimze breakage of existing software. The "compat" page size
> is always the first number.

Only if add_huge_hstate() is called first for the compat page size,
right? That seems bad if we depend on an ordering.

For instance, for power, I think Jon is calling huge_add_hstate() from
the arch/powerpc/mm/hugetlbpage.c init routine. Which runs before
hugetlb_init, which means that if he adds hugepages like

huge_add_hstate(64k-order);
huge_add_hstate(16m-order);
huge_add_hstate(16g-order);

We'll get 64k as the first field in meminfo.

So perhaps what we should do is:

1) architectures define HPAGE_* as the default (compat) hugepage values
2) architectures have a call into generic code at their init time to
specify what sizes they support
3) the core is the only place that actually does huge_add_hstate() and
it always does it first for the compat order?

I wonder if this might lead to issues in timing between processing
hugepagesz= (in arch code) and hugepages= (in generic code). Not sure. I
guess if we always add all hugepage sizes, we should have all the
hstates we know about ready to configure and as long as hugetlb_init
runs before hugepages= processing, we should be fine? Dunno.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
