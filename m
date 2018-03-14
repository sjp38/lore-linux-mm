Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4381D6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 16:56:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p128so1912856pga.19
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:56:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p66si1829702pfk.100.2018.03.14.13.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 13:56:32 -0700 (PDT)
Date: Wed, 14 Mar 2018 13:56:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-Id: <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
In-Reply-To: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 14 Mar 2018 14:51:48 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> In case of memory deficit and low percpu memory pages,
> pcpu_balance_workfn() takes pcpu_alloc_mutex for a long
> time (as it makes memory allocations itself and waits
> for memory reclaim). If tasks doing pcpu_alloc() are
> choosen by OOM killer, they can't exit, because they
> are waiting for the mutex.
> 
> The patch makes pcpu_alloc() to care about killing signal
> and use mutex_lock_killable(), when it's allowed by GFP
> flags. This guarantees, a task does not miss SIGKILL
> from OOM killer.
> 
> ...
>
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1369,8 +1369,12 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>  		return NULL;
>  	}
>  
> -	if (!is_atomic)
> -		mutex_lock(&pcpu_alloc_mutex);
> +	if (!is_atomic) {
> +		if (gfp & __GFP_NOFAIL)
> +			mutex_lock(&pcpu_alloc_mutex);
> +		else if (mutex_lock_killable(&pcpu_alloc_mutex))
> +			return NULL;
> +	}

It would benefit from a comment explaining why we're doing this (it's
for the oom-killer).

My memory is weak and our documentation is awful.  What does
mutex_lock_killable() actually do and how does it differ from
mutex_lock_interruptible()?  Userspace tasks can run pcpu_alloc() and I
wonder if there's any way in which a userspace-delivered signal can
disrupt another userspace task's memory allocation attempt?
