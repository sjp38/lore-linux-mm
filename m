Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB5B6B0271
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:44:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id d17so3415588iob.7
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:44:28 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id z8si8418082itc.123.2018.02.16.07.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:44:27 -0800 (PST)
Date: Fri, 16 Feb 2018 09:44:25 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180215204817.GB22948@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802160941500.9660@nuc-kabylake>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz> <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com> <20180215144525.GG7275@dhcp22.suse.cz> <20180215151129.GB12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake> <20180215204817.GB22948@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, 15 Feb 2018, Matthew Wilcox wrote:

> > The inducing of releasing memory back is not there but you can run SLUB
> > with MAX_ORDER allocations by passing "slab_min_order=9" or so on bootup.
>
> This is subtly different from the idea that I had.  If you set
> slub_min_order to 9, then slub will allocate 2MB pages for each slab,
> so allocating one object from kmalloc-32 and one object from dentry will
> cause 4MB to be taken from the system.

Right.

> What I was proposing was an intermediate page allocator where slab would
> request 2MB for its own uses all at once, then allocate pages from that to
> individual slabs, so allocating a kmalloc-32 object and a dentry object
> would result in 510 pages of memory still being available for any slab
> that needed it.

Well thats not really going to work since you would be mixing objects of
different sizes which may present more fragmentation problems within the
2M later if they are freed and more objects are allocated.

What we could do is add a readonly allocation mode for those objects for
which we know that are never freed. Those could be combined into 2M
blocks.

Or an allocation mode where we would free a whole bunch of objects in one
go. If we can mark those allocs then they could be satisfied from the same
block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
