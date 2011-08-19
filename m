Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA9D26B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 10:02:39 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p7JE2Zub021062
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:02:35 GMT
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7JE2Z9B2498776
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 15:02:35 +0100
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7JE2YUW017024
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 08:02:35 -0600
Subject: Re: [patch v3 2/8] kdump: Make kimage_load_crash_segment() weak
From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Reply-To: holzheu@linux.vnet.ibm.com
In-Reply-To: <20110819134836.GB18656@redhat.com>
References: <20110812134849.748973593@linux.vnet.ibm.com>
	 <20110812134907.166585439@linux.vnet.ibm.com>
	 <20110818171541.GC15413@redhat.com> <1313760472.3858.26.camel@br98xy6r>
	 <20110819134836.GB18656@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Aug 2011 16:02:34 +0200
Message-ID: <1313762554.3858.37.camel@br98xy6r>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: ebiederm@xmission.com, mahesh@linux.vnet.ibm.com, hbabu@us.ibm.com, oomichi@mxs.nes.nec.co.jp, horms@verge.net.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org

Hello Vivek,

On Fri, 2011-08-19 at 09:48 -0400, Vivek Goyal wrote:

[snip]

> > > Michael,
> > > 
> > > Thinking more about it. Can't we provide a arch specific version of
> > > kmap() and kunmap() so that we create temporary mappings to copy
> > > the pages and then these are torn off.
> > 
> > Isn't kmap/kunmap() used for higmem? These functions are called from
> > many different functions in the Linux kernel, not only for kdump. I
> > would assume that creating and removing mappings with these functions is
> > not what a caller would expect and probably would break the Linux kernel
> > at many other places, no?
> 
> [CCing linux-mm]
> 
> Yes it is being used for highmem pages. If arch has not defined kmap()
> then generic definition is just returning page_address(page), expecting
> that page will be mapped.
> 
> I was wondering that what will be broken if arch decides to extend this
> to create temporary mappings for pages which are not HIGHMEM but do
> not have any mapping. (Like this special case of s390).

At least we have significant additional overhead for all the other
places where kmap/kunmap is called.

> I guess memory management guys can give a better answer here. As a layman,
> kmap() seems to be the way to get a kernel mapping for any page frame
> and if one is not already there, then arch might create one on the fly,
> like we do for HIGHMEM pages. So the question is can be extend this
> to also cover pages which are not highmem but do not have any mappings
> on s390.
> 
> > 
> > Perhaps we can finish this discussion after my vacation. I will change
> > my patch series that we even do not need this patch...
> 
> So how are you planning to get rid of this patch without modifying kmap(),
> kunmap() implementation for s390?

I will update my patch series that we do not remove page tables for
crashkernel memory. So everything will be as on other architectures.

I hope that we can find a good solution after my vacation. Perhaps then
I have enough energy again :-)

> > So only two common code patches are remaining. I will send the common
> > code patches again and will ask Andrew Morton to integrate them in the
> > next merge window.The s390 patches will be integrated by Martin.
> 
> I am fine with merge of other 2 common patches. Once you repost the
> series, I will ack those.

Great! I will resend the patches and contact Andrew Morton.

Thanks!

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
