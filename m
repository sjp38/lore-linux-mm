Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3SKqFbo010545
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 16:52:15 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3SKqEqM221296
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 14:52:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3SKq6AZ020965
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 14:52:14 -0600
Date: Mon, 28 Apr 2008 13:52:00 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080428205200.GA4386@us.ibm.com>
References: <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.04.2008 [13:31:00 -0700], Christoph Lameter wrote:
> On Sat, 26 Apr 2008, Greg KH wrote:
> 
> > Also, why use a "units" here, just always use the lowest unit, and
> > userspace can convert from kB to GB if needed.
> 
> Additional complications will come about because IA64 supports 
> varying hugetlb sizes from 4kb to 1GB.

What "complications" do you mean? It's a small function indeed to
convert from the directory name to the corresponding "human-named" size,
e.g. hugepages-1048576 to "1 GB". And such a function will probably
exist in libhugetlbfs at some point, for applications to use, if they
like.

A potential problem I do see is for a 32-bit binary running on a 64-bit
kernel and is one we've run against for 32-bit binaries with 16G pages
available. The 32-bit binary can't actually store the size of the
hugepage in an unsigned long, so we have to remember how big of a value
we can represent (i.e., max_hugepage_size_in_kb) and check what's
obtained from /proc/meminfo against that. Not ideal, for sure.

> Also we would at some point like to add support for 1TB hugepages
> (that may depend on the presence of a special device that handles
> these).

I also don't see a limitation here? For 32-bit programs, we'll see
1073741824 and know we can't convert that into a valid value in bytes.

More importnatly, I think the fact that IA64 supports multiple hugepage
sizes is a reason *for* moving to sysfs for this information? However, I
think we may need to massage the IA64-specific bits of the kernel to
actually support multiple hugepage size pools being available at
run-time? That is, with the current kernel, we can only support one
hugepagesize at run-time, due to VHPT restrictions?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
