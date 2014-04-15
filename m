Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75C046B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 20:02:16 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id i4so9907163oah.24
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 17:02:16 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id g2si15141545obv.159.2014.04.14.17.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 17:02:15 -0700 (PDT)
Message-ID: <1397520133.31076.24.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/3] mm,vmacache: optimize overflow system-wide flushing
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 14 Apr 2014 17:02:13 -0700
In-Reply-To: <1397519841-24847-4-git-send-email-davidlohr@hp.com>
References: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
	 <1397519841-24847-4-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aswin@hp.com, Oleg Nesterov <oleg@redhat.com>

Stupid script... Cc'ing Oleg.

On Mon, 2014-04-14 at 16:57 -0700, Davidlohr Bueso wrote:
> For single threaded workloads, we can avoid flushing
> and iterating through the entire list of tasks, making
> the whole function a lot faster, requiring only a single
> atomic read for the mm_users.
> 
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  mm/vmacache.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/vmacache.c b/mm/vmacache.c
> index e167da2..61c38ae 100644
> --- a/mm/vmacache.c
> +++ b/mm/vmacache.c
> @@ -17,6 +17,16 @@ void vmacache_flush_all(struct mm_struct *mm)
>  {
>  	struct task_struct *g, *p;
>  
> +	/*
> +	 * Single threaded tasks need not iterate the entire
> +	 * list of process. We can avoid the flushing as well
> +	 * since the mm's seqnum was increased and don't have
> +	 * to worry about other threads' seqnum. Current's
> +	 * flush will occur upon the next lookup.
> +	 */
> +	if (atomic_read(&mm->mm_users) == 1)
> +		return;
> +
>  	rcu_read_lock();
>  	for_each_process_thread(g, p) {
>  		/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
