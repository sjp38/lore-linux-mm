Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2631D6B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 20:01:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so122799271pfa.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 17:01:44 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id hi6si170244pac.108.2016.07.13.17.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 17:01:43 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id pp5so15533288pac.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 17:01:43 -0700 (PDT)
Date: Wed, 13 Jul 2016 17:01:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1607131659190.92037@chino.kir.corp.google.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 13 Jul 2016, Tetsuo Handa wrote:

> I wonder whether commit f9054c70d28bc214 ("mm, mempool: only set
> __GFP_NOMEMALLOC if there are free elements") is doing correct thing.
> It says
> 
>     If an oom killed thread calls mempool_alloc(), it is possible that it'll
>     loop forever if there are no elements on the freelist since
>     __GFP_NOMEMALLOC prevents it from accessing needed memory reserves in
>     oom conditions.
> 
> but we can allow mempool_alloc(__GFP_NOMEMALLOC) requests to access
> memory reserves via below change, can't we? The purpose of allowing
> ALLOC_NO_WATERMARKS via TIF_MEMDIE is to make sure current allocation
> request does not to loop forever inside the page allocator, isn't it?

This would defeat the purpose of __GFP_NOMEMALLOC for oom killed threads, 
so you'd need to demonstrate that isn't a problem for the current users 
and then change the semantics of the gfp flag.

> Why we need to allow mempool_alloc(__GFP_NOMEMALLOC) requests to use
> ALLOC_NO_WATERMARKS when TIF_MEMDIE is not set?
> 

mempool_alloc(__GFP_NOMEMALLOC) is forbidden.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
