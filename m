Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E25A26B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:33:11 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e93-v6so1256100plb.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:33:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c16-v6sor2661213pgl.324.2018.07.23.14.33.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 14:33:10 -0700 (PDT)
Date: Mon, 23 Jul 2018 14:33:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <alpine.DEB.2.21.1807231323460.105582@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1807231427550.103523@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org> <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com> <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
 <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com> <20180722035156.GA12125@bombadil.infradead.org> <alpine.DEB.2.21.1807231323460.105582@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Jul 2018, David Rientjes wrote:

> > > The huge zero page can be reclaimed under memory pressure and, if it is, 
> > > it is attempted to be allocted again with gfp flags that attempt memory 
> > > compaction that can become expensive.  If we are constantly under memory 
> > > pressure, it gets freed and reallocated millions of times always trying to 
> > > compact memory both directly and by kicking kcompactd in the background.
> > > 
> > > It likely should also be per node.
> > 
> > Have you benchmarked making the non-huge zero page per-node?
> > 
> 
> Not since we disable it :)  I will, though.  The more concerning issue for 
> us, modulo CVE-2017-1000405, is the cpu cost of constantly directly 
> compacting memory for allocating the hzp in real time after it has been 
> reclaimed.  We've observed this happening tens or hundreds of thousands 
> of times on some systems.  It will be 2MB per node on x86 if the data 
> suggests we should make it NUMA aware, I don't think the cost is too high 
> to leave it persistently available even under memory pressure if 
> use_zero_page is enabled.
> 

Measuring access latency to 4GB of memory on Naples I observe ~6.7% 
slower access latency intrasocket and ~14% slower intersocket.

use_zero_page is currently a simple thp flag, meaning it rejects writes 
where val != !!val, so perhaps it would be best to overload it with 
additional options?  I can imagine 0x2 defining persistent allocation so 
that the hzp is not freed when the refcount goes to 0 and 0x4 defining if 
the hzp should be per node.  Implementing persistent allocation fixes our 
concern with it, so I'd like to start there.  Comments?
