Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0C16B0008
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:12:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f59-v6so3110739plb.7
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:12:40 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0138.outbound.protection.outlook.com. [104.47.0.138])
        by mx.google.com with ESMTPS id h8si3324997pgq.665.2018.03.15.05.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 05:12:38 -0700 (PDT)
Subject: Re: [PATCH] Improve mutex documentation
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180315115812.GA9949@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2397831d-71b5-3cc8-9dc4-ce06e2eddfde@virtuozzo.com>
Date: Thu, 15 Mar 2018 15:12:30 +0300
MIME-Version: 1.0
In-Reply-To: <20180315115812.GA9949@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

Hi, Matthew,

On 15.03.2018 14:58, Matthew Wilcox wrote:
> On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
>> My memory is weak and our documentation is awful.  What does
>> mutex_lock_killable() actually do and how does it differ from
>> mutex_lock_interruptible()?
> 
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Add kernel-doc for mutex_lock_killable() and mutex_lock_io().  Reword the
> kernel-doc for mutex_lock_interruptible().
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
> index 858a07590e39..2048359f33d2 100644
> --- a/kernel/locking/mutex.c
> +++ b/kernel/locking/mutex.c
> @@ -1082,15 +1082,16 @@ static noinline int __sched
>  __mutex_lock_interruptible_slowpath(struct mutex *lock);
>  
>  /**
> - * mutex_lock_interruptible - acquire the mutex, interruptible
> - * @lock: the mutex to be acquired
> + * mutex_lock_interruptible() - Acquire the mutex, interruptible by signals.
> + * @lock: The mutex to be acquired.
>   *
> - * Lock the mutex like mutex_lock(), and return 0 if the mutex has
> - * been acquired or sleep until the mutex becomes available. If a
> - * signal arrives while waiting for the lock then this function
> - * returns -EINTR.
> + * Lock the mutex like mutex_lock().  If a signal is delivered while the
> + * process is sleeping, this function will return without acquiring the
> + * mutex.
>   *
> - * This function is similar to (but not equivalent to) down_interruptible().
> + * Context: Process context.
> + * Return: 0 if the lock was successfully acquired or %-EINTR if a
> + * signal arrived.
>   */
>  int __sched mutex_lock_interruptible(struct mutex *lock)
>  {
> @@ -1104,6 +1105,18 @@ int __sched mutex_lock_interruptible(struct mutex *lock)
>  
>  EXPORT_SYMBOL(mutex_lock_interruptible);
>  
> +/**
> + * mutex_lock_killable() - Acquire the mutex, interruptible by fatal signals.

Shouldn't we clarify that fatal signals are SIGKILL only?

> + * @lock: The mutex to be acquired.
> + *
> + * Lock the mutex like mutex_lock().  If a signal which will be fatal to
> + * the current process is delivered while the process is sleeping, this
> + * function will return without acquiring the mutex.
> + *
> + * Context: Process context.
> + * Return: 0 if the lock was successfully acquired or %-EINTR if a
> + * fatal signal arrived.
> + */
>  int __sched mutex_lock_killable(struct mutex *lock)
>  {
>  	might_sleep();
> @@ -1115,6 +1128,16 @@ int __sched mutex_lock_killable(struct mutex *lock)
>  }
>  EXPORT_SYMBOL(mutex_lock_killable);
>  
> +/**
> + * mutex_lock_io() - Acquire the mutex and mark the process as waiting for I/O
> + * @lock: The mutex to be acquired.
> + *
> + * Lock the mutex like mutex_lock().  While the task is waiting for this
> + * mutex, it will be accounted as being in the IO wait state by the
> + * scheduler.
> + *
> + * Context: Process context.
> + */
>  void __sched mutex_lock_io(struct mutex *lock)
>  {
>  	int token;
> 
