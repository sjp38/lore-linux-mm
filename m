Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 522F28E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:26:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v14-v6so2869027qkg.8
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:26:39 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id v15-v6si1538787qkf.370.2018.09.27.08.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Sep 2018 08:26:38 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:26:38 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [STABLE PATCH] slub: make ->cpu_partial unsigned int
In-Reply-To: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com>
Message-ID: <010001661ba398a8-f7e5b6c8-b7ff-4f01-8b18-0ad582344ea7-000000@email.amazonses.com>
References: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: gregkh@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, 27 Sep 2018, zhong jiang wrote:

> From: Alexey Dobriyan <adobriyan@gmail.com>
>
>         /*
>          * cpu_partial determined the maximum number of objects
>          * kept in the per cpu partial lists of a processor.
>          */
>
> Can't be negative.

True.

> I hit a real issue that it will result in a large number of memory leak.
> Because Freeing slabs are in interrupt context. So it can trigger this issue.
> put_cpu_partial can be interrupted more than once.
> due to a union struct of lru and pobjects in struct page, when other core handles
> page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
> result in pobjects being a negative value(0xdead0000). Therefore, a large number
> of slabs will be added to per_cpu partial list.

That sounds like it needs more investigation. Concurrent use of page
fields for other purposes can cause serious bugs.

>
> I had posted the issue to community before. The detailed issue description is as follows.

I did not see it. Please make sure to CC the maintainers.
