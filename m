Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D28D26B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 16:05:46 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so109600pdi.30
        for <linux-mm@kvack.org>; Thu, 29 May 2014 13:05:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xl4si2412900pab.5.2014.05.29.13.05.45
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 13:05:45 -0700 (PDT)
Date: Thu, 29 May 2014 13:05:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock
 contention
Message-Id: <20140529130544.56213f048f331723329ff828@linux-foundation.org>
In-Reply-To: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>

On Thu, 29 May 2014 15:22:34 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Richard Yao reported a month ago that his system have a trouble
> with vmap_area_lock contention during performance analysis
> by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> stressfully, but he didn't answer it.
> 
> https://lkml.org/lkml/2014/4/10/416
> 
> Although I'm not sure that this is right usage or not, there is a solution
> reducing vmap_area_lock contention with no side-effect. That is just
> to use rcu list iterator in get_vmalloc_info(). This function only needs
> values on vmap_area structure, so we don't need to grab a spinlock.

The mixture of rcu protection and spinlock protection for
vmap_area_list is pretty confusing.  Are you able to describe the
overall design here?  When and why do we use one versus the other?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
