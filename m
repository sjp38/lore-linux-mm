Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87CF06B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:53:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v8so2015732wmh.2
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:53:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j134si1911389wmj.210.2017.11.29.13.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 13:53:22 -0800 (PST)
Date: Wed, 29 Nov 2017 13:53:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-Id: <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
In-Reply-To: <1511965054-6328-1-git-send-email-longman@redhat.com>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Nov 2017 09:17:34 -0500 Waiman Long <longman@redhat.com> wrote:

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

Patch looks good.

Can someone (Dave?) please explain why list_lru_del() supports deletion
of an already list_empty(item)?  This seems a rather dangerous thing to
encourage.  Use cases I can think of are:

a) item is already reliably deleted, so why the heck was the caller
   calling list_lru_del() and 

b) item might be concurrently deleted by another thread, in which case
   the race loser is likely to hit a use-after-free.

Is there a good use case here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
