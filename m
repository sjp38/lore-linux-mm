Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4DD66B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:49:50 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e128so390345wmg.1
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:49:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93si370150ede.482.2017.12.05.06.49.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 06:49:49 -0800 (PST)
Date: Tue, 5 Dec 2017 15:49:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171205144948.ezgo3xpjeytkq6ua@dhcp22.suse.cz>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511965054-6328-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 29-11-17 09:17:34, Waiman Long wrote:
> The list_lru_del() function removes the given item from the LRU list.
> The operation looks simple, but it involves writing into the cachelines
> of the two neighboring list entries in order to get the deletion done.
> That can take a while if the cachelines aren't there yet, thus
> prolonging the lock hold time.
> 
> To reduce the lock hold time, the cachelines of the two neighboring
> list entries are now prefetched before acquiring the list_lru_node's
> lock.
> 
> Using a multi-threaded test program that created a large number
> of dentries and then killed them, the execution time was reduced
> from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
> 72-thread x86-64 system.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

The patch still seems to be in the mmotm tree while it breaks
compilation. At least m32r defconfig complains with
mm/list_lru.c: In function 'list_lru_del':
mm/list_lru.c:141:2: error: implicit declaration of function 'prefetchw' [-Werror=implicit-function-declaration]
  prefetchw(item->prev);

It also seems that there is no general agreement in the patch. Andrew,
do you plan to keep it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
