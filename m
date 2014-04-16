Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4096B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 20:27:39 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so10046913pdj.31
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:27:39 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id pu6si9583500pac.143.2014.04.15.17.27.37
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 17:27:39 -0700 (PDT)
Date: Wed, 16 Apr 2014 09:28:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/vmalloc: Introduce DEBUG_VMALLOCINFO to reduce
 spinlock contention
Message-ID: <20140416002804.GB17350@js1304-P5Q-DELUXE>
References: <1397148058-8737-1-git-send-email-ryao@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397148058-8737-1-git-send-email-ryao@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Yao <ryao@gentoo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@gentoo.org, Matthew Thode <mthode@mthode.org>

On Thu, Apr 10, 2014 at 12:40:58PM -0400, Richard Yao wrote:
> Performance analysis of software compilation by Gentoo portage on an
> Intel E5-2620 with 64GB of RAM revealed that a sizeable amount of time,
> anywhere from 5% to 15%, was spent in get_vmalloc_info(), with at least
> 40% of that time spent in the _raw_spin_lock() invoked by it.
> 
> The spinlock call is done on vmap_area_lock to protect vmap_area_list,
> but changes to vmap_area_list are made under RCU. The only consumer that
> requires a spinlock on an RCU-ified list is /proc/vmallocinfo. That is

Why only '/proc/vmallocinfo' needs the spinlock?
List iterators which access va->vm such as vread() and vwrite() needs
the spinlock too.
But, I think that get_vmalloc_info() doesn't need it, so you can use
rcu list iteration on that function and it would fix your problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
