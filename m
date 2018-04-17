Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5AC6B0275
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:46:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i23so12676592qke.1
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:46:30 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id t18si1629112qkg.174.2018.04.17.07.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:46:29 -0700 (PDT)
Date: Tue, 17 Apr 2018 09:45:27 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 16 Apr 2018, Mikulas Patocka wrote:

> This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
> flag causes allocation of larger slab caches in order to minimize wasted
> space.
>
> This is needed because we want to use dm-bufio for deduplication index and
> there are existing installations with non-power-of-two block sizes (such
> as 640KB). The performance of the whole solution depends on efficient
> memory use, so we must waste as little memory as possible.

Hmmm. Can we come up with a generic solution instead?

This may mean relaxing the enforcement of the allocation max order a bit
so that we can get dense allocation through higher order allocs.

But then higher order allocs are generally seen as problematic.

Note that SLUB will fall back to smallest order already if a failure
occurs so increasing slub_max_order may not be that much of an issue.

Maybe drop the max order limit completely and use MAX_ORDER instead? That
means that callers need to be able to tolerate failures.
