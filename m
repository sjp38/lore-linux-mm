Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 439D66B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:41:55 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so2771352pdb.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:41:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gf2si21692067pbd.94.2015.05.12.02.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:41:54 -0700 (PDT)
Date: Tue, 12 May 2015 12:41:34 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150512094134.GE17628@esperanza>
References: <20150429043536.GB11486@blaptop>
 <20150429091248.GD1694@esperanza>
 <20150430082531.GD21771@blaptop>
 <20150430145055.GB17640@esperanza>
 <20150504031722.GA2768@blaptop>
 <20150504094938.GB4197@esperanza>
 <20150504105459.GA19384@blaptop>
 <20150508095604.GO31732@esperanza>
 <20150509151031.GA24141@blaptop>
 <20150510103429.GA17628@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150510103429.GA17628@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux-foundation.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Sun, May 10, 2015 at 01:34:29PM +0300, Vladimir Davydov wrote:
> On Sun, May 10, 2015 at 12:12:38AM +0900, Minchan Kim wrote:
> > Yeb, I might be paranoid but my point is it might work now on most of
> > arch but it seem to be buggy/fragile/subtle because we couldn't prove
> > all arch/compiler don't make any trouble. So, intead of adding more
> > logics based on fragile, please use right lock model. If lock becomes
> > big trouble by overhead, let's fix it(for instance, use WRITE_ONCE for
> > update-side and READ_ONCE  for read-side) if I don't miss something.
> 
> IMO, locking would be an overkill. READ_ONCE is OK, because it has no
> performance implications, but I would prefer to be convinced that it is
> 100% necessary before adding it just in case.

Finally, I'm convinced we do need synchronization here :-) Sorry for
being so stubborn and thank you for your patience.

After examining page_referenced() with the knowledge that the compiler
may be completely unreliable and split page->mapping read/writes as it
wants, I've drawn the conclusion that it is safer to take
page_zone->lru_lock for checking if the page is on an LRU list, just as
you proposed initially, because otherwise we need to insert those
READ/WRITE_ONCE in every nook and cranny, which would look confusing
provided we only needed them for this idle page tracking feature, which
might even be not compiled in.

I'll fix it and resend.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
