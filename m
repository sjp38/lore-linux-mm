Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76C716B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 11:15:03 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so117262086lfi.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:15:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e132si15311312wme.59.2016.07.18.08.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 08:15:00 -0700 (PDT)
Date: Mon, 18 Jul 2016 11:14:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: System freezes after OOM
Message-ID: <20160718151445.GB14604@cmpxchg.org>
References: <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607150711270.5034@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607150711270.5034@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com, Dave Chinner <david@fromorbit.com>

CC Dave Chinner, who I recall had strong opinions on the mempool model

The context is commit f9054c7 ("mm, mempool: only set __GFP_NOMEMALLOC
if there are free elements"), which gives MEMALLOC/TIF_MEMDIE mempool
allocations access to the system emergency reserves when there is no
reserved object currently residing in the mempool.

On Fri, Jul 15, 2016 at 07:21:59AM -0400, Mikulas Patocka wrote:
> On Thu, 14 Jul 2016, David Rientjes wrote:
> 
> > There is no guarantee that _anything_ can return memory to the mempool,
> 
> You misunderstand mempools if you make such claims.

Uhm, fully agreed.

The point of mempools is that they have their own reserves, separate
from the system reserves, to make forward progress in OOM situations.

All mempool object holders promise to make forward progress, and when
memory is depleted, the mempool allocations serialize against each
other. In this case, every allocation has to wait for in-flight IO to
finish to pass the reserved object on to the next IO. That's how the
mempool model is designed. The commit in question breaks this by not
waiting for outstanding object holders and instead quickly depletes
the system reserves. That's a mempool causing a memory deadlock...

David observed systems hanging 2+h inside mempool allocations. But
where would an object holders get stuck? It can't be taking a lock
that the waiting mempool_alloc() is holding, obviously. It also can't
be waiting for another allocation, it makes no sense to use mempools
to guarantee forward progress, but then have the whole sequence rely
on an unguaranteed allocation to succeed after the mempool ones. So
how could a system-wide OOM situation cause a mempool holder to hang?

These hangs are fishy, but it seems reasonable to assume that somebody
is breaking the mempool contract somewhere. The solution can not to be
to abandon the mempool model. f9054c7 should be reverted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
