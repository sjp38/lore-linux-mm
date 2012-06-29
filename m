Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D66A86B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:07:55 -0400 (EDT)
Message-ID: <4FEDEE9F.4080103@redhat.com>
Date: Fri, 29 Jun 2012 14:06:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/40] autonuma: add page structure fields
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-15-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> On 64bit archs, 20 bytes are used for async memory migration (specific
> to the knuma_migrated per-node threads), and 4 bytes are used for the
> thread NUMA false sharing detection logic.
>
> This is a bad implementation due lack of time to do a proper one.

It is not ideal, no.

If you document what everything does, maybe somebody else
will understand the code well enough to help fix it.

> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -136,6 +136,32 @@ struct page {
>   		struct page *first_page;	/* Compound tail pages */
>   	};
>
> +#ifdef CONFIG_AUTONUMA
> +	/*
> +	 * FIXME: move to pgdat section along with the memcg and allocate
> +	 * at runtime only in presence of a numa system.
> +	 */

Once you fix it, could you fold the fix into this patch?

> +	/*
> +	 * To modify autonuma_last_nid lockless the architecture,
> +	 * needs SMP atomic granularity<  sizeof(long), not all archs
> +	 * have that, notably some ancient alpha (but none of those
> +	 * should run in NUMA systems). Archs without that requires
> +	 * autonuma_last_nid to be a long.
> +	 */
> +#if BITS_PER_LONG>  32
> +	int autonuma_migrate_nid;
> +	int autonuma_last_nid;
> +#else
> +#if MAX_NUMNODES>= 32768
> +#error "too many nodes"
> +#endif
> +	/* FIXME: remember to check the updates are atomic */
> +	short autonuma_migrate_nid;
> +	short autonuma_last_nid;
> +#endif
> +	struct list_head autonuma_migrate_node;
> +#endif

Please document what these fields mean.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
