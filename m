Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6D1286B004D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 21:19:12 -0400 (EDT)
Message-ID: <1344302351.2026.24.camel@joe2Laptop>
Subject: Re: [RFC v3 4/7] workqueue: use new hashtable implementation
From: Joe Perches <joe@perches.com>
Date: Mon, 06 Aug 2012 18:19:11 -0700
In-Reply-To: <1344300317-23189-6-git-send-email-levinsasha928@gmail.com>
References: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com>
	 <1344300317-23189-6-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, Sasha Levin <sasha.levin@oracle.com>

On Tue, 2012-08-07 at 02:45 +0200, Sasha Levin wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> 
> Switch workqueues to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the workqueues.

Just style trivia:

> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
[]
> @@ -897,8 +839,15 @@ static struct worker *__find_worker_executing_work(struct global_cwq *gcwq,
>  static struct worker *find_worker_executing_work(struct global_cwq *gcwq,
>  						 struct work_struct *work)
>  {
> -	return __find_worker_executing_work(gcwq, busy_worker_head(gcwq, work),
> -					    work);
> +	struct worker *worker;
> +	struct hlist_node *tmp;
> +
> +	hash_for_each_possible(gcwq->busy_hash, worker, BUSY_WORKER_HASH_ORDER,
> +								tmp, hentry, work)
> +		if (worker->current_work == work)
> +			return worker;

braces please:

	hash_for_each_possible(gcwq->busy_hash, worker, BUSY_WORKER_HASH_ORDER,
			       tmp, hentry, work) {
		if (worker->current_work == work)
			return worker;
	}

[]

@@ -1916,7 +1865,7 @@ static void cwq_dec_nr_in_flight(struct cpu_workqueue_struct *cwq, int color,
>   * @worker: self
>   * @work: work to process
>   *
> - * Process @work.  This function contains all the logics necessary to
> + * Process @work.  This? function contains all the logics necessary to

Odd ? and the grammar also seems odd.

>   * process a single work including synchronization against and
>   * interaction with other workers on the same cpu, queueing and
>   * flushing.  As long as context requirement is met, any worker can


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
