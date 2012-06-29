Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F132D6B0078
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:18:01 -0400 (EDT)
Date: Fri, 29 Jun 2012 14:17:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-Id: <20120629141759.3312b49e.akpm@linux-foundation.org>
In-Reply-To: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 29 Jun 2012 13:49:52 +0200
Petr Holasek <pholasek@redhat.com> wrote:

> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes
> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).
> 
> Typical use-case could be a lot of KVM guests on NUMA machine
> and cpus from more distant nodes would have significant increase
> of access latency to the merged ksm page. Sysfs knob was choosen
> for higher scalability.
> 
> Every numa node has its own stable & unstable trees because
> of faster searching and inserting. Changing of merge_nodes
> value is possible only when there are not any ksm shared pages in system.

It would be neat to have a knob which enables KSM for all anon
mappings.  ie: pretend that MADV_MERGEABLE is always set.  For testing
coverage purposes.

> I've tested this patch on numa machines with 2, 4 and 8 nodes and
> measured speed of memory access inside of KVM guests with memory pinned
> to one of nodes with this benchmark:
> 
> http://pholasek.fedorapeople.org/alloc_pg.c
> 
> Population standard deviations of access times in percentage of average
> were following:
> 
> merge_nodes=1
> 2 nodes 1.4%
> 4 nodes 1.6%
> 8 nodes	1.7%
> 
> merge_nodes=0
> 2 nodes	1%
> 4 nodes	0.32%
> 8 nodes	0.018%

ooh, numbers!  Thanks.

> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -58,6 +58,12 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
>                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
>                     Default: 20 (chosen for demonstration purposes)
>  
> +merge_nodes      - specifies if pages from different numa nodes can be merged.
> +                   When set to 0, ksm merges only pages which physically
> +                   resides in the memory area of same NUMA node. It brings
> +                   lower latency to access to shared page.
> +                   Default: 1

s/resides/reside/.

This doc should mention that /sys/kernel/mm/ksm/run should be zeroed to
alter merge_nodes.  Otherwise confusion will reign.

>
> ...
>
> +static ssize_t merge_nodes_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long knob;
> +
> +	err = kstrtoul(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	if (knob > 1)
> +		return -EINVAL;
> +
> +	if (ksm_run & KSM_RUN_MERGE)
> +		return -EBUSY;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	if (ksm_merge_nodes != knob) {
> +		if (ksm_pages_shared > 0)
> +			return -EBUSY;
> +		else
> +			ksm_merge_nodes = knob;
> +	}
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return count;
> +}

Seems a bit racy.  Shouldn't the test of ksm_run be inside the locked
region?

> +KSM_ATTR(merge_nodes);
> +#endif
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
