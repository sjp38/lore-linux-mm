Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 814A46B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 17:47:49 -0500 (EST)
Message-ID: <50BD2BB9.7010808@redhat.com>
Date: Mon, 03 Dec 2012 17:46:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 32/52] sched: Track groups of shared tasks
References: <1354473824-19229-1-git-send-email-mingo@kernel.org> <1354473824-19229-33-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-33-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/02/2012 01:43 PM, Ingo Molnar wrote:

> This is not entirely correct as this task might have scheduled or
> migrate ther - but statistically there will be correlation to the
           ^^^^ there?

> tasks that we share memory with, and correlation is all we need.
>
> We map out the relation itself by filtering out the highest address
> ask that is below our own task address, per working set scan
   ^^^ task?
> iteration.

> @@ -906,23 +945,122 @@ out_backoff:
>   }
>
>   /*
> + * Track our "memory buddies" the tasks we actively share memory with.
> + *
> + * Firstly we establish the identity of some other task that we are
> + * sharing memory with by looking at rq[page::last_cpu].curr - i.e.
> + * we check the task that is running on that CPU right now.
> + *
> + * This is not entirely correct as this task might have scheduled or
> + * migrate ther - but statistically there will be correlation to the
               ^^^^ there

> + * tasks that we share memory with, and correlation is all we need.
> + *
> + * We map out the relation itself by filtering out the highest address
> + * ask that is below our own task address, per working set scan
       ^^^ task?

If that word is "task", the comment makes sense. If it is
something else, I'm back to square one on what the code does :)


>   void task_numa_fault(int node, int last_cpu, int pages)
>   {
>   	struct task_struct *p = current;
>   	int priv = (task_cpu(p) == last_cpu);
> +	int idx = 2*node + priv;
>
>   	if (unlikely(!p->numa_faults)) {
> -		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
> +		int entries = 2*nr_node_ids;
> +		int size = sizeof(*p->numa_faults) * entries;
>
> -		p->numa_faults = kzalloc(size, GFP_KERNEL);
> +		p->numa_faults = kzalloc(2*size, GFP_KERNEL);

So we multiply nr_node_ids by 2. Twice.

That kind of magic deserves a comment explaining how
and why.  How about:

	/*
	 * We track two arrays with private and shared faults
	 * for each NUMA node. The p->numa_faults_curr array
	 * is allocated at the same time as the p->numa_faults
	 * array.
	 */
	int size = sizeof(*p->numa_faults) * 4 * nr_node_ids;

>   		if (!p->numa_faults)
>   			return;
> +		/*
> +		 * For efficiency reasons we allocate ->numa_faults[]
> +		 * and ->numa_faults_curr[] at once and split the
> +		 * buffer we get. They are separate otherwise.
> +		 */
> +		p->numa_faults_curr = p->numa_faults + entries;
>   	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
