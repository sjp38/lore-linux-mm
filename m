Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 85BC46B0038
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 02:39:51 -0500 (EST)
Received: by pfcc203 with SMTP id c203so15146pfc.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 23:39:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xc6si1798739pab.244.2015.12.10.23.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 23:39:50 -0800 (PST)
Date: Fri, 11 Dec 2015 10:39:37 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151211073937.GB5171@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <566A3999.5060509@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <566A3999.5060509@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 11, 2015 at 11:48:57AM +0900, Kamezawa Hiroyuki wrote:
> On 2015/12/10 20:39, Vladimir Davydov wrote:
> > In the legacy hierarchy we charge memsw, which is dubious, because:
> > 
> >   - memsw.limit must be >= memory.limit, so it is impossible to limit
> >     swap usage less than memory usage. Taking into account the fact that
> >     the primary limiting mechanism in the unified hierarchy is
> >     memory.high while memory.limit is either left unset or set to a very
> >     large value, moving memsw.limit knob to the unified hierarchy would
> >     effectively make it impossible to limit swap usage according to the
> >     user preference.
> > 
> >   - memsw.usage != memory.usage + swap.usage, because a page occupying
> >     both swap entry and a swap cache page is charged only once to memsw
> >     counter. As a result, it is possible to effectively eat up to
> >     memory.limit of memory pages *and* memsw.limit of swap entries, which
> >     looks unexpected.
> > 
> > That said, we should provide a different swap limiting mechanism for
> > cgroup2.
> > 
> > This patch adds mem_cgroup->swap counter, which charges the actual
> > number of swap entries used by a cgroup. It is only charged in the
> > unified hierarchy, while the legacy hierarchy memsw logic is left
> > intact.
> > 
> > The swap usage can be monitored using new memory.swap.current file and
> > limited using memory.swap.max.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> setting swap.max=0 will work like mlock ?

For anonymous memory - yes.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
