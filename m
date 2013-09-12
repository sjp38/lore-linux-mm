Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 68AFE6B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 08:45:54 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id c11so826655lbj.41
        for <linux-mm@kvack.org>; Thu, 12 Sep 2013 05:45:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378805550-29949-42-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-42-git-send-email-mgorman@suse.de>
Date: Thu, 12 Sep 2013 20:45:52 +0800
Message-ID: <CAJd=RBCdFjKkCx=3+K0PD5Hmj_C=Bggnebt28Zpdw-wOdNZnWA@mail.gmail.com>
Subject: Re: [PATCH 41/50] sched: numa: Use {cpu, pid} to create task groups
 for shared faults
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Mel

On Tue, Sep 10, 2013 at 5:32 PM, Mel Gorman <mgorman@suse.de> wrote:
>
> +void task_numa_free(struct task_struct *p)
> +{
> +       struct numa_group *grp = p->numa_group;
> +       int i;
> +
> +       kfree(p->numa_faults);
> +
> +       if (grp) {
> +               for (i = 0; i < 2*nr_node_ids; i++)
> +                       atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
> +
use after free :/

> +               spin_lock(&grp->lock);
> +               list_del(&p->numa_entry);
> +               grp->nr_tasks--;
> +               spin_unlock(&grp->lock);
> +               rcu_assign_pointer(p->numa_group, NULL);
> +               put_numa_group(grp);
> +       }
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
