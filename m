Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id BE0376B0085
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 12:34:02 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so11543201wgh.16
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 09:34:02 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bj4si16943675wib.23.2014.10.14.09.34.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 09:34:01 -0700 (PDT)
Date: Tue, 14 Oct 2014 12:33:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141014163354.GA23911@phnom.home.cmpxchg.org>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
 <1413251163-8517-2-git-send-email-hannes@cmpxchg.org>
 <20141014155647.GA6414@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014155647.GA6414@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 05:56:47PM +0200, Michal Hocko wrote:
> On Mon 13-10-14 21:46:01, Johannes Weiner wrote:
> > Memory is internally accounted in bytes, using spinlock-protected
> > 64-bit counters, even though the smallest accounting delta is a page.
> > The counter interface is also convoluted and does too many things.
> > 
> > Introduce a new lockless word-sized page counter API, then change all
> > memory accounting over to it.  The translation from and to bytes then
> > only happens when interfacing with userspace.
> > 
> > The removed locking overhead is noticable when scaling beyond the
> > per-cpu charge caches - on a 4-socket machine with 144-threads, the
> > following test shows the performance differences of 288 memcgs
> > concurrently running a page fault benchmark:
> 
> I assume you had root.use_hierarchy = 1, right? Processes wouldn't bounce
> on the same lock otherwise.

Yep.  That's already the default on most distros, and will be in the
kernel in unified hierarchy.

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> You have only missed MAINTAINERS...

Hm, we can add it, but then again scripts/get_maintainer.pl should
already do the right thing.  I find myself using it with --git all the
time to find the people that actually worked on the code recently, not
just the ones listed in there - which might be stale information.

> Acked-by: Michal Hocko <mhocko@suse.cz>

Thank you, Michal!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
