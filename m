Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id AC83B6B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 22:17:30 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id xn12so1601961obc.20
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:17:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373901620-2021-10-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<1373901620-2021-10-git-send-email-mgorman@suse.de>
Date: Wed, 17 Jul 2013 10:17:29 +0800
Message-ID: <CAJd=RBDhYMifi8hp7dX5TQrAegNwmaU9wYPtHCjBv5Dhp1E4BQ@mail.gmail.com>
Subject: Re: [PATCH 09/18] sched: Add infrastructure for split shared/private
 accounting of NUMA hinting faults
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
>  /*
>   * Got a PROT_NONE fault for a page on @node.
>   */
> -void task_numa_fault(int node, int pages, bool migrated)
> +void task_numa_fault(int last_nid, int node, int pages, bool migrated)

For what is the new parameter?

>  {
>         struct task_struct *p = current;
> +       int priv;
>
>         if (!sched_feat_numa(NUMA))
>                 return;
>
> +       /* For now, do not attempt to detect private/shared accesses */
> +       priv = 1;
> +
>         /* Allocate buffer to track faults on a per-node basis */
>         if (unlikely(!p->numa_faults)) {
> -               int size = sizeof(*p->numa_faults) * nr_node_ids;
> +               int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
>
>                 /* numa_faults and numa_faults_buffer share the allocation */
>                 p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
> @@ -900,7 +915,7 @@ void task_numa_fault(int node, int pages, bool migrated)
>                         return;
>
>                 BUG_ON(p->numa_faults_buffer);
> -               p->numa_faults_buffer = p->numa_faults + nr_node_ids;
> +               p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
>         }
>
>         /*
> @@ -914,7 +929,7 @@ void task_numa_fault(int node, int pages, bool migrated)
>         task_numa_placement(p);
>
>         /* Record the fault, double the weight if pages were migrated */
> -       p->numa_faults_buffer[node] += pages << migrated;
> +       p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
