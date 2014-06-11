Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 15D3E6B0148
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:43:42 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so1518452pad.31
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:43:41 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id cc3si5358725pad.47.2014.06.10.22.43.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 22:43:41 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so6833385pde.18
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:43:40 -0700 (PDT)
Message-ID: <1402465419.3645.453.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH v2] vmalloc: use rcu list iterator to reduce
 vmap_area_lock contention
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jun 2014 22:43:39 -0700
In-Reply-To: <5397CDC3.1050809@hurleysoftware.com>
References: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <5397CDC3.1050809@hurleysoftware.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>

On Tue, 2014-06-10 at 23:32 -0400, Peter Hurley wrote:

> While rcu list traversal over the vmap_area_list is safe, this may
> arrive at different results than the spinlocked version. The rcu list
> traversal version will not be a 'snapshot' of a single, valid instant
> of the entire vmap_area_list, but rather a potential amalgam of
> different list states.
> 
> This is because the vmap_area_list can continue to change during
> list traversal.


As soon as we exit from get_vmalloc_info(), information can be obsolete
anyway, especially if we held a spinlock for the whole list traversal.

So using the spinlock is certainly not protecting anything in this
regard.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
