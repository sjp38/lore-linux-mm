Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A5A0B6B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 17:47:08 -0400 (EDT)
Date: Tue, 13 Mar 2012 14:47:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 7/8] memcg: move HugeTLB resource count to parent
 cgroup on memcg removal
Message-Id: <20120313144705.020b6dde.akpm@linux-foundation.org>
In-Reply-To: <1331622432-24683-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 12:37:11 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add support for memcg removal with HugeTLB resource usage.
> 
> ...
>
> +int hugetlb_force_memcg_empty(struct cgroup *cgroup)

It's useful to document things, you know.  For a major function like
this, a nice little description of why it exists, what its role is,
etc.  Programming is not just an act of telling a computer what to do:
it is also an act of telling other programmers what you wished the
computer to do.  Both are important, and the latter deserves care.

> +{
> +	struct hstate *h;
> +	struct page *page;
> +	int ret = 0, idx = 0;
> +
> +	do {
> +		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
> +			goto out;
> +		if (signal_pending(current)) {
> +			ret = -EINTR;
> +			goto out;
> +		}

Why is its behaviour altered by signal_pending()?  This seems broken.

> +		for_each_hstate(h) {
> +			spin_lock(&hugetlb_lock);
> +			list_for_each_entry(page, &h->hugepage_activelist, lru) {
> +				ret = mem_cgroup_move_hugetlb_parent(idx, cgroup, page);
> +				if (ret) {
> +					spin_unlock(&hugetlb_lock);
> +					goto out;
> +				}
> +			}
> +			spin_unlock(&hugetlb_lock);
> +			idx++;
> +		}
> +		cond_resched();
> +	} while (mem_cgroup_hugetlb_usage(cgroup) > 0);
> +out:
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
