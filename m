Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D08746B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:15:30 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m70so4041270ioi.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:15:30 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id o71si10690389ite.146.2018.02.16.12.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 12:15:30 -0800 (PST)
Date: Fri, 16 Feb 2018 14:15:26 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
Message-ID: <alpine.DEB.2.20.1802161413340.11934@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, 16 Feb 2018, Dave Hansen wrote:

> On 02/16/2018 08:01 AM, Christoph Lameter wrote:
> > In order to make this work just right one needs to be able to
> > know the workload well enough to reserve the right amount
> > of pages. This is comparable to other reservation schemes.
>
> Yes, but it's a reservation scheme that doesn't show up in MemFree, for
> instance.  Even hugetlbfs-reserved memory subtracts from that.

Ok. There is the question if we can get all these reservation schemes
under one hood instead of having page order specific ones in subsystems
like hugetlb.

> This has the potential to be really confusing to apps.  If this memory
> is now not available to normal apps, they might plow into the invisible
> memory limits and get into nasty reclaim scenarios.

> Shouldn't this subtract the memory for MemFree and friends?

Ok certainly we could do that. But on the other hand the memory is
available if those subsystems ask for the right order. Its not clear to me
what the right way of handling this is. Right now it adds the reserved
pages to the watermarks. But then under some circumstances the memory is
available. What is the best solution here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
