Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C55936B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:49:03 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b5so536544itd.6
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:49:03 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id u67si1648385iod.280.2018.02.15.07.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 07:49:02 -0800 (PST)
Date: Thu, 15 Feb 2018 09:49:00 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180215151129.GB12360@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz> <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com> <20180215144525.GG7275@dhcp22.suse.cz>
 <20180215151129.GB12360@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, 15 Feb 2018, Matthew Wilcox wrote:

> What if ... on startup, slab allocated a MAX_ORDER page for itself.
> It would then satisfy its own page allocation requests from this giant
> page.  If we start to run low on memory in the rest of the system, slab
> can be induced to return some of it via its shrinker.  If slab runs low
> on memory, it tries to allocate another MAX_ORDER page for itself.

The inducing of releasing memory back is not there but you can run SLUB
with MAX_ORDER allocations by passing "slab_min_order=9" or so on bootup.

> I think even this should reduce fragmentation.  We could enhance the
> fragmentation reduction by noticing when somebody else releases a page
> that was previously part of a slab MAX_ORDER page and handing that page
> back to slab.  When slab notices that it has an entire MAX_ORDER page free
> (and sufficient other memory on hand that it's unlikely to need it soon),
> it can hand that MAX_ORDER page back to the page allocator.

SLUB will release MAX_ORDER pages if they are completely free with the
above configuration.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
