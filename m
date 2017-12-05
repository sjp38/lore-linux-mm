Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5E486B026B
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 18:56:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 80so1009493wmb.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 15:56:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i184si1008459wmf.57.2017.12.05.15.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 15:56:21 -0800 (PST)
Date: Tue, 5 Dec 2017 15:56:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-Id: <20171205155618.7a3a59751ed49c704210b736@linux-foundation.org>
In-Reply-To: <20171205144948.ezgo3xpjeytkq6ua@dhcp22.suse.cz>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
	<20171205144948.ezgo3xpjeytkq6ua@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Waiman Long <longman@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 5 Dec 2017 15:49:48 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 29-11-17 09:17:34, Waiman Long wrote:
> > The list_lru_del() function removes the given item from the LRU list.
> > The operation looks simple, but it involves writing into the cachelines
> > of the two neighboring list entries in order to get the deletion done.
> > That can take a while if the cachelines aren't there yet, thus
> > prolonging the lock hold time.
> > 
> > To reduce the lock hold time, the cachelines of the two neighboring
> > list entries are now prefetched before acquiring the list_lru_node's
> > lock.
> > 
> > Using a multi-threaded test program that created a large number
> > of dentries and then killed them, the execution time was reduced
> > from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
> > 72-thread x86-64 system.
> > 
> > Signed-off-by: Waiman Long <longman@redhat.com>
> 
> The patch still seems to be in the mmotm tree while it breaks
> compilation. At least m32r defconfig complains with
> mm/list_lru.c: In function 'list_lru_del':
> mm/list_lru.c:141:2: error: implicit declaration of function 'prefetchw' [-Werror=implicit-function-declaration]
>   prefetchw(item->prev);

erp, I forgot to cc Stephen.

> It also seems that there is no general agreement in the patch. Andrew,
> do you plan to keep it?

It's in wait-and-see mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
