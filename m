Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id E5ED56B014E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 16:09:37 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so825256qcq.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 13:09:37 -0700 (PDT)
Message-ID: <506DED04.6090706@gmail.com>
Date: Thu, 04 Oct 2012 16:09:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 29/33] autonuma: page_autonuma
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <1349308275-2174-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-30-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, kosaki.motohiro@gmail.com

> +struct page_autonuma *lookup_page_autonuma(struct page *page)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	unsigned long offset;
> +	struct page_autonuma *base;
> +
> +	base = NODE_DATA(page_to_nid(page))->node_page_autonuma;
> +#ifdef CONFIG_DEBUG_VM
> +	/*
> +	 * The sanity checks the page allocator does upon freeing a
> +	 * page can reach here before the page_autonuma arrays are
> +	 * allocated when feeding a range of pages to the allocator
> +	 * for the first time during bootup or memory hotplug.
> +	 */
> +	if (unlikely(!base))
> +		return NULL;
> +#endif

When using CONFIG_DEBUG_VM, please just use BUG_ON instead of additional
sanity check. Otherwise only MM people might fault to find a real bug.


And I have additional question here. What's happen if memory hotplug occur
and several autonuma_last_nid will point to invalid node id? My quick skimming
didn't find hotplug callback code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
